import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'package:bugin/data/mock_catalog.dart';
import 'package:bugin/data/mock_profile.dart';
import 'package:bugin/l10n/app_language.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/navigation/app_state.dart';
import 'package:bugin/services/api/api_client.dart';
import 'package:bugin/services/api/api_evening_planner.dart';
import 'package:bugin/services/api/api_events_repository.dart';
import 'package:bugin/services/api/api_places_repository.dart';
import 'package:bugin/services/api/api_search_service.dart';
import 'package:bugin/services/evening_planner.dart';
import 'package:bugin/services/events_repository.dart';
import 'package:bugin/services/external_links.dart';
import 'package:bugin/services/favorites_store.dart';
import 'package:bugin/services/mock/mock_evening_planner.dart';
import 'package:bugin/services/mock/mock_events_repository.dart';
import 'package:bugin/services/mock/mock_places_repository.dart';
import 'package:bugin/services/mock/mock_profile_repository.dart';
import 'package:bugin/services/mock/mock_search_service.dart';
import 'package:bugin/services/places_repository.dart';
import 'package:bugin/services/profile_repository.dart';
import 'package:bugin/services/profile_store.dart';
import 'package:bugin/services/search_history.dart';
import 'package:bugin/services/search_service.dart';
import 'package:bugin/services/storage/key_value_store.dart';

/// Источники данных — то, чем mock отличается от API.
typedef _DataSources = ({
  PlacesRepository places,
  EventsRepository events,
  SearchService search,
  EveningPlanner planner,
  ProfileRepository profileRepository,
  // Сохранённые сценарии при первом запуске и после сброса.
  List<Scenario> Function() defaultScenarios,
});

/// Все зависимости приложения. Экраны знают только интерфейсы,
/// поэтому mock-реализации заменяются на API в одном месте — здесь.
class AppServices {
  AppServices({
    required this.places,
    required this.events,
    required this.search,
    required this.planner,
    required this.favorites,
    required this.profile,
    required this.history,
    required this.state,
    this.links = const UrlLauncherLinks(),
    VoidCallback? restoreDefaults,
  }) : _restoreDefaults = restoreDefaults {
    state.language.addListener(_translateSavedScenarios);
  }

  /// Прототип на mock data.
  ///
  /// [storage] — где хранить избранное, профиль, историю и настройки
  /// (по умолчанию в памяти — для тестов). [deviceLanguage] — язык телефона,
  /// он выбирается при первом запуске.
  factory AppServices.mock({
    Duration latency = const Duration(milliseconds: 450),
    KeyValueStore? storage,
    AppLanguage deviceLanguage = AppLanguage.ru,
    DateTime? now,
    ExternalLinks links = const UrlLauncherLinks(),
  }) =>
      AppServices._onDevice(
        storage: storage,
        deviceLanguage: deviceLanguage,
        links: links,
        sources: (language, history) {
          final catalog = MockCatalog(now: now);
          final planner = MockEveningPlanner(catalog, language, latency: latency);
          return (
            places: MockPlacesRepository(catalog, language, latency: latency),
            events: MockEventsRepository(catalog, language, latency: latency),
            search: MockSearchService(
              catalog: catalog,
              language: language,
              history: history,
              latency: latency,
            ),
            planner: planner,
            profileRepository: MockProfileRepository(
              MockProfile.profile(language()),
              latency: latency,
            ),
            defaultScenarios: () => planner.library,
          );
        },
      );

