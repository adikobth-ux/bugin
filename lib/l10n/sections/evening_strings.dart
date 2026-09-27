import 'package:bugin/l10n/l10n_section.dart';

/// Тексты «Собрать мне вечер» и плана вечера.
class EveningStrings extends L10nSection {
  const EveningStrings(super.language);

  // ---------- Форма параметров ----------

  String get title => tr('Собрать мне вечер', 'Маған кеш ұйымдастыр');
  String get headline => tr('Какой вечер хочешь?', 'Қандай кеш қалайсың?');
  String get subtitle => tr(
        'Соберу план: места, время и бюджет',
        'Жоспар құрамын: орындар, уақыт және бюджет',
      );
  String get companyQuestion => tr('С кем?', 'Кіммен?');
  String get dayQuestion => tr('Когда?', 'Қашан?');
  String get datePickerTitle => tr('Когда собираемся?', 'Қашан жиналамыз?');
  String get startQuestion => tr('Во сколько начнём?', 'Сағат нешеде бастаймыз?');
  String get budgetQuestion => tr('Бюджет на человека', 'Бір адамға бюджет');
  String get moodQuestion => tr('Настроение', 'Көңіл-күй');
  String get wishes => tr('Пожелания', 'Тілектер');
  String get optional => tr('— необязательно', '— міндетті емес');

  /// Пример в поле пожеланий. «киносыз» понимает планировщик.
  String get wishesHint => tr(
        'Например: без кино, хочу погулять у воды',
        'Мысалы: киносыз, су жағасында серуен',
      );
  String get createPlan => tr('Создать план', 'Жоспар құру');

  // ---------- Сборка плана ----------

  String get building => tr('Собираю план…', 'Жоспар құрып жатырмын…');
  String get buildingHint => tr(
        'Подбираю места под бюджет и время',
        'Бюджет пен уақытқа сай орындарды таңдап жатырмын',
      );

  // ---------- План ----------

  String get yourEvening => tr('Твой вечер', 'Сенің кешің');
  String get edit => tr('Изменить', 'Өзгерту');
  String get budgetAny => tr('Бюджет не важен', 'Бюджет маңызды емес');

  /// «≈ 12 000 ₸ на человека».
  String perPerson(String amount) =>
      tr('$amount на человека', '$amount бір адамға');

  /// «3 точки» / «3 орын».
  String stopsCount(int n) =>
      tr('$n ${ruPlural(n, 'точка', 'точки', 'точек')}', '$n орын');
  String get withinBudget => tr('в рамках бюджета', 'бюджет шегінде');
  String get overBudget => tr('дороже бюджета', 'бюджеттен асады');

  String get saved => tr('Сохранено', 'Сақталды');
  String get update => tr('Обновить', 'Жаңарту');
  String get savedToFavorites =>
      tr('Сценарий сохранён в избранное', 'Сценарий таңдаулыларға сақталды');
  String get open => tr('Открыть', 'Ашу');
  String get routeDemo => tr(
        'маршрут по всем точкам откроется в картах',
        'барлық орындар бойынша бағыт картада ашылады',
      );

  // ---------- Замена точки ----------

  String get replace => tr('Заменить', 'Ауыстыру');
  String replaceLabel(String title) =>
      tr('Заменить: $title', 'Ауыстыру: $title');
  String replaceTitle(String title) =>
      tr('Чем заменить «$title»?', '«$title» орнына не таңдаймыз?');
  String get onlyWithinBudget =>
      tr('Только варианты в рамках бюджета', 'Тек бюджет шегіндегі нұсқалар');
  String get noAlternatives => tr(
        'Других вариантов в рамках бюджета нет — попробуй увеличить бюджет',
        'Бюджет шегінде басқа нұсқа жоқ — бюджетті ұлғайтып көр',
      );
  String replaced(String title) =>
      tr('Заменил на «$title»', 'Ауыстырдым: «$title»');
}
