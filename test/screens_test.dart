// Обход всех экранов на обоих языках, на узком телефоне и с крупным
// системным шрифтом. Любое переполнение вёрстки или исключение при
// построении экрана роняет тест — так длинные казахские строки не
// сломают интерфейс незаметно.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bugin/app.dart';
import 'package:bugin/data/mock_events.dart';
import 'package:bugin/data/mock_places.dart';
import 'package:bugin/l10n/app_language.dart';
import 'package:bugin/l10n/app_strings.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/navigation/app_routes.dart';
import 'package:bugin/navigation/app_tab.dart';
import 'package:bugin/screens/home/home_screen.dart';
import 'package:bugin/services/app_services.dart';
import 'package:bugin/services/mock/mock_search_service.dart';
import 'package:bugin/widgets/city_button.dart';

const _placeIds = [
  MockPlaces.theGarden,
  MockPlaces.coffeeLab,
  MockPlaces.galaxyBowling,
  MockPlaces.skyLounge,
  MockPlaces.lunaCinema,
  MockPlaces.esilEmbankment,
  MockPlaces.holstStudio,
  MockPlaces.bastauGallery,
];

const _eventIds = [
  MockEvents.neonNights,
  MockEvents.rooftopAcoustic,
  MockEvents.steppeWind,
  MockEvents.artEvening,
  MockEvents.cityOfLight,
  MockEvents.jazz,
  MockEvents.standup,
  MockEvents.seagull,
];

/// Даёт экрану загрузить данные и доиграть анимации (без ожидания «тишины»:
/// у некоторых экранов есть бесконечные анимации загрузки).
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 15; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  const variants = [
    (width: 320.0, height: 640.0, textScale: 1.0),
    (width: 390.0, height: 844.0, textScale: 1.3),
  ];

  for (final language in AppLanguage.values) {
    for (final v in variants) {
      final name = '${language.code}, ${v.width.toInt()} pt, шрифт ×${v.textScale}';

      testWidgets('все экраны без переполнений: $name', (tester) async {
        await tester.binding.setSurfaceSize(Size(v.width, v.height));
        tester.platformDispatcher.textScaleFactorTestValue = v.textScale;
        addTearDown(() {
          tester.binding.setSurfaceSize(null);
          tester.platformDispatcher.clearTextScaleFactorTestValue();
        });

        final services = AppServices.mock(
          latency: Duration.zero,
          deviceLanguage: language,
        );
        final l10n = AppStrings.forLanguage(language);
        await tester.pumpWidget(BuginApp(services: services));
        await _settle(tester);
        expect(find.byType(HomeScreen), findsOneWidget);

        final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);

        Future<void> visit(String route, [Object? arguments]) async {
          navigator.pushNamed(route, arguments: arguments);
          await _settle(tester);
          navigator.pop();
          await _settle(tester);
        }

        /// Нажимает на текст и закрывает открывшийся лист или диалог.
        Future<void> openAndClose(String text) async {
          final finder = find.text(text);
          if (finder.evaluate().isEmpty) {
            return;
          }
          final routeBefore = ModalRoute.of(tester.element(finder.first));
          await tester.ensureVisible(finder.first);
          await tester.pump();
          await tester.tap(finder.first, warnIfMissed: false);
          await _settle(tester);
          if (routeBefore != null && !routeBefore.isCurrent) {
            navigator.pop();
            await _settle(tester);
          }
        }

        // Вкладки и разделы избранного.
        for (final tab in AppTab.values) {
          services.state.tab.value = tab;
          await _settle(tester);
          if (tab == AppTab.favorites) {
            for (final section in FavoritesSection.values) {
              services.state.favoritesSection.value = section;
              await _settle(tester);
            }
          }
        }

        // Листы профиля: язык и сброс данных.
        await openAndClose(l10n.profile.languageRow);
        await openAndClose(l10n.profile.resetData);

        services.state.tab.value = AppTab.home;
        await _settle(tester);

        // Выбор города.
        showCityPicker(tester.element(find.byType(HomeScreen)));
        await _settle(tester);
        navigator.pop();
        await _settle(tester);

        // Поиск и выдача.
        await visit(AppRoutes.search);
        final search = services.search as MockSearchService;
        final query = services.search.suggestions.first;
        final intent = search.parse(query);
        await visit(
          AppRoutes.results,
          ResultsArgs(intent: intent, items: search.rank(intent, DateTime.now())),
        );
        final empty = search.parse('${l10n.label(Occasion.family)} 1000');
        await visit(AppRoutes.results, ResultsArgs(intent: empty, items: const []));

        // Карточки мест и событий, листы брони и билетов.
        for (final id in _placeIds) {
          navigator.pushNamed(
            AppRoutes.place,
            arguments: PlaceArgs(id, reasons: const ['—', '—']),
          );
          await _settle(tester);
          if (id == MockPlaces.theGarden || id == MockPlaces.lunaCinema) {
            await openAndClose(
              id == MockPlaces.theGarden ? l10n.place.book : l10n.place.buyTicket,
            );
          }
          navigator.pop();
          await _settle(tester);
        }
        for (final id in _eventIds) {
          navigator.pushNamed(AppRoutes.event, arguments: id);
          await _settle(tester);
          if (id == MockEvents.neonNights) {
            await openAndClose(l10n.event.buyTicket);
          }
          navigator.pop();
          await _settle(tester);
        }

        // «Собрать мне вечер»: форма, новые планы, сохранённые сценарии.
        await visit(AppRoutes.eveningForm);
        for (final mood in Mood.values) {
          await visit(
            AppRoutes.eveningPlan,
            EveningPlanArgs(
              request: EveningRequest(mood: mood, company: Company.family, budget: null),
            ),
          );
        }
        for (final scenario in services.favorites.scenarios) {
          await visit(AppRoutes.eveningPlan, EveningPlanArgs(scenario: scenario));
        }

        // Обработка запроса сама переходит к выдаче.
        navigator.pushNamed(AppRoutes.processing, arguments: query);
        await _settle(tester);
        await _settle(tester);
        navigator.popUntil((route) => route.isFirst);
        await _settle(tester);

        expect(find.byType(HomeScreen), findsOneWidget);

        // Дожидаемся отложенных таймеров, чтобы тест завершился чисто.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 5));
      });
    }
  }
}
