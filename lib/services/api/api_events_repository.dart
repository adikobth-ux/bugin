import 'package:bugin/models/models.dart';
import 'package:bugin/services/api/api_client.dart';
import 'package:bugin/services/events_repository.dart';

/// Афиша с сервера: `GET /v1/events…` (контракт — docs/api.md в bugin-backend).
class ApiEventsRepository implements EventsRepository {
  ApiEventsRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<Event>> list({
    required EventDayFilter day,
    DateTime? date,
    EventCategory? category,
  }) async {
    // Как в mock: «на дату» без выбранной даты — пустой список.
    if (day == EventDayFilter.date && date == null) {
      return <Event>[];
    }
    final query = <String, String>{
      'day': day.name,
      if (day == EventDayFilter.date && date != null) 'date': _isoDate(date),
      if (category != null) 'category': category.name,
    };
    return _events(await _api.get('/v1/events', query: query));
  }

  @override
  Future<List<Event>> featured() async =>
      _events(await _api.get('/v1/events/featured'));

  /// Неизвестный id — [ApiException] с кодом `not_found`.
  @override
  Future<Event> byId(String id) async => Event.fromJson(
        jsonObject(await _api.get('/v1/events/${Uri.encodeComponent(id)}')),
      );

  @override
  Future<List<Event>> byIds(List<String> ids) async {
    // Пустой список не запрашиваем — ответ и так известен.
    if (ids.isEmpty) {
      return <Event>[];
    }
    return _events(await _api.get('/v1/events', query: {'ids': ids.join(',')}));
  }

  @override
  Future<List<Event>> similar(String id, {int limit = 4}) async => _events(
        await _api.get(
          '/v1/events/${Uri.encodeComponent(id)}/similar',
          query: {'limit': '$limit'},
        ),
      );

  static List<Event> _events(Object? json) =>
      jsonList(json).map(Event.fromJson).toList();

  /// Дата без времени: `2026-10-03`.
  static String _isoDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }
}
