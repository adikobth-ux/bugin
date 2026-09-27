import 'package:bugin/models/models.dart';

/// Источник событий для афиши.
abstract interface class EventsRepository {
  Future<List<Event>> list({
    required EventDayFilter day,
    DateTime? date,
    EventCategory? category,
  });

  /// «Главное на неделе».
  Future<List<Event>> featured();

  Future<Event> byId(String id);

  Future<List<Event>> byIds(List<String> ids);

  Future<List<Event>> similar(String id, {int limit = 4});
}
