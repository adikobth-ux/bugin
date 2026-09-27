import 'package:bugin/l10n/l10n_section.dart';

/// Тексты избранного.
class FavoritesStrings extends L10nSection {
  const FavoritesStrings(super.language);

  String get title => tr('Избранное', 'Таңдаулылар');

  // ---------- Удаление ----------

  /// Место или событие: «„Кафе“ убрано из избранного».
  String removed(String name) => tr(
        '«$name» убрано из избранного',
        '«$name» таңдаулылардан алып тасталды',
      );

  /// Сценарий: «„Вечер у воды“ убран из избранного».
  String scenarioRemoved(String title) => tr(
        '«$title» убран из избранного',
        '«$title» таңдаулылардан алып тасталды',
      );

  // ---------- Пустые разделы ----------

  String get noPlaces => tr('Пока нет мест', 'Әзірге орын жоқ');
  String get noPlacesMessage => tr(
        'Нажимай на сердечко на карточках — места появятся здесь',
        'Карточкалардағы жүрекшені бас — орындар осында пайда болады',
      );
  String get findPlace => tr('Найти место', 'Орын табу');

  String get noEvents => tr('Пока нет событий', 'Әзірге іс-шара жоқ');
  String get noEventsMessage => tr(
        'Сохраняй концерты и выставки из афиши, чтобы не потерять',
        'Жоғалтып алмау үшін афишадағы концерттер мен көрмелерді сақта',
      );
  String get openAfisha => tr('Открыть афишу', 'Афишаны ашу');

  String get noScenarios => tr('Пока нет сценариев', 'Әзірге сценарий жоқ');
  String get noScenariosMessage => tr(
        'Собери вечер и сохрани план, чтобы вернуться к нему',
        'Кеш ұйымдастырып, жоспарды сақта — кейін оған қайта ораласың',
      );
  String get planEvening => tr('Собрать вечер', 'Кеш ұйымдастыру');

  // ---------- Карточка сценария ----------

  /// «3 точки» / «3 орын».
  String stopsCount(int n) =>
      tr('$n ${ruPlural(n, 'точка', 'точки', 'точек')}', '$n орын');
}
