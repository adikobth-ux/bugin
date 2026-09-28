import 'package:bugin/core/formatters.dart';
import 'package:bugin/l10n/l10n_section.dart';

/// Тексты карточки события.
class EventStrings extends L10nSection {
  const EventStrings(super.language);

  // ---------- Шапка и «Поделиться» ----------

  String get share => tr('Поделиться', 'Бөлісу');

  /// Текст, который копируется в буфер при «Поделиться».
  String shareText(String title, String when, String venue) => tr(
        '$title, $when, $venue — нашёл в Bugin',
        '$title, $when, $venue — Bugin-де таптым',
      );

  String get copied => tr(
        'Скопировано — можно отправить друзьям',
        'Көшірілді — достарыңа жіберуге болады',
      );

  // ---------- Нижняя панель ----------

  /// Цена рядом с кнопкой: «от 12 000 ₸». В казахском — только цена, а «от»
  /// передаёт подпись под ней («ең арзан билет»): «12 000 ₸-ден бастап»
  /// рядом с кнопкой не помещается.
  String priceFrom(int price) =>
      tr('от${Fmt.nbsp}${Fmt.tenge(price)}', Fmt.tenge(price));

  String get buyTicket => tr('Купить билет', 'Билет алу');

  // ---------- Дата и место ----------

  String get anyTime =>
      tr('Можно прийти в любое время', 'Кез келген уақытта келуге болады');

  /// «около 2 часа» / «шамамен 2 сағат».
  String approxDuration(String duration) =>
      tr('около $duration', 'шамамен $duration');

  String get addToCalendar => tr('Добавить в календарь', 'Күнтізбеге қосу');

  /// Демо-сообщение (без префикса «Демо:»).
  String get calendarDemo => tr(
        'событие добавится в календарь телефона',
        'іс-шара телефон күнтізбесіне қосылады',
      );

  /// Демо-сообщение (без префикса «Демо:»).
  String routeDemo(String venue) => tr(
        'маршрут до «$venue» откроется в картах',
        '«$venue» бағыты картада ашылады',
      );

  // ---------- Билеты и возраст ----------

  /// «3 категории билетов» / «3 билет санаты».
  String ticketCategories(int n) => tr(
        '$n ${ruPlural(n, 'категория', 'категории', 'категорий')} билетов',
        '$n билет санаты',
      );

  String get noAgeLimit => tr('Без ограничений по возрасту', 'Жас шектеуі жоқ');

  // ---------- Разделы карточки ----------

  String get reasonsTitle => tr('Почему тебе понравится', 'Саған неге ұнайды');
  String get about => tr('О событии', 'Іс-шара туралы');
  String get similar => tr('Похожие события', 'Ұқсас іс-шаралар');

  // ---------- Билеты ----------

  String get ticketsSoon =>
      tr('Билеты скоро появятся', 'Билеттер жақында сатылымға шығады');
}
