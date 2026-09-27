import 'package:bugin/core/app_images.dart';
import 'package:bugin/data/mock_catalog.dart';
import 'package:bugin/data/mock_places.dart';
import 'package:bugin/l10n/app_language.dart';
import 'package:bugin/l10n/app_strings.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/services/evening_planner.dart';
import 'package:bugin/services/mock/simulated_network.dart';

/// Вариант для роли в плане.
class _Candidate {
  const _Candidate(this.placeId, this.kind, this.durationMinutes, {this.cost});

  final String placeId;

  /// Код занятия — см. [MockEveningPlanner._kindLabel].
  final String kind;
  final int durationMinutes;

  /// Если null — берётся средний чек места.
  final int? cost;
}

/// Собирает план по правилам: шаблон по настроению → варианты,
/// которые укладываются в бюджет → расписание с переездами.
/// Тексты плана — на текущем языке приложения.
class MockEveningPlanner implements EveningPlanner {
  MockEveningPlanner(this._catalog, this._language, {required this.latency});

  final MockCatalog _catalog;
  final CurrentLanguage _language;
  final Duration latency;

  AppStrings get _l10n => AppStrings.forLanguage(_language());
  String _t(String ru, String kk) => _l10n.tr(ru, kk);
  Place? _place(String id) => _catalog.place(_language(), id);

  static const calmEveningId = 'calm_evening_pair';
  static const workDayId = 'work_day';
  static const activeSaturdayId = 'active_saturday';

  static const _activeSaturday = EveningRequest(
    company: Company.friends,
    day: PlanDay.weekend,
    startMinutes: 18 * 60,
    mood: Mood.active,
  );

  /// Готовые сценарии на текущем языке (для избранного и главной).
  List<Scenario> get library => [
        _compose(const EveningRequest(), id: calmEveningId, image: AppImages.scenarioEvening),
        _workDay(),
        _compose(_activeSaturday, id: activeSaturdayId),
      ];

  static const _templates = <Mood, List<StopRole>>{
    Mood.calm: [StopRole.coffee, StopRole.walk, StopRole.dinner],
    Mood.active: [StopRole.activity, StopRole.dinner],
    Mood.novelty: [StopRole.novelty, StopRole.walk, StopRole.dinner],
    Mood.culture: [StopRole.culture, StopRole.walk, StopRole.dinner],
  };

  static const _candidates = <StopRole, List<_Candidate>>{
    StopRole.coffee: [
      _Candidate(MockPlaces.coffeeLab, 'coffee', 60),
      _Candidate(MockPlaces.theGarden, 'coffee', 60),
    ],
    StopRole.walk: [
      _Candidate(MockPlaces.esilEmbankment, 'walk', 45),
    ],
    StopRole.dinner: [
      _Candidate(MockPlaces.theGarden, 'dinner', 105),
      _Candidate(MockPlaces.skyLounge, 'dinner_view', 105),
    ],
    StopRole.activity: [
      _Candidate(MockPlaces.galaxyBowling, 'bowling', 120),
      _Candidate(MockPlaces.lunaCinema, 'cinema', 150),
    ],
    StopRole.culture: [
      _Candidate(MockPlaces.bastauGallery, 'exhibition', 75),
      _Candidate(MockPlaces.lunaCinema, 'cinema', 150),
    ],
    StopRole.novelty: [
      _Candidate(MockPlaces.holstStudio, 'workshop', 120),
      _Candidate(MockPlaces.galaxyBowling, 'bowling', 120),
    ],
    StopRole.work: [
      _Candidate(MockPlaces.coffeeLab, 'coffee_work', 240, cost: 5000),
    ],
  };

  String _kindLabel(String kind) => switch (kind) {
        'coffee' => _t('Кофе и десерт', 'Кофе мен десерт'),
        'walk' => _t('Прогулка', 'Серуен'),
        'dinner' => _t('Ужин', 'Кешкі ас'),
        'dinner_view' => _t('Ужин с видом', 'Көрінісі әдемі кешкі ас'),
        'bowling' => _t('Боулинг', 'Боулинг'),
        'cinema' => _t('Кино', 'Кино'),
        'exhibition' => _t('Выставка', 'Көрме'),
        'workshop' => _t('Мастер-класс', 'Шеберлік сабағы'),
        'coffee_work' => _t('Кофе и работа', 'Кофе және жұмыс'),
        _ => kind,
      };

