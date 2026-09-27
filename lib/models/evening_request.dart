// Подписи компаний, дней и настроений, итоговая строка параметров
// и название плана — в `AppStrings` (label, requestSummary, planTitle).

enum Company {
  solo,
  pair,
  friends,
  family;

  static Company? tryParse(String? name) => _byName(Company.values, name);
}

enum PlanDay {
  today,
  tomorrow,
  weekend,
  date;

  static PlanDay? tryParse(String? name) => _byName(PlanDay.values, name);
}

enum Mood {
  calm,
  active,
  novelty,
  culture;

  static Mood? tryParse(String? name) => _byName(Mood.values, name);
}

T? _byName<T extends Enum>(List<T> values, String? name) {
  for (final value in values) {
    if (value.name == name) {
      return value;
    }
  }
  return null;
}

/// Параметры «Собрать мне вечер».
class EveningRequest {
  const EveningRequest({
    this.company = Company.pair,
    this.day = PlanDay.today,
    this.date,
    this.startMinutes = 19 * 60,
    this.budget = 15000,
    this.mood = Mood.calm,
    this.wishes = '',
  });

  factory EveningRequest.fromJson(Map<String, dynamic> json) => EveningRequest(
        company: Company.tryParse(json['company'] as String?) ?? Company.pair,
        day: PlanDay.tryParse(json['day'] as String?) ?? PlanDay.today,
        date: DateTime.tryParse(json['date'] as String? ?? ''),
        startMinutes: json['startMinutes'] as int? ?? 19 * 60,
        budget: json['budget'] as int?,
        mood: Mood.tryParse(json['mood'] as String?) ?? Mood.calm,
        wishes: json['wishes'] as String? ?? '',
      );

  final Company company;
  final PlanDay day;

  /// Конкретная дата, если выбран [PlanDay.date].
  final DateTime? date;
  final int startMinutes;

  /// Бюджет на человека. `null` — не важен.
  final int? budget;
  final Mood mood;
  final String wishes;

  static const startOptions = [18 * 60, 19 * 60, 20 * 60, 21 * 60];
  static const budgetOptions = <int?>[5000, 10000, 15000, null];

  Map<String, dynamic> toJson() => {
        'company': company.name,
        'day': day.name,
        'date': date?.toIso8601String(),
        'startMinutes': startMinutes,
        'budget': budget,
        'mood': mood.name,
        'wishes': wishes,
      };

  EveningRequest copyWith({
    Company? company,
    PlanDay? day,
    DateTime? date,
    int? startMinutes,
    int? budget,
    bool anyBudget = false,
    Mood? mood,
    String? wishes,
  }) {
    return EveningRequest(
      company: company ?? this.company,
      day: day ?? this.day,
      date: date ?? this.date,
      startMinutes: startMinutes ?? this.startMinutes,
      budget: anyBudget ? null : (budget ?? this.budget),
      mood: mood ?? this.mood,
      wishes: wishes ?? this.wishes,
    );
  }
}
