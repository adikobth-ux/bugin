import 'dart:math';

import 'package:bugin/core/formatters.dart';
import 'package:bugin/data/mock_catalog.dart';
import 'package:bugin/data/mock_profile.dart';
import 'package:bugin/l10n/app_language.dart';
import 'package:bugin/l10n/app_strings.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/services/mock/simulated_network.dart';
import 'package:bugin/services/search_history.dart';
import 'package:bugin/services/search_service.dart';

/// Правила вместо AI: ключевые слова → параметры, параметры → ранжирование.
/// Понимает запросы на русском и казахском, объяснения пишет на языке приложения.
/// Интерфейс тот же, что будет у настоящего сервиса.
class MockSearchService implements SearchService {
  MockSearchService({
    required MockCatalog catalog,
    required CurrentLanguage language,
    required SearchHistory history,
    required this.latency,
  })  : _catalog = catalog,
        _language = language,
        _history = history;

  final MockCatalog _catalog;
  final CurrentLanguage _language;
  final SearchHistory _history;
  final Duration latency;
  final _random = Random();

  List<Place> get _places => _catalog.places(_language());
  List<Event> get _events => _catalog.events(_language());

  /// Текст объяснения на языке приложения.
  String _t(String ru, String kk) => AppStrings.forLanguage(_language()).tr(ru, kk);

  @override
  List<String> get recentQueries => _history.queries;

  @override
  List<String> get suggestions => MockProfile.suggestions(_language());

  @override
  void remember(String query) => _history.remember(query);

  @override
  void clearHistory() => _history.clear();

  // ---------- Понимание запроса ----------

  @override
  Future<SearchIntent> understand(String query) =>
      simulateNetwork(latency * 2, () => parse(query));

  SearchIntent parse(String query, {DateTime? now}) {
    final q = query.toLowerCase().replaceAll('ё', 'е');
    final moment = now ?? DateTime.now();
    bool has(List<String> words) => words.any(q.contains);

    final params = <IntentParam>[];

    final occasion = has(['девушк', 'парн', 'свидан', 'вдвоем', 'романт', 'любим', 'кездесу', 'қызбен', 'жігіт', 'екеуміз', 'сүйікті'])
        ? 'date'
        : has(['друз', 'компани', 'достар', 'досым', 'доспен'])
            ? 'friends'
            : has(['работ', 'ноут', 'розетк', 'учеб', 'позаниматься', 'жұмыс', 'оқу', 'сабақ'])
                ? 'work'
                : has(['семь', 'детьми', 'ребен', 'родител', 'отбасы', 'бала', 'ата-ана'])
                    ? 'family'
                    : has(['для себя', 'одному', 'одной', 'өзім үшін', 'жалғыз'])
                        ? 'solo'
                        : null;
    if (occasion != null) {
      params.add(IntentParam.of(ParamType.occasion, occasion));
    }

    final time = has(['вечер', 'кешке', 'кешт', 'кешкі'])
        ? 'evening'
        : has(['утр', 'завтрак', 'таңертең', 'таңғы'])
            ? 'morning'
            : has(['днем', 'обед', 'күндіз', 'түскі'])
                ? 'day'
                : has(['ноч', 'түнде', 'түнгі'])
                    ? 'night'
                    : null;
    params.add(
      time != null
          ? IntentParam.of(ParamType.time, time)
          : IntentParam.of(
              ParamType.time,
              moment.hour >= 16 ? 'evening' : 'day',
              inferred: true,
            ),
    );

    final amount = _amount(q);
    if (amount != null) {
      params.add(IntentParam.of(ParamType.budget, '$amount'));
    } else if (has(['недорог', 'не дорог', 'не слишком дорог', 'дешев', 'бюджетн', 'эконом', 'арзан', 'қымбат емес', 'үнемді'])) {
      params.add(IntentParam.of(ParamType.budget, '15000'));
    } else if (has(['шикарн', 'премиал', 'не важно сколько', 'сәнді', 'премиум'])) {
      params.add(IntentParam.of(ParamType.budget, 'any'));
    }

    final mood = has(['красив', 'романт', 'панорам', 'әдемі', 'көрінісі'])
        ? 'beautiful'
        : has(['спокой', 'тих', 'уют', 'расслаб', 'тыныш', 'жайлы', 'демал'])
            ? 'calm'
            : has(['актив', 'спорт', 'драйв', 'весел', 'подвига', 'белсенді', 'көңілді', 'қозғал'])
                ? 'active'
                : has(['нов', 'необычн', 'попробова', 'удиви', 'жаңа', 'ерекше', 'таң қалдыр'])
                    ? 'novelty'
                    : null;
    if (mood != null) {
      params.add(IntentParam.of(ParamType.mood, mood));
    }

    if (has(['рядом', 'недалеко', 'поблизости', 'возле', 'жақын', 'маңында', 'қасында'])) {
      params.add(IntentParam.of(ParamType.location, 'near'));
    } else if (has(['центр', 'орталық'])) {
      params.add(IntentParam.of(ParamType.location, 'center'));
    } else {
      params.add(IntentParam.of(ParamType.location, 'near', inferred: true));
    }

    return SearchIntent(query: query.trim(), params: params);
  }

