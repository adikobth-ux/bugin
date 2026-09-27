import 'package:bugin/core/formatters.dart';

enum ParamType {
  occasion('Повод'),
  time('Когда'),
  budget('Бюджет'),
  mood('Настроение'),
  location('Где искать');

  const ParamType(this.label);

  final String label;
}

class ParamOption {
  const ParamOption(this.code, this.label);

  final String code;
  final String label;
}

/// Один распознанный параметр запроса: «Свидание», «Вечером», «до 15 000 ₸».
class IntentParam {
  const IntentParam({
    required this.type,
    required this.code,
    required this.label,
    this.inferred = false,
  });

  /// Параметр из справочника по коду. Для бюджета допускается любое число.
  factory IntentParam.of(ParamType type, String code, {bool inferred = false}) {
    final options = IntentParam.options[type] ?? const <ParamOption>[];
    for (final option in options) {
      if (option.code == code) {
        return IntentParam(
          type: type,
          code: code,
          label: option.label,
          inferred: inferred,
        );
      }
    }
    final amount = int.tryParse(code);
    final label =
        type == ParamType.budget && amount != null ? Fmt.upToTenge(amount) : code;
    return IntentParam(type: type, code: code, label: label, inferred: inferred);
  }

  final ParamType type;
  final String code;
  final String label;

  /// true — параметр не был в запросе, AI додумал его сам.
  final bool inferred;

  /// Бюджет в тенге или null, если «не важен».
  int? get budgetValue => type == ParamType.budget ? int.tryParse(code) : null;

  static const options = <ParamType, List<ParamOption>>{
    ParamType.occasion: [
      ParamOption('date', 'Свидание'),
      ParamOption('friends', 'С друзьями'),
      ParamOption('work', 'Поработать'),
      ParamOption('family', 'С семьёй'),
      ParamOption('solo', 'Для себя'),
    ],
    ParamType.time: [
      ParamOption('morning', 'Утром'),
      ParamOption('day', 'Днём'),
      ParamOption('evening', 'Вечером'),
      ParamOption('night', 'Ночью'),
    ],
    ParamType.budget: [
      ParamOption('5000', 'до 5 000 ₸'),
      ParamOption('10000', 'до 10 000 ₸'),
      ParamOption('15000', 'до 15 000 ₸'),
      ParamOption('25000', 'до 25 000 ₸'),
      ParamOption('any', 'Бюджет не важен'),
    ],
    ParamType.mood: [
      ParamOption('beautiful', 'Красиво и спокойно'),
      ParamOption('calm', 'Спокойно'),
      ParamOption('active', 'Активно'),
      ParamOption('novelty', 'Что-то новое'),
    ],
    ParamType.location: [
      ParamOption('near', 'Рядом'),
      ParamOption('center', 'В центре'),
      ParamOption('any', 'Где угодно'),
    ],
  };
}

/// Результат «понимания» запроса.
class SearchIntent {
  const SearchIntent({required this.query, required this.params});

  final String query;
  final List<IntentParam> params;

  IntentParam? param(ParamType type) {
    for (final p in params) {
      if (p.type == type) {
        return p;
      }
    }
    return null;
  }

  bool get hasInferred => params.any((p) => p.inferred);

  List<ParamType> get missingTypes =>
      ParamType.values.where((t) => param(t) == null).toList();

  /// Заменяет параметр того же типа или добавляет новый.
  SearchIntent withParam(IntentParam value) {
    final next = <IntentParam>[];
    var replaced = false;
    for (final p in params) {
      if (p.type == value.type) {
        next.add(value);
        replaced = true;
      } else {
        next.add(p);
      }
    }
    if (!replaced) {
      next.add(value);
    }
    return SearchIntent(query: query, params: next);
  }

  SearchIntent without(ParamType type) => SearchIntent(
        query: query,
        params: params.where((p) => p.type != type).toList(),
      );
}
