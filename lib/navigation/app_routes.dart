import 'package:bugin/models/models.dart';

/// Имена маршрутов. Пригодятся для диплинков, когда появится backend.
abstract final class AppRoutes {
  static const shell = '/';
  static const search = '/search';
  static const processing = '/search/processing';
  static const results = '/search/results';
  static const place = '/place';
  static const event = '/event';
  static const eveningForm = '/evening';
  static const eveningPlan = '/evening/plan';
}

class ResultsArgs {
  const ResultsArgs({required this.intent, required this.items});

  final SearchIntent intent;
  final List<Recommendation> items;
}

class PlaceArgs {
  const PlaceArgs(this.placeId, {this.reasons = const []});

  final String placeId;

  /// Причины из выдачи — показываются блоком «Почему тебе подойдёт».
  final List<String> reasons;
}

class EveningPlanArgs {
  const EveningPlanArgs({this.request, this.scenario})
      : assert(request != null || scenario != null);

  /// Собрать новый план по параметрам.
  final EveningRequest? request;

  /// Открыть готовый сценарий.
  final Scenario? scenario;
}
