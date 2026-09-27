import 'package:bugin/l10n/l10n_section.dart';

/// Тексты главной.
class HomeStrings extends L10nSection {
  const HomeStrings(super.language);

  // ---------- Приветствие ----------

  String greeting(String name) => tr('Привет, $name!', 'Сәлем, $name!');
  String get eveningQuestion =>
      tr('Куда сходим вечером?', 'Кешке қайда барамыз?');
  String get dayQuestion =>
      tr('Чем займёмся сегодня?', 'Бүгін немен айналысамыз?');

  // ---------- Быстрые намерения ----------
  // Подпись чипа и готовый запрос в AI-поиск. Казахские запросы
  // распознаёт и mock-поиск: кездесу, кешке, әдемі, қымбат емес, жақын…

  String get intentDate => tr('Свидание', 'Кездесу');
  String get intentDateQuery => tr(
        'Свидание сегодня вечером, красиво и не слишком дорого',
        'Бүгін кешке кездесу, әдемі әрі тым қымбат емес',
      );

  String get intentCoffee => tr('Кофе', 'Кофе');
  String get intentCoffeeQuery => tr(
        'Где выпить хороший кофе рядом',
        'Жақын жерде жақсы кофе қайда ішуге болады',
      );

  String get intentActive => tr('Активно', 'Белсенді');
  String get intentActiveQuery => tr(
        'Хочу чего-нибудь активного с друзьями',
        'Достармен белсенді бірдеңе істегім келеді',
      );

  String get intentNovelty => tr('Что-то новое', 'Жаңа нәрсе');
  String get intentNoveltyQuery => tr(
        'Хочу попробовать что-то новое',
        'Жаңа нәрсені байқап көргім келеді',
      );

  String get intentWork => tr('Поработать', 'Жұмыс істеу');
  String get intentWorkQuery =>
      tr('Тихое кафе, чтобы поработать', 'Жұмыс істеуге тыныш кафе');

  // ---------- «Собрать мне вечер» ----------

  String get eveningBannerTitle =>
      tr('Собрать мне вечер', 'Маған кеш ұйымдастыр');
  String get eveningBannerSubtitle => tr(
        'Места, время и бюджет — одним планом',
        'Орындар, уақыт және бюджет — бір жоспарда',
      );

  // ---------- Лента ----------

  String get forYouToday => tr('Для тебя сегодня', 'Бүгін саған арналған');
  String get nearbyNow => tr('Сейчас рядом', 'Қазір жақын жерде');

  /// Запрос в AI-поиск по «Все» у секции «Сейчас рядом».
  String get nearbyQuery =>
      tr('Что интересного рядом', 'Жақын жерде не қызық бар');
}
