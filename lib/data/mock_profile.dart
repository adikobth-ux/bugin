import 'package:bugin/data/mock_events.dart';
import 'package:bugin/data/mock_places.dart';
import 'package:bugin/models/models.dart';

abstract final class MockProfile {
  static const profile = UserProfile(
    name: 'Адильхан',
    bio: 'Хорошие места и яркие моменты',
    interests: [Interest.dates, Interest.active, Interest.coffee, Interest.concerts],
    typicalBudget: 10000,
    searchCount: 28,
  );

  static const favoritePlaceIds = [
    MockPlaces.theGarden,
    MockPlaces.coffeeLab,
    MockPlaces.galaxyBowling,
    MockPlaces.skyLounge,
  ];

  static const favoriteEventIds = [
    MockEvents.neonNights,
    MockEvents.rooftopAcoustic,
    MockEvents.artEvening,
  ];

  static const recentQueries = [
    'Кофейня с розетками рядом',
    'Концерт в эти выходные',
    'Боулинг с друзьями вечером',
  ];

  static const suggestions = [
    'Спокойный вечер вдвоём до 10 000 ₸',
    'Куда сходить с друзьями в субботу',
    'Тихое кафе, чтобы поработать',
    'Что-то новое на выходных',
  ];
}