  @override
  Future<Scenario> plan(EveningRequest request) => simulateNetwork(
        latency * 3,
        () => _compose(request, id: 'plan_${DateTime.now().millisecondsSinceEpoch}'),
      );

  @override
  Future<Scenario> featured() => simulateNetwork(latency, () {
        final hour = DateTime.now().hour;
        return hour < 16
            ? _workDay()
            : _compose(
                const EveningRequest(),
                id: calmEveningId,
                image: AppImages.scenarioEvening,
              );
      });

  @override
  Future<Scenario> localize(Scenario scenario) =>
      simulateNetwork(latency, () => _localized(scenario));

  /// Тот же план (точки, время, цены), но тексты — на текущем языке.
  Scenario _localized(Scenario scenario) {
    final stops = [for (final stop in scenario.stops) _relabel(stop)];
    final request = scenario.request;
    return switch (scenario.id) {
      workDayId => _workDay().copyWith(stops: stops, legs: scenario.legs),
      activeSaturdayId => scenario.copyWith(title: _activeSaturdayTitle, stops: stops),
      _ when request != null => scenario.copyWith(
          title: _l10n.planTitle(request.mood, request.company),
          stops: stops,
        ),
      _ => scenario.copyWith(stops: stops),
    };
  }

  PlanStop _relabel(PlanStop stop) {
    final place = _place(stop.placeId);
    if (place == null) {
      return stop;
    }
    return PlanStop(
      role: stop.role,
      placeId: stop.placeId,
      kind: stop.kind,
      title: place.name,
      kindLabel: _kindLabel(stop.kind),
      startMinutes: stop.startMinutes,
      durationMinutes: stop.durationMinutes,
      cost: stop.cost,
      routeLabel: _routeLabel(place),
      rating: stop.rating,
      image: stop.image,
    );
  }

  String? _routeLabel(Place place) =>
      place.category == PlaceCategory.park ? _t('набережная', 'жағалау') : null;

  String get _activeSaturdayTitle => _t('Активная суббота', 'Белсенді сенбі');

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
    String? image,
  }) {
    final roles = _templates[request.mood] ?? _templates[Mood.calm]!;
    final chosen = _choose(roles, request.budget, _noCinema(request));

    final scheduled = _schedule(chosen, request.startMinutes);
    return Scenario(
      id: id,
      title: id == activeSaturdayId
          ? _activeSaturdayTitle
          : _l10n.planTitle(request.mood, request.company),
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
      id: workDayId,
      title: _t('Спокойный день', 'Тыныш күн'),
      subtitle: _t('Кофейня → работа', 'Кофехана → жұмыс'),
      image: AppImages.scenarioWorkDay,
      stops: [stop],
      legs: const [],
      tags: ['Wi-Fi', _t('Розетки', 'Розеткалар'), _t('Тихо', 'Тыныш')],
    );
  }

  PlanStop? _toStop(StopRole role, _Candidate candidate, int start) {
    final place = _place(candidate.placeId);
    if (place == null) {
      return null;
    }
    return PlanStop(
      role: role,
      placeId: place.id,
      kind: candidate.kind,
      title: place.name,
      kindLabel: _kindLabel(candidate.kind),
      startMinutes: start,
      durationMinutes: candidate.durationMinutes,
      cost: candidate.cost ?? place.averageCheck,
      routeLabel: _routeLabel(place),
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
    final from = _place(fromId);
    final to = _place(toId);
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
    const phrases = ['без кино', 'киносыз', 'кино емес', 'кинодан басқа', 'кино керек емес'];
    return phrases.any(wishes.contains);
  }

  bool _isCinema(String placeId) =>
      _place(placeId)?.category == PlaceCategory.cinema;

  static int _roundUp15(int minutes) => ((minutes + 14) ~/ 15) * 15;

  static int _atLeast5(int minutes) => minutes < 5 ? 5 : minutes;
}
