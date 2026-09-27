import 'package:bugin/l10n/app_language.dart';

/// База для всех разделов текстов.
///
/// Каждая строка записана парой «русский — казахский» в одном месте:
/// перевод невозможно забыть, а носителю языка удобно вычитывать оба
/// варианта рядом. Если языков станет больше, разделы легко перенести
/// в ARB-файлы — экраны при этом не изменятся.
abstract class L10nSection {
  const L10nSection(this.language);

  final AppLanguage language;

  bool get isKk => language == AppLanguage.kk;

  /// Строка на текущем языке.
  String tr(String ru, String kk) => language == AppLanguage.kk ? kk : ru;
}

/// Русское склонение после числа: 1 место, 2 места, 5 мест.
/// В казахском существительное после числа не меняется.
String ruPlural(int n, String one, String few, String many) {
  final mod10 = n.abs() % 10;
  final mod100 = n.abs() % 100;
  if (mod10 == 1 && mod100 != 11) {
    return one;
  }
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return few;
  }
  return many;
}

// Казахские окончания после чисел зависят от последнего произносимого слова:
// 3 — «үш» → «үштен», 30 — «отыз» → «отыздан», 0 — «нөл» → «нөлден».
// Для времени «19:00» последнее слово — минуты («нөл»): «19:00-ден».

const _kkUnitsAblative = ['ден', 'ден', 'ден', 'тен', 'тен', 'тен', 'дан', 'ден', 'ден', 'дан'];
const _kkTensAblative = ['ден', 'нан', 'дан', 'дан', 'тан', 'ден', 'тан', 'тен', 'нен', 'нан'];
const _kkUnitsDative = ['ге', 'ге', 'ге', 'ке', 'ке', 'ке', 'ға', 'ге', 'ге', 'ға'];
const _kkTensDative = ['ге', 'ға', 'ға', 'ға', 'қа', 'ге', 'қа', 'ке', 'ге', 'ға'];

/// Исходный падеж после числа: 5 → «тен» (бестен), 30 → «дан» (отыздан).
String kkAblative(int n) => _kkSuffix(n, _kkUnitsAblative, _kkTensAblative, 'ден', 'нан');

/// Дательный падеж после числа: 5 → «ке» (беске), 30 → «ға» (отызға).
String kkDative(int n) => _kkSuffix(n, _kkUnitsDative, _kkTensDative, 'ге', 'ға');

String _kkSuffix(
  int n,
  List<String> units,
  List<String> tens,
  String hundred,
  String thousand,
) {
  final value = n.abs();
  if (value == 0) {
    return units[0];
  }
  if (value % 10 != 0) {
    return units[value % 10];
  }
  if (value % 100 != 0) {
    return tens[(value % 100) ~/ 10];
  }
  // «жүз» — жүзден/жүзге, «мың» — мыңнан/мыңға.
  return value % 1000 == 0 ? thousand : hundred;
}
