import 'package:flutter/widgets.dart';

import 'package:bugin/data/mock_events.dart';
import 'package:bugin/data/mock_places.dart';
import 'package:bugin/data/mock_profile.dart';
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
import 'package:bugin/services/search_service.dart';

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
    required this.state,
  });

  factory AppServices.mock({
    Duration latency = const Duration(milliseconds: 450),
  }) {
    final now = DateTime.now();
    final places = MockPlaces.build(now: now);
    final events = MockEvents.build(now: now);
    final planner = MockEveningPlanner(places, latency: latency);

    return AppServices(
      places: MockPlacesRepository(places, latency: latency),
      events: MockEventsRepository(events, latency: latency),
      search: MockSearchService(
        places: places,
        events: events,
        latency: latency,
        recent: MockProfile.recentQueries,
        suggestions: MockProfile.suggestions,
      ),
      planner: planner,
      favorites: FavoritesStore(
        placeIds: MockProfile.favoritePlaceIds,
        eventIds: MockProfile.favoriteEventIds,
        scenarios: planner.library,
      ),
      profile: ProfileStore(
        MockProfile.profile,
        MockProfileRepository(MockProfile.profile, latency: latency),
      ),
      state: AppState(),
    );
  }

  final PlacesRepository places;
  final EventsRepository events;
  final SearchService search;
  final EveningPlanner planner;
  final FavoritesStore favorites;
  final ProfileStore profile;
  final AppState state;
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
