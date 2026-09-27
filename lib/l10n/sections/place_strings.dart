import 'package:bugin/core/formatters.dart';
import 'package:bugin/l10n/l10n_section.dart';

/// Тексты карточки места.
class PlaceStrings extends L10nSection {
  const PlaceStrings(super.language);

  // ---------- Шапка ----------

  String get share => tr('Поделиться', 'Бөлісу');

  /// Цена в шапке для бесплатного места.
  String get free => tr('бесплатно', 'тегін');

  /// «≈ 5 000 ₸ / чел.» / «≈ 5 000 ₸ / адам».
  String perPerson(int averageCheck) => tr(
        '${Fmt.approxTenge(averageCheck)} / чел.',
        '${Fmt.approxTenge(averageCheck)} / адам',
      );

  String get reasonsTitle => tr('Почему тебе подойдёт', 'Саған неге сай келеді');

  // ---------- Поделиться, звонок, маршрут ----------

  /// Текст, который копируется в буфер при «Поделиться».
  String shareText(String name, String address) => tr(
        '$name, $address — нашёл в Bugin',
        '$name, $address — Bugin-де таптым',
      );

  String get copied => tr(
        'Скопировано — можно отправить другу',
        'Көшірілді — досыңа жіберуге болады',
      );

  String get call => tr('Позвонить', 'Қоңырау шалу');

  /// Демо-сообщение (без префикса «Демо:»).
  String callDemo(String phone) => tr(
        'звонок на $phone подключим вместе с телефонией',
        '$phone нөміріне қоңырауды телефониямен бірге қосамыз',
      );

  /// Демо-сообщение (без префикса «Демо:»).
  String routeDemo(String name) => tr(
        'маршрут до «$name» откроется в картах',
        '«$name» бағыты картада ашылады',
      );

  // ---------- Часы работы и адрес ----------

  String get open => tr('Открыто', 'Ашық');
  String get closed => tr('Закрыто', 'Жабық');
  String get aroundTheClock => tr('круглосуточно', 'тәулік бойы');

  /// «откроется в 10:00» / «10:00-де ашылады».
  String opensAt(int minutesOfDay) => tr(
        'откроется в ${Fmt.hm(minutesOfDay)}',
        '${Fmt.hm(minutesOfDay)}-${_kkLocative(minutesOfDay % 60)} ашылады',
      );

  String get noDaysOff => tr('Без выходных', 'Демалыссыз');

  /// «Ежедневно 08:00–23:00» / «Күн сайын 08:00–23:00».
  String daily(String hours) => tr('Ежедневно $hours', 'Күн сайын $hours');

  /// «15 мин на такси» / «таксимен 15 мин».
  String byTaxi(int minutes) =>
      tr('$minutes мин на такси', 'таксимен $minutes мин');

  // ---------- Разделы карточки ----------

  String get amenities => tr('Удобства', 'Ыңғайлылықтар');
  String get about => tr('О месте', 'Орын туралы');
  String get reviews => tr('Отзывы', 'Пікірлер');
  String get gallery => tr('Галерея', 'Галерея');

  /// Ссылка раздела: «Все 1 540» / «Барлығы 1 540».
  String allCount(String count) => tr('Все $count', 'Барлығы $count');

  /// «4,8 из 5 · 1 540 оценок» / «5 балдан 4,8 · 1 540 баға».
  String reviewsSummary(double rating, int count) => tr(
        '${Fmt.rating(rating)} из 5 · ${Fmt.thousands(count)} оценок',
        '5 балдан ${Fmt.rating(rating)} · ${Fmt.thousands(count)} баға',
      );

  /// Подпись фото для скринридера.
  String photoLabel(int number, int total) =>
      tr('Фото $number из $total', 'Фото $number, барлығы $total');

  // ---------- Время и бронь ----------

  /// «Сегодня, 19:00» / «Бүгін, 19:00».
  String todayAt(String time) => tr('Сегодня, $time', 'Бүгін, $time');

  /// «Завтра, 11:00» / «Ертең, 11:00».
  String tomorrowAt(String time) => tr('Завтра, $time', 'Ертең, $time');

  String get noSlotsToday => tr(
        'На сегодня свободного времени нет — попробуй завтра',
        'Бүгінге бос уақыт жоқ — ертеңге байқап көр',
      );

  String get pickSession => tr('Выбери сеанс', 'Сеансты таңда');
  String get pickTime => tr('Выбери время', 'Уақытты таңда');
  String get sessionToday => tr('Сеанс сегодня', 'Бүгінгі сеанс');

  /// Подпись кнопки времени для скринридера: «Сегодня: 19:00. Изменить».
  String slotSemantics(String title, String value) =>
      tr('$title: $value. Изменить', '$title: $value. Өзгерту');

  String get buyTicket => tr('Купить билет', 'Билет сатып алу');
  String get book => tr('Забронировать', 'Брондау');

  String ticketsTitle(String name) => tr('Билеты · $name', 'Билеттер · $name');
  String bookingTitle(String name) => tr('Бронь · $name', 'Бронь · $name');

  String paidDemo(String slot) => tr(
        'Готово! $slot — это демо, реальной оплаты нет',
        'Дайын! $slot — бұл демо, нақты төлем жоқ',
      );

  String bookedDemo(String slot) => tr(
        'Готово! $slot — это демо, реальной брони нет',
        'Дайын! $slot — бұл демо, нақты бронь жоқ',
      );

  // ---------- Подтверждение брони ----------

  String get sessionLabel => tr('Сеанс', 'Сеанс');
  String get timeLabel => tr('Время', 'Уақыт');

  /// «2 гостя» / «2 қонақ».
  String guests(int n) =>
      tr('$n ${ruPlural(n, 'гость', 'гостя', 'гостей')}', '$n қонақ');

  String get ticketCount => tr('Количество билетов', 'Билет саны');
  String get partySize => tr('Сколько вас будет', 'Неше адам боласыңдар');
  String get less => tr('Меньше', 'Азайту');
  String get more => tr('Больше', 'Көбейту');

  /// «Итого: 24 000 ₸» / «Жиыны: 24 000 ₸».
  String total(int amount) =>
      tr('Итого: ${Fmt.tenge(amount)}', 'Жиыны: ${Fmt.tenge(amount)}');

  /// «Средний счёт на всех: ≈ 24 000 ₸».
  String averageTotal(int amount) => tr(
        'Средний счёт на всех: ${Fmt.approxTenge(amount)}',
        'Бәріне орташа шот: ${Fmt.approxTenge(amount)}',
      );

  String get prototypeNote => tr(
        'Это прототип: подтверждение ничего не бронирует и не списывает.',
        'Бұл прототип: растау ештеңені брондамайды, ақша да алмайды.',
      );

  String get goToPayment => tr('Перейти к оплате', 'Төлемге өту');
  String get confirmBooking => tr('Подтвердить бронь', 'Броньды растау');
}

/// Местный падеж после числа — из исходного: 0 → «де» (нөлде),
/// 30 → «да» (отызда), 10 → «да» (онда), 15 → «те» (бесте).
String _kkLocative(int n) => switch (kkAblative(n)) {
      'нан' => 'да',
      'нен' => 'де',
      final ablative => ablative.substring(0, 2),
    };
