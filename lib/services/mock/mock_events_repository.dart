import 'package:bugin/core/formatters.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/services/events_repository.dart';
import 'package:bugin/services/mock/simulated_network.dart';

class MockEventsRepository implements EventsRepository {
  MockEventsRepository(this._events, {required this.latency});

  final List<Event> _events;
  final Duration latency;

  Event? _find(String id) {
    for (final event in _events) {
      if (event.id == id) {
        return event;
      }
    }
    return null;
  }

  bool _matchesDay(Event e, EventDayFilter day, DateTime? date, DateTime now) {
    final diff = Fmt.dayDiff(e.startsAt, now);
    final toSunday = (DateTime.sunday - now.weekday) % 7;
    final weekday = e.startsAt.weekday;
    final isWeekendDay =
        weekday == DateTime.saturday || weekday == DateTime.sunday;
    return switch (day) {
      EventDayFilter.today => diff == 0,
      EventDayFilter.tomorrow => diff == 1,
      EventDayFilter.weekend => diff >= 0 && diff <= toSunday && isWeekendDay,
      EventDayFilter.date => date != null && Fmt.isSameDay(e.startsAt, date),
    };
  }

  @override
  Future<List<Event>> list({
    required EventDayFilter day,
    DateTime? date,
    EventCategory? category,
  }) =>
      simulateNetwork(latency, () {
        final now = DateTime.now();
        final result = _events
            .where((e) => _matchesDay(e, day, date, now))
            .where((e) => category == null || e.category == category)
            .toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
        return result;
      });

  @override
  Future<List<Event>> featured() => simulateNetwork(latency, () {
        final now = DateTime.now();
        return _events.where((e) {
          final diff = Fmt.dayDiff(e.startsAt, now);
          return e.isFeatured && diff >= 0 && diff < 7;
        }).toList();
      });

  @override
  Future<Event> byId(String id) => simulateNetwork(latency, () {
        final event = _find(id);
        if (event == null) {
          throw StateError('Событие $id не найдено');
        }
        return event;
      });

  @override
  Future<List<Event>> byIds(List<String> ids) => simulateNetwork(latency, () {
        final result = <Event>[];
        for (final id in ids) {
          final event = _find(id);
          if (event != null) {
            result.add(event);
          }
        }
        return result;
      });

  @override
  Future<List<Event>> similar(String id, {int limit = 4}) =>
      simulateNetwork(latency, () {
        final source = _find(id);
        final others = _events.where((e) => e.id != id).toList()
          ..sort((a, b) {
            final sameA = source != null && a.category == source.category ? 0 : 1;
            final sameB = source != null && b.category == source.category ? 0 : 1;
            if (sameA != sameB) {
              return sameA - sameB;
            }
            return a.startsAt.compareTo(b.startsAt);
          });
        return others.take(limit).toList();
      });
}
