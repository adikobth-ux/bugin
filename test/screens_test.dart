// Обход всех экранов на обоих языках, на узком телефоне и с крупным
// системным шрифтом. Любое переполнение вёрстки или исключение при
// построении экрана роняет тест — так длинные казахские строки не
// сломают интерфейс незаметно.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// По умолчанию тесты рисуют текст шрифтом, где каждая буква — квадрат
/// шириной в кегль, и строки выходят почти вдвое шире настоящих.
/// Загружаем настоящий шрифт приложения, чтобы ширины были как на телефоне.
Future<void> _loadAppFont() async {
  final loader = FontLoader('Onest');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    loader.addFont(rootBundle.load('assets/fonts/Onest-$weight.ttf'));
  }
  await loader.load();
}

void main() {
  setUpAll(_loadAppFont);

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

        // Ошибки собираем с пометкой экрана и проверяем в конце все сразу.
        final problems = <String>{};
        var where = 'главная';

        /// Даёт экрану загрузить данные и доиграть анимации (без ожидания
        /// «тишины»: у некоторых экранов бесконечные анимации загрузки).
        Future<void> settle() async {
          for (var i = 0; i < 15; i++) {
            await tester.pump(const Duration(milliseconds: 100));
            final error = tester.takeException();
            if (error != null) {
              problems.add('$where: ${error.toString().split('\n').first}');
            }
          }
        }

        await tester.pumpWidget(BuginApp(services: services));
        await settle();
        expect(find.byType(HomeScreen), findsOneWidget);

        final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);

        Future<void> visit(String route, [Object? arguments]) async {
          where = '$route ${arguments ?? ''}';
          navigator.pushNamed(route, arguments: arguments);
          await settle();
          navigator.pop();
          await settle();
        }

        /// Нажимает на текст и закрывает открывшийся лист или диалог.
        Future<void> openAndClose(String text) async {
          final finder = find.text(text);
          if (finder.evaluate().isEmpty) {
            return;
          }
          where = '$where → «$text»';
          final routeBefore = ModalRoute.of(tester.element(finder.first));
          await tester.ensureVisible(finder.first);
          await tester.pump();
          await tester.tap(finder.first, warnIfMissed: false);
          await settle();
          if (routeBefore != null && !routeBefore.isCurrent) {
            navigator.pop();
            await settle();
          }
        }

        // Вкладки и разделы избранного.
        for (final tab in AppTab.values) {
          where = 'вкладка ${tab.name}';
          services.state.tab.value = tab;
          await settle();
          if (tab == AppTab.favorites) {
            for (final section in FavoritesSection.values) {
              where = 'избранное ${section.name}';
              services.state.favoritesSection.value = section;
              await settle();
            }
          }
        }
        where = 'профиль';

        // Листы профиля: язык и сброс данных.
        await openAndClose(l10n.profile.languageRow);
        await openAndClose(l10n.profile.resetData);

        services.state.tab.value = AppTab.home;
        await settle();

        // Выбор города.
        where = 'выбор города';
        showCityPicker(tester.element(find.byType(HomeScreen)));
        await settle();
        navigator.pop();
        await settle();

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
          where = 'место $id';
          navigator.pushNamed(
            AppRoutes.place,
            arguments: PlaceArgs(id, reasons: const ['—', '—']),
          );
          await settle();
          if (id == MockPlaces.theGarden || id == MockPlaces.lunaCinema) {
            await openAndClose(
              id == MockPlaces.theGarden ? l10n.place.book : l10n.place.buyTicket,
            );
          }
          navigator.pop();
          await settle();
        }
        for (final id in _eventIds) {
          where = 'событие $id';
          navigator.pushNamed(AppRoutes.event, arguments: id);
          await settle();
          if (id == MockEvents.neonNights) {
            await openAndClose(l10n.event.buyTicket);
          }
          navigator.pop();
          await settle();
        }

        // «Собрать мне вечер»: форма, новые планы, сохранённые сценарии.
        await visit(AppRoutes.eveningForm);
        for (final mood in Mood.values) {
          where = 'план ${mood.name}';
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
        where = 'обработка запроса';
        navigator.pushNamed(AppRoutes.processing, arguments: query);
        await settle();
        await settle();
        navigator.popUntil((route) => route.isFirst);
        await settle();

        expect(find.byType(HomeScreen), findsOneWidget);
        expect(problems, isEmpty, reason: problems.join('\n'));

        // Дожидаемся отложенных таймеров, чтобы тест завершился чисто.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 5));
      });
    }
  }
}
