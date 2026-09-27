import 'package:bugin/core/app_images.dart';
import 'package:bugin/data/mock_places.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/services/evening_planner.dart';
import 'package:bugin/services/mock/simulated_network.dart';

/// Вариант для роли в плане.
class _Candidate {
  const _Candidate(this.placeId, this.kindLabel, this.durationMinutes, {this.cost});

  final String placeId;
  final String kindLabel;
  final int durationMinutes;

  /// Если null — берётся средний чек места.
  final int? cost;
}

/// Собирает план по правилам: шаблон по настроению → первый вариант,
/// который укладывается в остаток бюджета → расписание с переездами.
class MockEveningPlanner implements EveningPlanner {
  MockEveningPlanner(List<Place> places, {required this.latency})
      : _places = {for (final p in places) p.id: p} {
    _library = [
      _compose(
        const EveningRequest(),
        id: 'calm_evening_pair',
        image: AppImages.scenarioEvening,
      ),
      _workDay(),
      _compose(
        const EveningRequest(
          company: Company.friends,
          day: PlanDay.weekend,
          startMinutes: 18 * 60,
          mood: Mood.active,
        ),
        id: 'active_saturday',
        title: 'Активная суббота',
      ),
    ];
  }

  final Map<String, Place> _places;
  final Duration latency;
  late final List<Scenario> _library;

  /// Готовые сценарии (для избранного и главной).
  List<Scenario> get library => List.unmodifiable(_library);

  static const _templates = <Mood, List<StopRole>>{
    Mood.calm: [StopRole.coffee, StopRole.walk, StopRole.dinner],
    Mood.active: [StopRole.activity, StopRole.dinner],
    Mood.novelty: [StopRole.novelty, StopRole.walk, StopRole.dinner],
    Mood.culture: [StopRole.culture, StopRole.walk, StopRole.dinner],
  };

  static const _candidates = <StopRole, List<_Candidate>>{
    StopRole.coffee: [
      _Candidate(MockPlaces.coffeeLab, 'Кофе и десерт', 60),
      _Candidate(MockPlaces.theGarden, 'Кофе и десерт', 60),
    ],
    StopRole.walk: [
      _Candidate(MockPlaces.esilEmbankment, 'Прогулка', 45),
    ],
    StopRole.dinner: [
      _Candidate(MockPlaces.theGarden, 'Ужин', 105),
      _Candidate(MockPlaces.skyLounge, 'Ужин с видом', 105),
    ],
    StopRole.activity: [
      _Candidate(MockPlaces.galaxyBowling, 'Боулинг', 120),
      _Candidate(MockPlaces.lunaCinema, 'Кино', 150),
    ],
    StopRole.culture: [
      _Candidate(MockPlaces.bastauGallery, 'Выставка', 75),
      _Candidate(MockPlaces.lunaCinema, 'Кино', 150),
    ],
    StopRole.novelty: [
      _Candidate(MockPlaces.holstStudio, 'Мастер-класс', 120),
      _Candidate(MockPlaces.galaxyBowling, 'Боулинг', 120),
    ],
    StopRole.work: [
      _Candidate(MockPlaces.coffeeLab, 'Кофе и работа', 240, cost: 5000),
    ],
  };

  @override
  Future<Scenario> plan(EveningRequest request) => simulateNetwork(
        latency * 3,
        () => _compose(request, id: 'plan_${DateTime.now().millisecondsSinceEpoch}'),
      );

  @override
  Future<Scenario> featured() => simulateNetwork(latency, () {
        final hour = DateTime.now().hour;
        final id = hour < 16 ? 'work_day' : 'calm_evening_pair';
        return _library.firstWhere((s) => s.id == id);
      });

  @override
  Future<List<PlanStop>> alternatives(Scenario scenario, int index) =>
      simulateNetwork(latency, () {
        final current = scenario.stops[index];
        final budget = scenario.request?.budget;
        final spentWithout = scenario.totalCost - current.cost;
        final noCinema = _noCinema(scenario.request);
        final used = scenario.stops.map((s) => s.placeId).toSet();
        final result = <PlanStop>[];
        for (final candidate in _allCandidatesFor(current.role)) {
          if (used.contains(candidate.placeId)) {
            continue;
          }
          final stop = _toStop(current.role, candidate, current.startMinutes);
          if (stop == null) {
            continue;
          }
          if (noCinema && _isCinema(stop.placeId)) {
            continue;
          }
          if (budget != null && spentWithout + stop.cost > budget) {
            continue;
          }
          result.add(stop);
        }
        return result;
      });

  @override
  Future<Scenario> replaceStop(Scenario scenario, int index, PlanStop stop) =>
      simulateNetwork(latency, () {
        final stops = List<PlanStop>.of(scenario.stops);
        stops[index] = stop;
        final scheduled = _schedule(stops, scenario.startMinutes);
        return scenario.copyWith(stops: scheduled.stops, legs: scheduled.legs);
      });

  // ---------- Сборка ----------

