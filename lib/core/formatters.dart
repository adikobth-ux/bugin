/// Форматирование чисел, цен, расстояний и дат по русской локали.
///
/// Намеренно без пакета intl: прототип не тянет лишних зависимостей,
/// а правила отображения собраны в одном месте.
abstract final class Fmt {
  static const nbsp = ' ';

  static const _weekdaysShort = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  static const _weekdaysFull = [
    'понедельник',
    'вторник',
    'среда',
    'четверг',
    'пятница',
    'суббота',
    'воскресенье',
  ];
  static const _monthsShort = [
    'янв',
    'фев',
    'мар',
    'апр',
    'мая',
    'июн',
    'июл',
    'авг',
    'сен',
    'окт',
    'ноя',
    'дек',
  ];
  static const _monthsGenitive = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];

  // ---------- Числа и деньги ----------

  /// 12000 → «12 000» (неразрывный пробел).
  static String thousands(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final fromEnd = digits.length - i;
      buffer.write(digits[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) {
        buffer.write(nbsp);
      }
    }
    return value < 0 ? '-$buffer' : buffer.toString();
  }

  static String tenge(int value) => '${thousands(value)}$nbsp₸';
  static String approxTenge(int value) => '≈$nbsp${tenge(value)}';
  static String fromTenge(int value) => 'от$nbsp${tenge(value)}';
  static String upToTenge(int value) => 'до$nbsp${tenge(value)}';

  /// Средний чек: 0 → «бесплатно».
  static String averageCheck(int value) =>
      value == 0 ? 'бесплатно' : approxTenge(value);

  /// 4.8 → «4,8».
  static String decimal(double value, {int digits = 1}) =>
      value.toStringAsFixed(digits).replaceAll('.', ',');

  static String rating(double value) => decimal(value);

  /// 1.5 → «1,5 км», 0.4 → «400 м».
  static String distance(double km) {
    if (km < 1) {
      return '${(km * 1000).round()}${nbsp}м';
    }
    return '${decimal(km)}${nbsp}км';
  }

  /// 1540 → «1,5 тыс.», 892 → «892».
  static String compactCount(int value) {
    if (value < 1000) {
      return value.toString();
    }
    final t = value / 1000;
    final text = t >= 10 ? t.round().toString() : decimal(t);
    return '$text${nbsp}тыс.';
  }

  /// Склонение: 1 место, 2 места, 5 мест.
  static String plural(int n, String one, String few, String many) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) {
      return one;
    }
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return few;
    }
    return many;
  }

  // ---------- Время ----------

  /// Минуты от начала суток → «19:00». Значения больше суток переносятся.
  static String hm(int minutesOfDay) {
    final h = (minutesOfDay ~/ 60) % 24;
    final m = minutesOfDay % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  static String time(DateTime d) => hm(d.hour * 60 + d.minute);

  /// 45 → «45 минут», 120 → «2 часа», 150 → «2,5 часа».
  static String duration(int minutes) {
    if (minutes < 60) {
      return '$minutes ${plural(minutes, 'минута', 'минуты', 'минут')}';
    }
    if (minutes % 60 == 0) {
      final h = minutes ~/ 60;
      return '$h ${plural(h, 'час', 'часа', 'часов')}';
    }
    return '${decimal(minutes / 60)} часа';
  }

  /// Коротко: 240 → «4 ч», 150 → «2,5 ч», 45 → «45 мин».
  static String durationShort(int minutes) {
    if (minutes < 60) {
      return '$minutes${nbsp}мин';
    }
    if (minutes % 60 == 0) {
      return '${minutes ~/ 60}${nbsp}ч';
    }
    return '${decimal(minutes / 60)}${nbsp}ч';
  }

  // ---------- Даты ----------

  static int _dayIndex(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;

  /// Разница в календарных днях: a − b.
  static int dayDiff(DateTime a, DateTime b) => _dayIndex(a) - _dayIndex(b);

  static bool isSameDay(DateTime a, DateTime b) => dayDiff(a, b) == 0;

  /// «Сегодня», «Завтра», «Сб, 3 окт».
  static String relativeDay(DateTime d, {DateTime? now}) {
    final diff = dayDiff(d, now ?? DateTime.now());
    if (diff == 0) {
      return 'Сегодня';
    }
    if (diff == 1) {
      return 'Завтра';
    }
    return '${_weekdaysShort[d.weekday - 1]}, ${d.day} ${_monthsShort[d.month - 1]}';
  }

  /// «Сегодня · 20:00», «Сб, 3 окт · 20:00».
  static String eventWhen(DateTime d, {DateTime? now}) =>
      '${relativeDay(d, now: now)} · ${time(d)}';

  /// «Суббота, 3 октября».
  static String longDate(DateTime d) {
    final weekday = _weekdaysFull[d.weekday - 1];
    final capitalized = weekday[0].toUpperCase() + weekday.substring(1);
    return '$capitalized, ${d.day} ${_monthsGenitive[d.month - 1]}';
  }

  /// «Сегодня», «Завтра», «Через 6 дней».
  static String inDays(DateTime d, {DateTime? now}) {
    final diff = dayDiff(d, now ?? DateTime.now());
    if (diff <= 0) {
      return 'Сегодня';
    }
    if (diff == 1) {
      return 'Завтра';
    }
    return 'Через $diff ${plural(diff, 'день', 'дня', 'дней')}';
  }

  /// «сегодня», «вчера», «3 дня назад», «2 недели назад».
  static String ago(DateTime d, {DateTime? now}) {
    final diff = dayDiff(now ?? DateTime.now(), d);
    if (diff <= 0) {
      return 'сегодня';
    }
    if (diff == 1) {
      return 'вчера';
    }
    if (diff < 7) {
      return '$diff ${plural(diff, 'день', 'дня', 'дней')} назад';
    }
    if (diff < 30) {
      final weeks = diff ~/ 7;
      return '$weeks ${plural(weeks, 'неделю', 'недели', 'недель')} назад';
    }
    final months = diff ~/ 30;
    return '$months ${plural(months, 'месяц', 'месяца', 'месяцев')} назад';
  }
}
