import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bugin/app.dart';
import 'package:bugin/core/formatters.dart';
import 'package:bugin/data/mock_catalog.dart';
import 'package:bugin/l10n/app_language.dart';
import 'package:bugin/l10n/app_strings.dart';
import 'package:bugin/l10n/l10n_section.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/navigation/app_state.dart';
import 'package:bugin/screens/home/home_screen.dart';
import 'package:bugin/services/app_services.dart';
import 'package:bugin/services/favorites_store.dart';
import 'package:bugin/services/mock/mock_evening_planner.dart';
import 'package:bugin/services/mock/mock_search_service.dart';
import 'package:bugin/services/search_history.dart';
import 'package:bugin/services/storage/key_value_store.dart';

void main() {
  final ru = AppStrings.forLanguage(AppLanguage.ru);
  final kk = AppStrings.forLanguage(AppLanguage.kk);

  group('Форматирование', () {
    test('числа, цены и расстояния', () {
      expect(Fmt.tenge(6000), '6 000 ₸');
      expect(Fmt.approxTenge(12000), '≈ 12 000 ₸');
      expect(Fmt.distance(1.5), '1,5 км');
      expect(Fmt.hm(19 * 60 + 5), '19:05');
    });

    test('русский', () {
      expect(ru.compactCount(1540), '1,5 тыс.');
      expect(ru.upToTenge(10000), 'до 10 000 ₸');
      expect(ru.fromTime(19 * 60), 'с 19:00');
      expect(ru.duration(150), '2,5 часа');
      expect(ruPlural(21, 'место', 'места', 'мест'), 'место');
      expect(ruPlural(3, 'место', 'места', 'мест'), 'места');
      expect(ruPlural(11, 'место', 'места', 'мест'), 'мест');
    });

    test('казахский', () {
      final now = DateTime(2026, 10, 1, 12);
      expect(kk.compactCount(1540), '1,5 мың');
      expect(kk.upToTenge(10000), '10 000 ₸-ге дейін');
      expect(kk.fromTenge(12000), '12 000 ₸-ден бастап');
      expect(kk.fromTime(19 * 60), '19:00-ден');
      expect(kk.fromTime(19 * 60 + 30), '19:30-дан');
      expect(kk.untilTime(23 * 60), '23:00-ге дейін');
      expect(kk.relativeDay(now, now: now), 'Бүгін');
      expect(kk.relativeDay(DateTime(2026, 10, 3), now: now), 'Сн, 3 қаз');
      expect(kk.longDate(DateTime(2026, 10, 3)), '3 қазан, сенбі');
      expect(kk.duration(120), '2 сағат');
      expect(kk.label(Occasion.friends), 'Достармен');
    });

    test('казахские окончания после чисел', () {
      expect(kkAblative(5), 'тен');
      expect(kkAblative(30), 'дан');
      expect(kkAblative(10), 'нан');
      expect(kkAblative(0), 'ден');
      expect(kkDative(45), 'ке');
      expect(kkDative(1000), 'ға');
    });

    test('у каждого значения справочников есть подпись на обоих языках', () {
      final values = <Enum>[
        ...Occasion.values,
        ...Vibe.values,
        ...PlaceCategory.values,
        ...AmenityType.values,
        ...EventCategory.values,
        ...EventDayFilter.values,
        ...Company.values,
        ...PlanDay.values,
        ...Mood.values,
        ...ParamType.values,
        ...TravelMode.values,
        ...Interest.values,
      ];
      for (final strings in [ru, kk]) {
        for (final value in values) {
          expect(strings.label(value), isNot(value.name), reason: '$value');
        }
      }
      for (final entry in IntentParam.options.entries) {
        for (final code in entry.value) {
          expect(kk.paramOption(entry.key, code), isNot(code), reason: code);
        }
      }
    });
  });

  group('AI-поиск (mock)', () {
    var language = AppLanguage.ru;
    final search = MockSearchService(
      catalog: MockCatalog(),
      language: () => language,
      history: SearchHistory(),
      latency: Duration.zero,
    );

    test('разбирает запрос из ТЗ', () {
      final intent = search.parse(
        'Хочу сегодня вечером сходить куда-нибудь с девушкой, '
        'чтобы было красиво и не слишком дорого',
      );
      expect(intent.param(ParamType.occasion)?.code, 'date');
      expect(intent.param(ParamType.time)?.code, 'evening');
      expect(intent.param(ParamType.budget)?.code, '15000');
      expect(intent.param(ParamType.mood)?.code, 'beautiful');
      expect(intent.param(ParamType.location)?.inferred, isTrue);
    });

    test('понимает запрос на казахском', () {
      final intent = search.parse('Кешке қызбен әдемі жерге, 10 мыңға дейін');
      expect(intent.param(ParamType.occasion)?.code, 'date');
      expect(intent.param(ParamType.time)?.code, 'evening');
      expect(intent.param(ParamType.budget)?.budgetValue, 10000);
      expect(intent.param(ParamType.mood)?.code, 'beautiful');
    });

    test('время «19:00» не путается с бюджетом', () {
      final intent = search.parse('кафе в 19:00 до 10 000 тенге');
      expect(intent.param(ParamType.budget)?.budgetValue, 10000);
    });

    test('выдача не выходит за бюджет и объясняет на языке приложения', () {
      final intent = search.parse('свидание до 5000');
      final items = search.rank(intent, DateTime.now());
      expect(items, isNotEmpty);
      expect(items.every((item) => item.price <= 5000), isTrue);

      language = AppLanguage.kk;
      final kkItems = search.rank(intent, DateTime.now());
      expect(kkItems.map((i) => i.id), items.map((i) => i.id));
      expect(kkItems.first.reason, isNot(items.first.reason));
      language = AppLanguage.ru;
    });

    test('история поиска: без повторов, свежие сверху', () {
      search
        ..clearHistory()
        ..remember('кофе')
        ..remember('кино')
        ..remember('кофе');
      expect(search.recentQueries, ['кофе', 'кино']);
    });
  });

  group('Собрать мне вечер (mock)', () {
    var language = AppLanguage.ru;
    final planner = MockEveningPlanner(
      MockCatalog(),
      () => language,
      latency: Duration.zero,
    );

    test('план укладывается в выбранный бюджет', () async {
      for (final budget in [5000, 10000, 15000]) {
        for (final mood in Mood.values) {
          final plan = await planner.plan(EveningRequest(budget: budget, mood: mood));
          expect(plan.totalCost, lessThanOrEqualTo(budget), reason: '$mood, $budget');
          expect(plan.stops, isNotEmpty);
        }
      }
    });

    test('заголовок отражает компанию', () async {
      final plan = await planner.plan(const EveningRequest(company: Company.solo));
      expect(plan.title, contains('для себя'));
    });

    test('сохранённый план переводится на казахский без изменения точек', () async {
      final plan = await planner.plan(const EveningRequest(company: Company.pair));
      language = AppLanguage.kk;
      final translated = await planner.localize(plan);
      language = AppLanguage.ru;
      expect(translated.title, 'Екеуге арналған тыныш кеш');
      expect(translated.stops.map((s) => s.placeId), plan.stops.map((s) => s.placeId));
      expect(translated.totalCost, plan.totalCost);
      expect(translated.stops.first.kindLabel, isNot(plan.stops.first.kindLabel));
    });
  });

  group('Сохранение на устройстве', () {
    test('сценарий переживает JSON без потерь', () async {
      final planner = MockEveningPlanner(
        MockCatalog(),
        () => AppLanguage.ru,
        latency: Duration.zero,
      );
      final plan = await planner.plan(const EveningRequest(budget: 10000));
      final json = jsonDecode(jsonEncode(plan.toJson())) as Map<String, dynamic>;
      final restored = Scenario.fromJson(json);
      expect(restored.title, plan.title);
      expect(restored.totalCost, plan.totalCost);
      expect(restored.legs.length, plan.legs.length);
      expect(restored.request?.budget, 10000);
      expect(restored.stops.first.kind, plan.stops.first.kind);
    });

    test('избранное восстанавливается после перезапуска', () async {
      final storage = MemoryKeyValueStore();
      FavoritesStore(storage: storage, placeIds: const ['a', 'b'])
        ..toggle(FavoriteKind.place, 'a')
        ..toggle(FavoriteKind.event, 'e1');
      await Future<void>.delayed(Duration.zero);

      final reopened = FavoritesStore(storage: storage, placeIds: const ['x']);
      expect(reopened.placeIds, ['b']);
      expect(reopened.eventIds, ['e1']);
    });

    test('язык и город сохраняются, язык устройства — только по умолчанию', () async {
      final storage = MemoryKeyValueStore();
      final first = AppState(storage: storage, language: AppLanguage.kk);
      expect(first.language.value, AppLanguage.kk);
      first
        ..language.value = AppLanguage.ru
        ..city.value = 'Алматы';
      await Future<void>.delayed(Duration.zero);

      final second = AppState(storage: storage, language: AppLanguage.kk);
      expect(second.language.value, AppLanguage.ru);
      expect(second.city.value, 'Алматы');
    });

    test('профиль и история восстанавливаются, сброс возвращает начальные', () async {
      final storage = MemoryKeyValueStore();
      final services = AppServices.mock(latency: Duration.zero, storage: storage);
      services.profile.updateBudget(25000);
      services.search.remember('боулинг');
      services.favorites.toggle(FavoriteKind.place, 'luna_cinema');
      await Future<void>.delayed(Duration.zero);

      final again = AppServices.mock(latency: Duration.zero, storage: storage);
      expect(again.profile.profile.typicalBudget, 25000);
      expect(again.search.recentQueries.first, 'боулинг');
      expect(again.favorites.isFavorite(FavoriteKind.place, 'luna_cinema'), isTrue);

      again.resetData();
      expect(again.profile.profile.typicalBudget, 10000);
      expect(again.favorites.isFavorite(FavoriteKind.place, 'luna_cinema'), isFalse);
    });
  });

  Future<void> pumpApp(WidgetTester tester, AppServices services) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(BuginApp(services: services));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
  }

  String visibleTexts(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
      .take(30)
      .join(' | ');

  testWidgets('приложение запускается и показывает главную', (tester) async {
    await pumpApp(tester, AppServices.mock(latency: Duration.zero));

    final onScreen = visibleTexts(tester);
    expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget, reason: onScreen);
    expect(find.text('Bugin'), findsOneWidget, reason: onScreen);
    expect(find.text('Собрать мне вечер'), findsOneWidget, reason: onScreen);
  });

  testWidgets('казахский язык телефона — главная на казахском', (tester) async {
    await pumpApp(
      tester,
      AppServices.mock(latency: Duration.zero, deviceLanguage: AppLanguage.kk),
    );

    final onScreen = visibleTexts(tester);
    expect(find.text('Маған кеш ұйымдастыр'), findsOneWidget, reason: onScreen);
    expect(find.text('Собрать мне вечер'), findsNothing, reason: onScreen);
    expect(find.text('Басты бет'), findsOneWidget, reason: onScreen);
  });

  testWidgets('смена языка пересобирает приложение', (tester) async {
    final services = AppServices.mock(latency: Duration.zero);
    await pumpApp(tester, services);
    expect(find.text('Главная'), findsOneWidget);

    services.state.language.value = AppLanguage.kk;
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    final onScreen = visibleTexts(tester);
    expect(find.text('Басты бет'), findsOneWidget, reason: onScreen);
    expect(find.text('Главная'), findsNothing, reason: onScreen);
  });
}
