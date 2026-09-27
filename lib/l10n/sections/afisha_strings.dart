import 'package:bugin/l10n/l10n_section.dart';

/// Тексты афиши.
class AfishaStrings extends L10nSection {
  const AfishaStrings(super.language);

  String get title => tr('Афиша', 'Афиша');
  String get pickDate => tr('Выбери дату', 'Күнді таңда');
  String get featured => tr('Главное на неделе', 'Аптаның ең қызығы');

  /// «5 событий» / «5 іс-шара».
  String eventsCount(int n) =>
      tr('$n ${ruPlural(n, 'событие', 'события', 'событий')}', '$n іс-шара');

  // ---------- Пустой список ----------

  String get emptyTitle => tr('Здесь пока пусто', 'Мұнда әзірге бос');

  String get emptyMessage => tr(
        'На этот день ничего не нашлось — загляни на выходные',
        'Бұл күнге ештеңе табылмады — демалыс күндерін қарап көр',
      );

  String get showWeekend => tr('Показать выходные', 'Демалыс күндерін көрсету');
}
