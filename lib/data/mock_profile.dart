import 'package:bugin/data/mock_events.dart';
import 'package:bugin/data/mock_places.dart';
import 'package:bugin/l10n/app_language.dart';
import 'package:bugin/models/models.dart';

/// Профиль и стартовые данные пользователя для первого запуска.
abstract final class MockProfile {
  static UserProfile profile(AppLanguage language) => UserProfile(
        name: 'Адильхан',
        bio: language == AppLanguage.kk
            ? 'Жақсы орындар мен жарқын сәттер'
            : 'Хорошие места и яркие моменты',
        interests: const [
          Interest.dates,
          Interest.active,
          Interest.coffee,
          Interest.concerts,
        ],
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

  static List<String> recentQueries(AppLanguage language) =>
      language == AppLanguage.kk
          ? const [
              'Жақын жердегі розеткасы бар кофехана',
              'Осы демалыс күндері концерт',
              'Кешке достармен боулинг',
            ]
          : const [
              'Кофейня с розетками рядом',
              'Концерт в эти выходные',
              'Боулинг с друзьями вечером',
            ];

  static List<String> suggestions(AppLanguage language) =>
      language == AppLanguage.kk
          ? const [
              '10 000 теңгеге дейін екеуміз тыныш кеш',
              'Сенбіде достармен қайда баруға болады',
              'Жұмыс істеуге тыныш кафе',
              'Демалыс күндері жаңа нәрсе',
            ]
          : const [
              'Спокойный вечер вдвоём до 10 000 ₸',
              'Куда сходить с друзьями в субботу',
              'Тихое кафе, чтобы поработать',
              'Что-то новое на выходных',
            ];
}
