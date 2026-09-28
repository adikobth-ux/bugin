import 'package:bugin/models/models.dart';
import 'package:bugin/services/api/api_client.dart';
import 'package:bugin/services/evening_planner.dart';

/// «Собрать мне вечер» на сервере: `/v1/evening/…`. Правила те же,
/// что в `MockEveningPlanner`; тексты плана — на языке из `Accept-Language`.
class ApiEveningPlanner implements EveningPlanner {
  ApiEveningPlanner(this._api);

  final ApiClient _api;

  @override
  Future<Scenario> plan(EveningRequest request) async =>
      _scenario(await _api.post('/v1/evening/plan', request.toJson()));

  @override
  Future<List<PlanStop>> alternatives(Scenario scenario, int index) async =>
      jsonList(
        await _api.post('/v1/evening/alternatives', {
          'scenario': scenario.toJson(),
          'index': index,
        }),
      ).map(PlanStop.fromJson).toList();

  @override
  Future<Scenario> replaceStop(Scenario scenario, int index, PlanStop stop) async =>
      _scenario(
        await _api.post('/v1/evening/replace', {
          'scenario': scenario.toJson(),
          'index': index,
          'stop': stop.toJson(),
        }),
      );

  @override
  Future<Scenario> featured() async =>
      _scenario(await _api.get('/v1/evening/featured'));

  /// Сервер переводит план на язык запроса — текущий язык приложения.
  @override
  Future<Scenario> localize(Scenario scenario) async => _scenario(
        await _api.post('/v1/evening/localize', {'scenario': scenario.toJson()}),
      );

  static Scenario _scenario(Object? json) => Scenario.fromJson(jsonObject(json));
}