  /// Данные с сервера Bugin по адресу [baseUrl] (контракт — docs/api.md
  /// в bugin-backend). Избранное, профиль и история поиска пока хранятся
  /// на устройстве: вход и `/v1/me` появятся на этапе 1.
  ///
  /// [httpClient] — для тестов (`MockClient` из `package:http/testing.dart`).
  factory AppServices.api({
    required Uri baseUrl,
    KeyValueStore? storage,
    AppLanguage deviceLanguage = AppLanguage.ru,
    ExternalLinks links = const UrlLauncherLinks(),
    http.Client? httpClient,
  }) =>
      AppServices._onDevice(
        storage: storage,
        deviceLanguage: deviceLanguage,
        links: links,
        sources: (language, history) {
          final api = ApiClient(baseUrl, language, client: httpClient);
          return (
            places: ApiPlacesRepository(api),
            events: ApiEventsRepository(api),
            search: ApiSearchService(api, language: language, history: history),
            planner: ApiEveningPlanner(api),
            // Профиль пока локальный, без задержки «сети».
            profileRepository: MockProfileRepository(
              MockProfile.profile(language()),
              latency: Duration.zero,
            ),
            // Сценарии собирает сервер — готовых в избранном нет.
            defaultScenarios: () => const <Scenario>[],
          );
        },
      );

  /// Общая часть mock и API: язык и город, история поиска, избранное
  /// и профиль живут на устройстве; сброс возвращает их к начальным.
  /// [sources] собирает источники данных — им нужны текущий язык и история.
  factory AppServices._onDevice({
    required KeyValueStore? storage,
    required AppLanguage deviceLanguage,
    required ExternalLinks links,
    required _DataSources Function(CurrentLanguage language, SearchHistory history)
        sources,
  }) {
    final store = storage ?? MemoryKeyValueStore();
    final state = AppState(storage: store, language: deviceLanguage);
    AppLanguage language() => state.language.value;

    final history = SearchHistory(
      storage: store,
      initial: MockProfile.recentQueries(language()),
    );
    final data = sources(language, history);
    final favorites = FavoritesStore(
      storage: store,
      placeIds: MockProfile.favoritePlaceIds,
      eventIds: MockProfile.favoriteEventIds,
      scenarios: data.defaultScenarios(),
    );
    final profile = ProfileStore(
      MockProfile.profile(language()),
      data.profileRepository,
      storage: store,
    );

    return AppServices(
      places: data.places,
      events: data.events,
      search: data.search,
      planner: data.planner,
      favorites: favorites,
      profile: profile,
      history: history,
      state: state,
      links: links,
      restoreDefaults: () {
        favorites.reset(
          placeIds: MockProfile.favoritePlaceIds,
          eventIds: MockProfile.favoriteEventIds,
          scenarios: data.defaultScenarios(),
        );
        profile.reset(MockProfile.profile(language()));
        history.reset(MockProfile.recentQueries(language()));
      },
    );
  }

  final PlacesRepository places;
  final EventsRepository events;
  final SearchService search;
  final EveningPlanner planner;
  final FavoritesStore favorites;
  final ProfileStore profile;
  final SearchHistory history;
  final AppState state;

  /// Переход на Ticketon, Kino.kz и сайты заведений.
  final ExternalLinks links;
  final VoidCallback? _restoreDefaults;

  /// Можно ли вернуть данные прототипа к начальным. Пока избранное, профиль
  /// и история хранятся на устройстве, сброс есть и у mock, и у API.
  bool get canResetData => _restoreDefaults != null;

  /// Возвращает избранное, профиль и историю поиска к начальным.
  /// Язык и город остаются как выбраны.
  void resetData() => _restoreDefaults?.call();

  /// Сохранённые сценарии содержат тексты — после смены языка переводим их.
  Future<void> _translateSavedScenarios() async {
    final saved = favorites.scenarios;
    if (saved.isEmpty) {
      return;
    }
    try {
      final translated = await Future.wait(saved.map(planner.localize));
      favorites.updateScenarios(translated);
    } catch (error) {
      debugPrint('Сценарии не переведены: $error');
    }
  }
}

/// Даёт экранам доступ к [AppServices] без глобальных синглтонов.
class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});

  final AppServices services;

  /// Можно вызывать и в initState: подписка на изменения не создаётся.
  static AppServices of(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<AppScope>();
    final scope = element?.widget as AppScope?;
    assert(scope != null, 'AppScope не найден в дереве виджетов');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => services != oldWidget.services;
}
