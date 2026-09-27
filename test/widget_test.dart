import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bugin/app.dart';
import 'package:bugin/core/formatters.dart';
import 'package:bugin/data/mock_events.dart';
import 'package:bugin/data/mock_places.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/screens/home/home_screen.dart';
import 'package:bugin/services/app_services.dart';
import 'package:bugin/services/mock/mock_evening_planner.dart';
import 'package:bugin/services/mock/mock_search_service.dart';

void main() {
  group('Форматирование', () {
    test('цены и расстояния по русской локали', () {
      expect(Fmt.tenge(6000), '6 000 ₸');
      expect(Fmt.approxTenge(12000), '≈ 12 000 ₸');
      expect(Fmt.distance(1.5), '1,5 км');
      expect(Fmt.compactCount(1540), '1,5 тыс.');
      expect(Fmt.plural(21, 'место', 'места', 'мест'), 'место');
      expect(Fmt.plural(3, 'место', 'места', 'мест'), 'места');
      expect(Fmt.plural(11, 'место', 'места', 'мест'), 'мест');
    });
  });

  group('AI-поиск (mock)', () {
    final places = MockPlaces.build();
    final events = MockEvents.build();
    final search = MockSearchService(
      places: places,
      events: events,
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

    test('время «19:00» не путается с бюджетом', () {
      final intent = search.parse('кафе в 19:00 до 10 000 тенге');
      expect(intent.param(ParamType.budget)?.budgetValue, 10000);
    });

    test('выдача не выходит за бюджет', () {
      final intent = search.parse('свидание до 5000');
      final items = search.rank(intent, DateTime.now());
      expect(items, isNotEmpty);
      expect(items.every((item) => item.price <= 5000), isTrue);
    });
  });

  group('Собрать мне вечер (mock)', () {
    final planner = MockEveningPlanner(MockPlaces.build(), latency: Duration.zero);

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
  });

  testWidgets('приложение запускается и показывает главную', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(BuginApp(services: AppServices.mock(latency: Duration.zero)));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // Что реально на экране — попадёт в сообщение, если проверка не пройдёт.
    final onScreen = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
        .take(30)
        .join(' | ');
    final everything = tester
        .widgetList<Text>(find.byType(Text, skipOffstage: false))
        .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
        .take(30)
        .join(' | ');

    expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget, reason: everything);
    expect(find.text('Bugin'), findsOneWidget, reason: 'на экране: $onScreen\nвсе: $everything');
    expect(find.text('Собрать мне вечер'), findsOneWidget, reason: onScreen);
  });
}
