import 'package:bugin/data/mock_events.dart';
import 'package:bugin/data/mock_places.dart';
import 'package:bugin/l10n/app_language.dart';
import 'package:bugin/models/models.dart';

/// Места и события на обоих языках. Mock-сервисы берут данные
/// на текущем языке — так же, как backend ответит на Accept-Language.
class MockCatalog {
  MockCatalog({DateTime? now}) : now = now ?? DateTime.now();

  /// От этой даты считаются даты событий и отзывов.
  final DateTime now;

  final Map<AppLanguage, List<Place>> _places = {};
  final Map<AppLanguage, List<Event>> _events = {};

  List<Place> places(AppLanguage language) => _places.putIfAbsent(
        language,
        () => MockPlaces.build(now: now, language: language),
      );

  List<Event> events(AppLanguage language) => _events.putIfAbsent(
        language,
        () => MockEvents.build(now: now, language: language),
      );

  Place? place(AppLanguage language, String id) {
    for (final place in places(language)) {
      if (place.id == id) {
        return place;
      }
    }
    return null;
  }
}
