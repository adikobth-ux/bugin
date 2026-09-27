/// Подписи типов и значений — в `AppStrings.label` и `AppStrings.paramLabel`.
enum ParamType { occasion, time, budget, mood, location }

/// Один распознанный параметр запроса: код значения + признак «додуман».
/// Текст («Свидание», «Вечером», «до 15 000 ₸») строится на нужном языке в UI.
class IntentParam {
  const IntentParam({
    required this.type,
    required this.code,
    this.inferred = false,
  });

  /// Параметр по коду. Для бюджета код — сумма в тенге или `any`.
  factory IntentParam.of(ParamType type, String code, {bool inferred = false}) =>
      IntentParam(type: type, code: code, inferred: inferred);

  final ParamType type;
  final String code;

  /// true — параметра не было в запросе, AI додумал его сам.
  final bool inferred;

  /// Бюджет в тенге или null, если «не важен».
  int? get budgetValue => type == ParamType.budget ? int.tryParse(code) : null;

  /// Варианты для выбора в карточке «Я понял тебя».
  static const options = <ParamType, List<String>>{
    ParamType.occasion: ['date', 'friends', 'work', 'family', 'solo'],
    ParamType.time: ['morning', 'day', 'evening', 'night'],
    ParamType.budget: ['5000', '10000', '15000', '25000', 'any'],
    ParamType.mood: ['beautiful', 'calm', 'active', 'novelty'],
    ParamType.location: ['near', 'center', 'any'],
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
