import 'package:flutter/material.dart';

import 'package:bugin/models/models.dart';
import 'package:bugin/navigation/app_routes.dart';
import 'package:bugin/screens/evening/evening_form_screen.dart';
import 'package:bugin/screens/evening/evening_plan_screen.dart';
import 'package:bugin/screens/event/event_screen.dart';
import 'package:bugin/screens/place/place_screen.dart';
import 'package:bugin/screens/search/ai_search_screen.dart';
import 'package:bugin/screens/search/processing_screen.dart';
import 'package:bugin/screens/search/results_screen.dart';
import 'package:bugin/screens/shell/main_shell.dart';

/// Таблица маршрутов. Аргументы типизированы в [AppRoutes].
abstract final class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case AppRoutes.shell:
        return _page(settings, (_) => const MainShell());
      case AppRoutes.search:
        return _page(
          settings,
          (_) => AiSearchScreen(initialQuery: args is String ? args : ''),
          fullscreenDialog: true,
        );
      case AppRoutes.processing:
        return _page(settings, (_) => ProcessingScreen(query: args as String));
      case AppRoutes.results:
        return _page(settings, (_) => ResultsScreen(args: args as ResultsArgs));
      case AppRoutes.place:
        return _page(
          settings,
          (_) => PlaceScreen(
            placeId: (args as PlaceArgs).placeId,
            reasons: args.reasons,
          ),
        );
      case AppRoutes.event:
        return _page(settings, (_) => EventScreen(eventId: args as String));
      case AppRoutes.eveningForm:
        return _page(
          settings,
          (_) => EveningFormScreen(initial: args is EveningRequest ? args : null),
        );
      case AppRoutes.eveningPlan:
        return _page(
          settings,
          (_) => EveningPlanScreen(
            request: (args as EveningPlanArgs).request,
            scenario: args.scenario,
          ),
        );
    }
    return null;
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) =>
      _page(settings, (_) => const MainShell());

  static MaterialPageRoute<void> _page(
    RouteSettings settings,
    WidgetBuilder builder, {
    bool fullscreenDialog = false,
  }) =>
      MaterialPageRoute<void>(
        builder: builder,
        settings: settings,
        fullscreenDialog: fullscreenDialog,
      );
}
