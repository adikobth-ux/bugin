import 'package:flutter/widgets.dart';

import 'package:bugin/data/mock_catalog.dart';
import 'package:bugin/data/mock_profile.dart';
import 'package:bugin/l10n/app_language.dart';
import 'package:bugin/navigation/app_state.dart';
import 'package:bugin/services/evening_planner.dart';
import 'package:bugin/services/events_repository.dart';
import 'package:bugin/services/favorites_store.dart';
import 'package:bugin/services/mock/mock_evening_planner.dart';
import 'package:bugin/services/mock/mock_events_repository.dart';
import 'package:bugin/services/mock/mock_places_repository.dart';
import 'package:bugin/services/mock/mock_profile_repository.dart';
import 'package:bugin/services/mock/mock_search_service.dart';
import 'package:bugin/services/places_repository.dart';
import 'package:bugin/services/profile_store.dart';
import 'package:bugin/services/search_history.dart';
import 'package:bugin/services/search_service.dart';
import 'package:bugin/services/storage/key_value_store.dart';

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
  }) {
    final store = storage ?? MemoryKeyValueStore();
    final state = AppState(storage: store, language: deviceLanguage);
    AppLanguage language() => state.language.value;

    final catalog = MockCatalog(now: now);
    final planner = MockEveningPlanner(catalog, language, latency: latency);
    final history = SearchHistory(
      storage: store,
      initial: MockProfile.recentQueries(language()),
    );
    final favorites = FavoritesStore(
      storage: store,
      placeIds: MockProfile.favoritePlaceIds,
      eventIds: MockProfile.favoriteEventIds,
      scenarios: planner.library,
    );
    final profile = ProfileStore(
      MockProfile.profile(language()),
      MockProfileRepository(MockProfile.profile(language()), latency: latency),
      storage: store,
    );

    return AppServices(
      places: MockPlacesRepository(catalog, language, latency: latency),
      events: MockEventsRepository(catalog, language, latency: latency),
      search: MockSearchService(
        catalog: catalog,
        language: language,
        history: history,
        latency: latency,
      ),
      planner: planner,
      favorites: favorites,
      profile: profile,
      history: history,
      state: state,
      restoreDefaults: () {
        favorites.reset(
          placeIds: MockProfile.favoritePlaceIds,
          eventIds: MockProfile.favoriteEventIds,
          scenarios: planner.library,
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
  final VoidCallback? _restoreDefaults;

  /// Можно ли вернуть данные прототипа к начальным (есть только у mock).
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
