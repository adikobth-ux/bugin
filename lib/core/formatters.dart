/// Форматирование, которое не зависит от языка: числа, цены, расстояния, время.
///
/// Всё, где есть слова («до», «сегодня», «2 часа»), — в `AppStrings`
/// (`context.l10n.upToTenge(...)`, `context.l10n.relativeDay(...)`).
/// Намеренно без пакета intl: правила отображения собраны в одном месте.
abstract final class Fmt {
  static const nbsp = ' ';

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

  /// 4.8 → «4,8» (в русском и казахском дробная часть — через запятую).
  static String decimal(double value, {int digits = 1}) =>
      value.toStringAsFixed(digits).replaceAll('.', ',');

  static String rating(double value) => decimal(value);

  /// 1.5 → «1,5 км», 0.4 → «400 м». Сокращения одинаковые в обоих языках.
  static String distance(double km) {
    if (km < 1) {
      return '${(km * 1000).round()}${nbsp}м';
    }
    return '${decimal(km)}${nbsp}км';
  }

  // ---------- Время ----------

  /// Минуты от начала суток → «19:00». Значения больше суток переносятся.
  static String hm(int minutesOfDay) {
    final h = (minutesOfDay ~/ 60) % 24;
    final m = minutesOfDay % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  static String time(DateTime d) => hm(d.hour * 60 + d.minute);

  // ---------- Даты ----------

  static int _dayIndex(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;

  /// Разница в календарных днях: a − b.
  static int dayDiff(DateTime a, DateTime b) => _dayIndex(a) - _dayIndex(b);

  static bool isSameDay(DateTime a, DateTime b) => dayDiff(a, b) == 0;
}
