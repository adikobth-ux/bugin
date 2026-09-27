import 'package:flutter/material.dart';

import 'package:bugin/models/models.dart';
import 'package:bugin/navigation/app_routes.dart';
import 'package:bugin/navigation/app_tab.dart';
import 'package:bugin/services/app_services.dart';

/// Типизированные переходы. Экраны не собирают маршруты вручную.
abstract final class AppNavigator {
  static Future<void> openSearch(BuildContext context, {String query = ''}) =>
      Navigator.of(context).pushNamed(AppRoutes.search, arguments: query);

  /// Сразу к обработке запроса (быстрые чипы, повтор из истории).
  static Future<void> startSearch(BuildContext context, String query) =>
      Navigator.of(context).pushNamed(AppRoutes.processing, arguments: query);

  static Future<void> openPlace(
    BuildContext context,
    String placeId, {
    List<String> reasons = const [],
  }) =>
      Navigator.of(context).pushNamed(
        AppRoutes.place,
        arguments: PlaceArgs(placeId, reasons: reasons),
      );

  static Future<void> openEvent(BuildContext context, String eventId) =>
      Navigator.of(context).pushNamed(AppRoutes.event, arguments: eventId);

  static Future<void> openRecommendation(
    BuildContext context,
    Recommendation item,
  ) {
    final place = item.place;
    if (place != null) {
      return openPlace(context, place.id, reasons: item.details);
    }
    return openEvent(context, item.id);
  }

  static Future<void> openEveningForm(
    BuildContext context, {
    EveningRequest? initial,
  }) =>
      Navigator.of(context).pushNamed(AppRoutes.eveningForm, arguments: initial);

  static Future<void> openPlan(
    BuildContext context, {
    EveningRequest? request,
    Scenario? scenario,
  }) =>
      Navigator.of(context).pushNamed(
        AppRoutes.eveningPlan,
        arguments: EveningPlanArgs(request: request, scenario: scenario),
      );

  /// Переключает вкладку и закрывает всё, что открыто поверх оболочки.
  static void goToTab(
    BuildContext context,
    AppTab tab, {
    FavoritesSection? section,
  }) {
    final state = AppScope.of(context).state;
    if (section != null) {
      state.favoritesSection.value = section;
    }
    state.tab.value = tab;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
