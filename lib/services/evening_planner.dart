import 'package:bugin/models/models.dart';

/// «Собрать мне вечер».
abstract interface class EveningPlanner {
  /// Собирает план строго под параметры (бюджет, компания, настроение).
  Future<Scenario> plan(EveningRequest request);

  /// Варианты замены точки [index] в рамках оставшегося бюджета.
  Future<List<PlanStop>> alternatives(Scenario scenario, int index);

  /// Меняет точку и пересчитывает время и итог.
  Future<Scenario> replaceStop(Scenario scenario, int index, PlanStop stop);

  /// Готовый сценарий для блока «Для тебя сегодня».
  Future<Scenario> featured();

  /// Тот же план на текущем языке приложения — для сохранённых сценариев
  /// после смены языка. Точки, время и цены не меняются.
  Future<Scenario> localize(Scenario scenario);
}