  Scenario _compose(
    EveningRequest request, {
    required String id,
    String? title,
    String? image,
  }) {
    final roles = _templates[request.mood] ?? _templates[Mood.calm]!;
    final chosen = _choose(roles, request.budget, _noCinema(request));

    final scheduled = _schedule(chosen, request.startMinutes);
    return Scenario(
      id: id,
      title: title ?? '${request.mood.adjective} вечер ${request.company.titleSuffix}',
      stops: scheduled.stops,
      legs: scheduled.legs,
      image: image,
      request: request,
    );
  }

  /// Перебирает варианты по ролям (их немного) и берёт план с наибольшим
  /// числом точек в рамках бюджета; при равенстве — с более предпочтительными местами.
  List<PlanStop> _choose(List<StopRole> roles, int? budget, bool noCinema) {
    var best = <PlanStop>[];
    var bestPenalty = 1 << 30;

    void search(int i, List<PlanStop> chosen, int spent, int penalty) {
      if (i == roles.length) {
        final better = chosen.length > best.length ||
            (chosen.length == best.length && penalty < bestPenalty);
        if (better) {
          best = List.of(chosen);
          bestPenalty = penalty;
        }
        return;
      }
      final candidates = _candidates[roles[i]] ?? const <_Candidate>[];
      for (var c = 0; c < candidates.length; c++) {
        final candidate = candidates[c];
        if (noCinema && _isCinema(candidate.placeId)) {
          continue;
        }
        if (chosen.any((s) => s.placeId == candidate.placeId)) {
          continue;
        }
        final stop = _toStop(roles[i], candidate, 0);
        if (stop == null) {
          continue;
        }
        if (budget != null && spent + stop.cost > budget) {
          continue;
        }
        chosen.add(stop);
        search(i + 1, chosen, spent + stop.cost, penalty + c);
        chosen.removeLast();
      }
      // Вариант «пропустить эту роль».
      search(i + 1, chosen, spent, penalty + 10);
    }

    search(0, <PlanStop>[], 0, 0);
    return best;
  }

  Scenario _workDay() {
    final candidate = _candidates[StopRole.work]!.first;
    final stop = _toStop(StopRole.work, candidate, 10 * 60)!;
    return Scenario(
      id: 'work_day',
      title: 'Спокойный день',
      subtitle: 'Кофейня → работа',
      image: AppImages.scenarioWorkDay,
      stops: [stop],
      legs: const [],
      tags: const ['Wi-Fi', 'Розетки', 'Тихо'],
    );
  }

  PlanStop? _toStop(StopRole role, _Candidate candidate, int start) {
    final place = _places[candidate.placeId];
    if (place == null) {
      return null;
    }
    return PlanStop(
      role: role,
      placeId: place.id,
      title: place.name,
      kindLabel: candidate.kindLabel,
      startMinutes: start,
      durationMinutes: candidate.durationMinutes,
      cost: candidate.cost ?? place.averageCheck,
      routeLabel: place.category == PlaceCategory.park ? 'набережная' : null,
      rating: place.isFree ? null : place.rating,
      image: place.cover,
    );
  }

  /// Расставляет время: старт → длительность → переезд → округление до 15 минут.
  ({List<PlanStop> stops, List<TravelLeg> legs}) _schedule(
    List<PlanStop> stops,
    int start,
  ) {
    final resultStops = <PlanStop>[];
    final legs = <TravelLeg>[];
    var t = start;
    for (var i = 0; i < stops.length; i++) {
      final stop = stops[i].copyWith(startMinutes: t);
      resultStops.add(stop);
      t = stop.endMinutes;
      if (i < stops.length - 1) {
        final leg = _leg(stops[i].placeId, stops[i + 1].placeId);
        legs.add(leg);
        t = _roundUp15(t + leg.minutes);
      }
    }
    return (stops: resultStops, legs: legs);
  }

  TravelLeg _leg(String fromId, String toId) {
    final from = _places[fromId];
    final to = _places[toId];
    if (from == null || to == null) {
      return const TravelLeg(TravelMode.taxi, 10);
    }
    final km = (from.distanceKm - to.distanceKm).abs() + 0.3;
    if (km <= 0.8) {
      return TravelLeg(TravelMode.walk, _atLeast5((km * 12).round()));
    }
    return TravelLeg(TravelMode.taxi, _atLeast5((km * 3 + 4).round()));
  }

  Iterable<_Candidate> _allCandidatesFor(StopRole role) sync* {
    yield* _candidates[role] ?? const <_Candidate>[];
    // Для ужина и активностей можно предложить и соседние роли.
    if (role == StopRole.activity) {
      yield* _candidates[StopRole.novelty] ?? const <_Candidate>[];
    }
    if (role == StopRole.culture) {
      yield* _candidates[StopRole.novelty] ?? const <_Candidate>[];
    }
  }

  bool _noCinema(EveningRequest? request) {
    final wishes = request?.wishes.toLowerCase() ?? '';
    return wishes.contains('без кино');
  }

  bool _isCinema(String placeId) =>
      _places[placeId]?.category == PlaceCategory.cinema;

  static int _roundUp15(int minutes) => ((minutes + 14) ~/ 15) * 15;

  static int _atLeast5(int minutes) => minutes < 5 ? 5 : minutes;
}
