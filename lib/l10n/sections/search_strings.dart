import 'package:bugin/l10n/l10n_section.dart';

/// Тексты AI-поиска, обработки запроса и результатов.
class SearchStrings extends L10nSection {
  const SearchStrings(super.language);

  // ---------- Ввод запроса ----------

  String get newQuery => tr('Новый запрос', 'Жаңа сұрау');
  String get title => tr('Что хочешь сделать?', 'Не істегің келеді?');
  String get inputHint => tr(
        'Например: хочу вечером с девушкой, красиво и недорого',
        'Мысалы: кешке қызбен барғым келеді, әдемі әрі қымбат емес',
      );
  String get writeLikeFriend =>
      tr('Пиши как другу — я разберусь', 'Досыңа жазғандай жаз — мен түсінемін');
  String get find => tr('Найти', 'Табу');
  String get tryThis => tr('Попробуй так', 'Былай жазып көр');
  String get recent => tr('Недавние', 'Соңғы сұраулар');
  String get clearHistory => tr('Очистить', 'Тазалау');

  // ---------- Обработка: понял → ищу → выбираю ----------

  String get cancelSearch => tr('Отменить поиск', 'Іздеуді болдырмау');
  String get yourQuery => tr('Твой запрос', 'Сенің сұрауың');
  String get processingTitle =>
      tr('Подбираю варианты', 'Нұсқаларды іріктеп жатырмын');
  String get processingHint =>
      tr('Обычно это пара секунд', 'Әдетте бұл бірер секунд алады');

  String get stepUnderstood => tr('Понял запрос', 'Сұрауды түсіндім');
  String get stepUnderstanding =>
      tr('Разбираю запрос', 'Сұрауды талдап жатырмын');

  /// «Нашёл 12 вариантов рядом» / «Жақын жерден 12 нұсқа таптым».
  String stepFound(int n) => tr(
        'Нашёл $n ${ruPlural(n, 'вариант', 'варианта', 'вариантов')} рядом',
        'Жақын жерден $n нұсқа таптым',
      );
  String get stepSearching => tr(
        'Ищу подходящие места и события',
        'Қолайлы орындар мен іс-шараларды іздеп жатырмын',
      );
  String get stepRanking => tr(
        'Выбираю лучшее под твой бюджет',
        'Бюджетіңе сай ең жақсысын таңдап жатырмын',
      );

  // ---------- Результаты: «Я понял тебя» ----------

  String get understood => tr('Я понял тебя', 'Сені түсіндім');
  String get inferredHint => tr(
        'Пунктир — это я додумал сам. Нажми на параметр, чтобы изменить.',
        'Пунктирмен белгіленгенін өзім болжадым. Өзгерту үшін параметрді бас.',
      );
  String get inferredParamHint => tr(
        'Это я додумал сам — поправь, если не так',
        'Мұны өзім болжадым — дұрыс болмаса, түзет',
      );
  String get refineTitle => tr('Что уточнить?', 'Нені нақтылаймыз?');
  String get rewriteQuery => tr('Переписать запрос', 'Сұрауды қайта жазу');

  // ---------- Результаты: выдача ----------

  String get foundForYou =>
      tr('Вот что нашёл для тебя', 'Міне, саған тапқандарым');

  String get filterRestaurants => tr('Рестораны', 'Мейрамханалар');
  String get filterCafes => tr('Кафе', 'Кафелер');
  String get filterFun => tr('Развлечения', 'Ойын-сауық');
  String get filterEvents => tr('События', 'Іс-шаралар');

  String get sortTitle => tr('Сортировка', 'Сұрыптау');
  String sortSemantic(String label) =>
      tr('Сортировка: $label', 'Сұрыптау: $label');
  String get sortBest => tr('Лучшее совпадение', 'Ең жақсы сәйкестік');

  /// Короткая подпись сортировки по умолчанию рядом с заголовком.
  String get sortBestShort => tr('Лучшее', 'Ең жақсы');
  String get sortNear => tr('Сначала ближе', 'Алдымен жақындары');
  String get sortCheap => tr('Сначала дешевле', 'Алдымен арзандары');
  String get sortRating => tr('По рейтингу', 'Рейтинг бойынша');

  String get emptyTitle => tr('Ничего не нашлось', 'Ештеңе табылмады');
  String get emptyAllMessage => tr(
        'Попробуй убрать один из параметров или увеличить бюджет',
        'Бір параметрді алып тастап немесе бюджетті көбейтіп көр',
      );
  String get emptyFilterMessage => tr(
        'В этой категории пусто — посмотри все варианты',
        'Бұл санатта ештеңе жоқ — барлық нұсқаларды қара',
      );
  String get changeQuery => tr('Изменить запрос', 'Сұрауды өзгерту');
  String get showAll => tr('Показать все', 'Барлығын көрсету');

  // ---------- «Удиви меня» ----------

  String get surpriseTitle => tr('Не то, что искал?', 'Іздегенің бұл емес пе?');
  String get surpriseSubtitle => tr(
        'Уточни запрос или доверься случаю',
        'Сұрауды нақтыла немесе сәттілікке сен',
      );
  String get surpriseMe => tr('Удиви меня', 'Мені таң қалдыр');
}