  /// «до 10 000», «10000 ₸», «15 тыс», «8к», «10 мың». Время вида «19:00» пропускается.
  int? _amount(String q) {
    final pattern = RegExp(r'(\d[\d\s ]*\d|\d)(\s*(тыс|мың|к|k))?');
    for (final match in pattern.allMatches(q)) {
      final end = match.end;
      if (end < q.length && q[end] == ':') {
        continue;
      }
      final digits = match.group(1)!.replaceAll(RegExp(r'[\s ]'), '');
      var value = int.tryParse(digits);
      if (value == null) {
        continue;
      }
      if (match.group(3) != null) {
        value *= 1000;
      }
      if (value >= 1000 && value <= 1000000) {
        return value;
      }
    }
    return null;
  }

  // ---------- Подбор ----------

  @override
  Future<List<Recommendation>> recommend(SearchIntent intent) =>
      simulateNetwork(latency, () => rank(intent, DateTime.now()));

  List<Recommendation> rank(SearchIntent intent, DateTime now) {
    final budget = intent.param(ParamType.budget)?.budgetValue;
    final occasion = Occasion.tryParse(intent.param(ParamType.occasion)?.code);
    final vibe = Vibe.tryParse(intent.param(ParamType.mood)?.code);
    final timeCode = intent.param(ParamType.time)?.code;
    final near = intent.param(ParamType.location)?.code == 'near';
    final targetMinute = switch (timeCode) {
      'morning' => 10 * 60,
      'day' => 14 * 60,
      'evening' => 20 * 60,
      'night' => 23 * 60 + 30,
      _ => null,
    };

    final result = <Recommendation>[];

    for (final place in _places) {
      if (place.category == PlaceCategory.park) {
        continue;
      }
      if (budget != null && place.averageCheck > budget) {
        continue;
      }
      if (occasion != null && !place.goodFor.contains(occasion)) {
        continue;
      }
      if (targetMinute != null && !place.openingHours.isOpenAtMinute(targetMinute)) {
        continue;
      }
      var score = place.rating * 10;
      if (occasion != null) {
        score += 10;
      }
      if (vibe != null && place.vibes.contains(vibe)) {
        score += 8;
      }
      if (near) {
        score -= place.distanceKm * 4;
      }
      result.add(
        Recommendation.place(
          place,
          reason: _join(place.pitch, _budgetPhrase(place.averageCheck, budget)),
          details: _placeDetails(place, occasion, budget),
          score: score,
        ),
      );
    }

    for (final event in _events) {
      if (Fmt.dayDiff(event.startsAt, now) != 0) {
        continue;
      }
      if (budget != null && event.priceFrom > budget) {
        continue;
      }
      if (occasion != null && !event.occasions.contains(occasion)) {
        continue;
      }
      final hour = event.startsAt.hour;
      if (timeCode == 'evening' && hour < 17 && !event.isLongRunning) {
        continue;
      }
      if (timeCode == 'morning' && hour >= 13 && !event.isLongRunning) {
        continue;
      }
      var score = 40.0;
      if (occasion != null) {
        score += 10;
      }
      if (vibe != null && event.vibes.contains(vibe)) {
        score += 8;
      }
      if (near) {
        score -= event.distanceKm * 4;
      }
      result.add(
        Recommendation.event(
          event,
          reason: _join(event.pitch, _budgetPhrase(event.priceFrom, budget)),
          details: event.reasons,
          score: score,
        ),
      );
    }

    result.sort((a, b) => b.score.compareTo(a.score));
    return result;
  }

  @override
  Future<Recommendation> surprise() => simulateNetwork(latency, () {
        final pool = rank(
          const SearchIntent(query: '', params: []),
          DateTime.now(),
        );
        return pool[_random.nextInt(pool.length)];
      });

  String _join(String base, String? tail) {
    if (tail == null) {
      return base;
    }
    return base.contains('—') ? '$base, $tail' : '$base — $tail';
  }

  String? _budgetPhrase(int price, int? budget) {
    if (budget == null) {
      return null;
    }
    if (price == 0) {
      return _t('бесплатно', 'тегін');
    }
    if (price <= budget * 0.6) {
      return _t('дешевле твоего бюджета', 'бюджетіңнен арзан');
    }
    return _t('в рамках бюджета', 'бюджетке сай');
  }

  List<String> _placeDetails(Place p, Occasion? occasion, int? budget) {
    final occasionPhrase = switch (occasion) {
      Occasion.date => _t('хорошо для свидания', 'кездесуге жақсы'),
      Occasion.friends => _t('удобно компанией', 'достармен баруға ыңғайлы'),
      Occasion.work => _t('можно спокойно поработать', 'тыныш жұмыс істеуге болады'),
      Occasion.family => _t('подойдёт всей семьёй', 'бүкіл отбасыға лайық'),
      Occasion.solo => _t('приятно провести время одному', 'жалғыз уақыт өткізуге жақсы'),
      null => null,
    };
    return [
      _join(p.pitch, occasionPhrase),
      if (budget != null)
        p.isFree
            ? _t('Бесплатно — бюджет не тратится', 'Тегін — бюджет жұмсалмайды')
            : _t(
                '${Fmt.approxTenge(p.averageCheck)} на человека — '
                    'в рамках твоих ${Fmt.tenge(budget)}',
                'Бір адамға ${Fmt.approxTenge(p.averageCheck)} — '
                    'сенің ${Fmt.tenge(budget)} бюджетіңе сай',
              ),
      if (p.bookingType == BookingType.table)
        _t('Есть свободные столики сегодня с 19:00', 'Бүгін 19:00-ден бос үстелдер бар')
      else
        _t(
          '${Fmt.distance(p.distanceKm)} от тебя · ${p.taxiMinutes} мин на такси',
          'Саған дейін ${Fmt.distance(p.distanceKm)} · таксимен ${p.taxiMinutes} мин',
        ),
    ];
  }
}
