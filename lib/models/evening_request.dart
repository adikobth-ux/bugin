import 'package:bugin/core/formatters.dart';

enum Company {
  solo('Один', 'для себя'),
  pair('Вдвоём', 'вдвоём'),
  friends('С друзьями', 'с друзьями'),
  family('С семьёй', 'с семьёй');

  const Company(this.label, this.titleSuffix);

  final String label;
  final String titleSuffix;
}

enum PlanDay {
  today('Сегодня', 'сегодня'),
  tomorrow('Завтра', 'завтра'),
  weekend('Выходные', 'в выходные'),
  date('Выбрать дату', 'в выбранный день');

  const PlanDay(this.label, this.inline);

  final String label;
  final String inline;
}

enum Mood {
  calm('Спокойно', 'Спокойный'),
  active('Активно', 'Активный'),
  novelty('Что-то новое', 'Необычный'),
  culture('Культурно', 'Культурный');

  const Mood(this.label, this.adjective);

  final String label;
  final String adjective;
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

  static String budgetLabel(int? value) =>
      value == null ? 'Неважно' : Fmt.upToTenge(value);

  String get dayText {
    if (day == PlanDay.date && date != null) {
      return Fmt.relativeDay(date!).toLowerCase();
    }
    return day.inline;
  }

  /// «Вдвоём · сегодня с 19:00 · до 15 000 ₸ · спокойно».
  String get summary {
    final budgetText = budget == null ? 'бюджет не важен' : Fmt.upToTenge(budget!);
    return '${company.label} · $dayText с ${Fmt.hm(startMinutes)} · '
        '$budgetText · ${mood.label.toLowerCase()}';
  }

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
