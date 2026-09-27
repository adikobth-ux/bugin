import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:bugin/core/formatters.dart';
import 'package:bugin/l10n/app_language.dart';
import 'package:bugin/l10n/l10n_section.dart';
import 'package:bugin/l10n/sections/afisha_strings.dart';
import 'package:bugin/l10n/sections/evening_strings.dart';
import 'package:bugin/l10n/sections/event_strings.dart';
import 'package:bugin/l10n/sections/favorites_strings.dart';
import 'package:bugin/l10n/sections/home_strings.dart';
import 'package:bugin/l10n/sections/place_strings.dart';
import 'package:bugin/l10n/sections/profile_strings.dart';
import 'package:bugin/l10n/sections/search_strings.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/navigation/app_tab.dart';

/// Все тексты приложения на русском и казахском.
///
/// Общие строки (кнопки, подписи категорий, даты, цены) — прямо здесь,
/// тексты конкретных экранов — в разделах: `context.l10n.home.title`.
/// Получить: `context.l10n` в build, `AppStrings.forLanguage(...)` вне виджетов.
class AppStrings extends L10nSection {
  AppStrings._(AppLanguage language)
      : home = HomeStrings(language),
        search = SearchStrings(language),
        place = PlaceStrings(language),
        event = EventStrings(language),
        afisha = AfishaStrings(language),
        evening = EveningStrings(language),
        favorites = FavoritesStrings(language),
        profile = ProfileStrings(language),
        super(language);

  final HomeStrings home;
  final SearchStrings search;
  final PlaceStrings place;
  final EventStrings event;
  final AfishaStrings afisha;
  final EveningStrings evening;
  final FavoritesStrings favorites;
  final ProfileStrings profile;

  static final Map<AppLanguage, AppStrings> _cache = {};

  /// Тексты для языка — для сервисов, тестов и кода вне дерева виджетов.
  static AppStrings forLanguage(AppLanguage language) =>
      _cache.putIfAbsent(language, () => AppStrings._(language));

  /// Тексты текущего языка приложения. Подписывает виджет на смену языка,
  /// поэтому вызывать в build или didChangeDependencies, не в initState.
  static AppStrings of(BuildContext context) =>
      Localizations.of<AppStrings>(context, AppStrings) ??
      forLanguage(AppLanguage.ru);

  static const LocalizationsDelegate<AppStrings> delegate = _AppStringsDelegate();

  static final List<Locale> supportedLocales = [
    for (final language in AppLanguage.values) language.locale,
  ];

  // ---------- Общие действия ----------

  String get appName => 'Bugin';
  String get cancel => tr('Отмена', 'Болдырмау');
  String get done => tr('Готово', 'Дайын');
  String get save => tr('Сохранить', 'Сақтау');
  String get retry => tr('Повторить', 'Қайталау');
  String get undo => tr('Вернуть', 'Қайтару');
  String get close => tr('Закрыть', 'Жабу');
  String get back => tr('Назад', 'Артқа');
  String get all => tr('Все', 'Барлығы');
  String get readMore => tr('Читать дальше', 'Толығырақ');
  String get collapse => tr('Свернуть', 'Жию');
  String get loading => tr('Загрузка', 'Жүктелуде');
  String get route => tr('Маршрут', 'Бағыт');
  String get refine => tr('Уточнить', 'Нақтылау');
  String get scenario => tr('Сценарий', 'Сценарий');
  String get free => tr('Бесплатно', 'Тегін');
  String get addToFavorites => tr('Добавить в избранное', 'Таңдаулыларға қосу');
  String get removeFromFavorites =>
      tr('Убрать из избранного', 'Таңдаулылардан алып тастау');

  /// Сообщение для действий, которых в прототипе нет (бронь, оплата, звонок).
  String demo(String message) => tr('Демо: $message', 'Демо: $message');

  // ---------- Состояния загрузки ----------

  String get loadErrorTitle => tr('Не получилось загрузить', 'Жүктеу мүмкін болмады');
  String get loadErrorMessage =>
      tr('Проверь интернет и попробуй ещё раз', 'Интернетті тексеріп, қайта көр');

  // ---------- Поиск (общие элементы) ----------

  String get openSearch => tr('Открыть поиск', 'Іздеуді ашу');
  String get searchHint => tr('Напиши, чего хочешь…', 'Не қалайтыныңды жаз…');
  String get searchExample => tr(
        'Например: «вечером с девушкой, красиво и не слишком дорого»',
        'Мысалы: «кешке қызбен, әдемі әрі тым қымбат емес»',
      );
  String editQuery(String query) =>
      tr('Изменить запрос: $query', 'Сұрауды өзгерту: $query');
  String editParam(String label) => tr('Изменить: $label', 'Өзгерту: $label');
  String removeParam(String label) => tr('Убрать: $label', 'Алып тастау: $label');

  // ---------- Город ----------

  String get city => tr('Город', 'Қала');
  String get cityPickerHint =>
      tr('Покажем места и события рядом', 'Жақын маңдағы орындар мен іс-шараларды көрсетеміз');
  String cityButton(String city) =>
      tr('Город: $city. Изменить', 'Қала: $city. Өзгерту');

  // ---------- Деньги ----------

  /// «до 10 000 ₸» / «10 000 ₸-ге дейін».
  String upToTenge(int value) =>
      tr('до${Fmt.nbsp}${Fmt.tenge(value)}', '${Fmt.tenge(value)}-ге дейін');

  /// «от 12 000 ₸» / «12 000 ₸-ден» (так короче и привычно в ценниках).
  String fromTenge(int value) =>
      tr('от${Fmt.nbsp}${Fmt.tenge(value)}', '${Fmt.tenge(value)}-ден');

  /// Средний чек: 0 → «бесплатно».
  String averageCheck(int value) =>
      value == 0 ? tr('бесплатно', 'тегін') : Fmt.approxTenge(value);

  /// 1540 → «1,5 тыс.» / «1,5 мың», 892 → «892».
  String compactCount(int value) {
    if (value < 1000) {
      return value.toString();
    }
    final t = value / 1000;
    final text = t >= 10 ? t.round().toString() : Fmt.decimal(t);
    return '$text${Fmt.nbsp}${tr('тыс.', 'мың')}';
  }

  // ---------- Время ----------

  /// 45 → «45 минут», 120 → «2 часа» / «2 сағат», 150 → «2,5 часа».
  String duration(int minutes) {
    if (minutes < 60) {
      return tr(
        '$minutes ${ruPlural(minutes, 'минута', 'минуты', 'минут')}',
        '$minutes минут',
      );
    }
    if (minutes % 60 == 0) {
      final h = minutes ~/ 60;
      return tr('$h ${ruPlural(h, 'час', 'часа', 'часов')}', '$h сағат');
    }
    final hours = Fmt.decimal(minutes / 60);
    return tr('$hours часа', '$hours сағат');
  }

  /// Коротко: 240 → «4 ч» / «4 сағ», 45 → «45 мин».
  String durationShort(int minutes) {
    if (minutes < 60) {
      return '$minutes${Fmt.nbsp}${tr('мин', 'мин')}';
    }
    final hours =
        minutes % 60 == 0 ? '${minutes ~/ 60}' : Fmt.decimal(minutes / 60);
    return '$hours${Fmt.nbsp}${tr('ч', 'сағ')}';
  }

  /// «с 19:00» / «19:00-ден».
  String fromTime(int minutesOfDay) => tr(
        'с ${Fmt.hm(minutesOfDay)}',
        '${Fmt.hm(minutesOfDay)}-${kkAblative(minutesOfDay % 60)}',
      );

  /// «до 23:00» / «23:00-ге дейін».
  String untilTime(int minutesOfDay) => tr(
        'до ${Fmt.hm(minutesOfDay)}',
        '${Fmt.hm(minutesOfDay)}-${kkDative(minutesOfDay % 60)} дейін',
      );

  /// Для событий «весь день»: «До 23:00», «Сегодня, до 23:00» / «Бүгін, 23:00-ге дейін».
  String openUntil(DateTime end, {String? day}) {
    final until = untilTime(end.hour * 60 + end.minute);
    if (day != null) {
      return '$day, $until';
    }
    return '${until[0].toUpperCase()}${until.substring(1)}';
  }

  /// «08:00–23:00» или «Круглосуточно».
  String hoursRange(OpeningHours hours) => hours.isAlwaysOpen
      ? tr('Круглосуточно', 'Тәулік бойы')
      : '${Fmt.hm(hours.opensAt)}–${Fmt.hm(hours.closesAt)}';

  // ---------- Даты ----------

  List<String> get _weekdaysShort => isKk
      ? const ['Дс', 'Сс', 'Ср', 'Бс', 'Жм', 'Сн', 'Жс']
      : const ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  List<String> get _weekdaysFull => isKk
      ? const ['дүйсенбі', 'сейсенбі', 'сәрсенбі', 'бейсенбі', 'жұма', 'сенбі', 'жексенбі']
      : const ['понедельник', 'вторник', 'среда', 'четверг', 'пятница', 'суббота', 'воскресенье'];

  List<String> get _monthsShort => isKk
      ? const ['қаң', 'ақп', 'нау', 'сәу', 'мам', 'мау', 'шіл', 'там', 'қыр', 'қаз', 'қар', 'жел']
      : const ['янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];

  /// Русский — в родительном падеже («3 октября»), казахский — как есть («3 қазан»).
  List<String> get _monthsFull => isKk
      ? const [
          'қаңтар', 'ақпан', 'наурыз', 'сәуір', 'мамыр', 'маусым',
          'шілде', 'тамыз', 'қыркүйек', 'қазан', 'қараша', 'желтоқсан',
        ]
      : const [
          'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
          'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
        ];

  String get today => tr('Сегодня', 'Бүгін');
  String get tomorrow => tr('Завтра', 'Ертең');

  /// «Сб» / «Сн».
  String weekdayShort(DateTime d) => _weekdaysShort[d.weekday - 1];

  /// «Сегодня», «Завтра», «Сб, 3 окт» / «Сн, 3 қаз».
  String relativeDay(DateTime d, {DateTime? now}) {
    final diff = Fmt.dayDiff(d, now ?? DateTime.now());
    if (diff == 0) {
      return today;
    }
    if (diff == 1) {
      return tomorrow;
    }
    return '${weekdayShort(d)}, ${d.day} ${_monthsShort[d.month - 1]}';
  }

  /// «Сегодня · 20:00».
  String eventWhen(DateTime d, {DateTime? now}) =>
      '${relativeDay(d, now: now)} · ${Fmt.time(d)}';

  /// «Суббота, 3 октября» / «3 қазан, сенбі».
  String longDate(DateTime d) {
    final weekday = _weekdaysFull[d.weekday - 1];
    final month = _monthsFull[d.month - 1];
    if (isKk) {
      return '${d.day} $month, $weekday';
    }
    return '${weekday[0].toUpperCase()}${weekday.substring(1)}, ${d.day} $month';
  }

  /// «Сегодня», «Завтра», «Через 6 дней» / «6 күннен кейін».
  String inDays(DateTime d, {DateTime? now}) {
    final diff = Fmt.dayDiff(d, now ?? DateTime.now());
    if (diff <= 0) {
      return today;
    }
    if (diff == 1) {
      return tomorrow;
    }
    return tr(
      'Через $diff ${ruPlural(diff, 'день', 'дня', 'дней')}',
      '$diff күннен кейін',
    );
  }

  /// «сегодня», «вчера», «3 дня назад» / «3 күн бұрын».
  String ago(DateTime d, {DateTime? now}) {
    final diff = Fmt.dayDiff(now ?? DateTime.now(), d);
    if (diff <= 0) {
      return tr('сегодня', 'бүгін');
    }
    if (diff == 1) {
      return tr('вчера', 'кеше');
    }
    if (diff < 7) {
      return tr('$diff ${ruPlural(diff, 'день', 'дня', 'дней')} назад', '$diff күн бұрын');
    }
    if (diff < 30) {
      final weeks = diff ~/ 7;
      return tr(
        '$weeks ${ruPlural(weeks, 'неделю', 'недели', 'недель')} назад',
        '$weeks апта бұрын',
      );
    }
    final months = diff ~/ 30;
    return tr(
      '$months ${ruPlural(months, 'месяц', 'месяца', 'месяцев')} назад',
      '$months ай бұрын',
    );
  }

  // ---------- Подписи справочников ----------

  /// Подпись любого значения-справочника: `l10n.label(place.category)`.
  String label(Enum value) => switch (value) {
        Occasion v => _occasion(v),
        Vibe v => _vibe(v),
        PlaceCategory v => _placeCategory(v),
        AmenityType v => _amenity(v),
        EventCategory v => _eventCategory(v),
        EventDayFilter v => _eventDay(v),
        Company v => _company(v),
        PlanDay v => _planDay(v),
        Mood v => _mood(v),
        ParamType v => _paramType(v),
        TravelMode v => _travelMode(v),
        Interest v => _interest(v),
        AppTab v => _tab(v),
        FavoritesSection v => _favoritesSection(v),
        AppLanguage v => v.nativeName,
        _ => value.name,
      };

  String _occasion(Occasion v) => switch (v) {
        Occasion.date => tr('Свидание', 'Кездесу'),
        Occasion.friends => tr('С друзьями', 'Достармен'),
        Occasion.work => tr('Поработать', 'Жұмыс істеу'),
        Occasion.family => tr('С семьёй', 'Отбасымен'),
        Occasion.solo => tr('Для себя', 'Өзім үшін'),
      };

  String _vibe(Vibe v) => switch (v) {
        Vibe.beautiful => tr('Красиво', 'Әдемі'),
        Vibe.calm => tr('Спокойно', 'Тыныш'),
        Vibe.active => tr('Активно', 'Белсенді'),
        Vibe.novelty => tr('Что-то новое', 'Жаңа нәрсе'),
      };

  String _placeCategory(PlaceCategory v) => switch (v) {
        PlaceCategory.cafe => tr('Кафе', 'Кафе'),
        PlaceCategory.coffeeShop => tr('Кофейня', 'Кофехана'),
        PlaceCategory.restaurant => tr('Ресторан', 'Мейрамхана'),
        PlaceCategory.bowling => tr('Боулинг', 'Боулинг'),
        PlaceCategory.cinema => tr('Кино', 'Кино'),
        PlaceCategory.park => tr('Прогулка', 'Серуен'),
        PlaceCategory.gallery => tr('Галерея', 'Галерея'),
        PlaceCategory.studio => tr('Студия', 'Студия'),
      };

  String _amenity(AmenityType v) => switch (v) {
        AmenityType.wifi => 'Wi-Fi',
        AmenityType.sockets => tr('Розетки', 'Розеткалар'),
        AmenityType.pets => tr('С животными', 'Жануарлармен'),
        AmenityType.smoking => tr('Курение', 'Темекі шегу'),
        AmenityType.payment => tr('Оплата', 'Төлем'),
        AmenityType.parking => tr('Парковка', 'Тұрақ'),
      };

  String _eventCategory(EventCategory v) => switch (v) {
        EventCategory.concert => tr('Концерт', 'Концерт'),
        EventCategory.cinema => tr('Кино', 'Кино'),
        EventCategory.theatre => tr('Театр', 'Театр'),
        EventCategory.exhibition => tr('Выставка', 'Көрме'),
        EventCategory.workshop => tr('Мастер-класс', 'Шеберлік сабағы'),
        EventCategory.standup => tr('Стендап', 'Стендап'),
      };

  /// Название категории во множественном числе — для фильтров афиши.
  String eventCategoryPlural(EventCategory v) => switch (v) {
        EventCategory.concert => tr('Концерты', 'Концерттер'),
        EventCategory.cinema => tr('Кино', 'Кино'),
        EventCategory.theatre => tr('Театр', 'Театр'),
        EventCategory.exhibition => tr('Выставки', 'Көрмелер'),
        EventCategory.workshop => tr('Мастер-классы', 'Шеберлік сабақтары'),
        EventCategory.standup => tr('Стендап', 'Стендап'),
      };

  String _eventDay(EventDayFilter v) => switch (v) {
        EventDayFilter.today => today,
        EventDayFilter.tomorrow => tomorrow,
        EventDayFilter.weekend => tr('Выходные', 'Демалыс'),
        EventDayFilter.date => tr('Дата', 'Күні'),
      };

  String _company(Company v) => switch (v) {
        Company.solo => tr('Один', 'Жалғыз'),
        Company.pair => tr('Вдвоём', 'Екеуміз'),
        Company.friends => tr('С друзьями', 'Достармен'),
        Company.family => tr('С семьёй', 'Отбасымен'),
      };

  String _planDay(PlanDay v) => switch (v) {
        PlanDay.today => today,
        PlanDay.tomorrow => tomorrow,
        PlanDay.weekend => tr('Выходные', 'Демалыс күндері'),
        PlanDay.date => tr('Выбрать дату', 'Күнді таңдау'),
      };

  /// День внутри фразы: «сегодня», «в выходные» / «бүгін», «демалыс күндері».
  String planDayInline(PlanDay v) => switch (v) {
        PlanDay.today => tr('сегодня', 'бүгін'),
        PlanDay.tomorrow => tr('завтра', 'ертең'),
        PlanDay.weekend => tr('в выходные', 'демалыс күндері'),
        PlanDay.date => tr('в выбранный день', 'таңдалған күні'),
      };

  String _mood(Mood v) => switch (v) {
        Mood.calm => tr('Спокойно', 'Тыныш'),
        Mood.active => tr('Активно', 'Белсенді'),
        Mood.novelty => tr('Что-то новое', 'Жаңа нәрсе'),
        Mood.culture => tr('Культурно', 'Мәдени'),
      };

  String _paramType(ParamType v) => switch (v) {
        ParamType.occasion => tr('Повод', 'Себеп'),
        ParamType.time => tr('Когда', 'Қашан'),
        ParamType.budget => tr('Бюджет', 'Бюджет'),
        ParamType.mood => tr('Настроение', 'Көңіл-күй'),
        ParamType.location => tr('Где искать', 'Қай жерден'),
      };

  String _travelMode(TravelMode v) => switch (v) {
        TravelMode.walk => tr('Пешком', 'Жаяу'),
        TravelMode.taxi => tr('На такси', 'Таксимен'),
      };

  String _interest(Interest v) => switch (v) {
        Interest.dates => tr('Свидания', 'Кездесулер'),
        Interest.active => tr('Активный отдых', 'Белсенді демалыс'),
        Interest.coffee => tr('Кофе', 'Кофе'),
        Interest.concerts => tr('Концерты', 'Концерттер'),
        Interest.art => tr('Искусство', 'Өнер'),
        Interest.cinema => tr('Кино', 'Кино'),
        Interest.food => tr('Гастрономия', 'Гастрономия'),
      };

  String _tab(AppTab v) => switch (v) {
        AppTab.home => tr('Главная', 'Басты бет'),
        AppTab.afisha => tr('Афиша', 'Афиша'),
        AppTab.favorites => tr('Избранное', 'Таңдаулылар'),
        AppTab.profile => tr('Профиль', 'Профиль'),
      };

  String _favoritesSection(FavoritesSection v) => switch (v) {
        FavoritesSection.places => tr('Места', 'Орындар'),
        FavoritesSection.events => tr('События', 'Іс-шаралар'),
        FavoritesSection.scenarios => tr('Сценарии', 'Сценарийлер'),
      };

  // ---------- Параметры поиска ----------

  /// Подпись распознанного параметра: «Свидание», «Вечером», «до 15 000 ₸».
  String paramLabel(IntentParam param) => paramOption(param.type, param.code);

  String paramOption(ParamType type, String code) {
    final amount = type == ParamType.budget ? int.tryParse(code) : null;
    if (amount != null) {
      return upToTenge(amount);
    }
    return switch ((type, code)) {
      (ParamType.occasion, _) => switch (Occasion.tryParse(code)) {
          final Occasion occasion => _occasion(occasion),
          null => code,
        },
      (ParamType.time, 'morning') => tr('Утром', 'Таңертең'),
      (ParamType.time, 'day') => tr('Днём', 'Күндіз'),
      (ParamType.time, 'evening') => tr('Вечером', 'Кешке'),
      (ParamType.time, 'night') => tr('Ночью', 'Түнде'),
      (ParamType.budget, 'any') => tr('Бюджет не важен', 'Бюджет маңызды емес'),
      (ParamType.mood, 'beautiful') => tr('Красиво и спокойно', 'Әдемі әрі тыныш'),
      (ParamType.mood, 'calm') => _vibe(Vibe.calm),
      (ParamType.mood, 'active') => _vibe(Vibe.active),
      (ParamType.mood, 'novelty') => _vibe(Vibe.novelty),
      (ParamType.location, 'near') => tr('Рядом', 'Жақын жерде'),
      (ParamType.location, 'center') => tr('В центре', 'Орталықта'),
      (ParamType.location, 'any') => tr('Где угодно', 'Кез келген жерде'),
      _ => code,
    };
  }

  // ---------- «Собрать мне вечер» ----------

  /// Бюджет плана: «до 15 000 ₸» или «Неважно».
  String budgetLabel(int? value) =>
      value == null ? tr('Неважно', 'Маңызды емес') : upToTenge(value);

  /// День плана внутри фразы: «сегодня», «сб, 3 окт».
  String requestDay(EveningRequest request, {DateTime? now}) {
    final date = request.date;
    if (request.day == PlanDay.date && date != null) {
      return relativeDay(date, now: now).toLowerCase();
    }
    return planDayInline(request.day);
  }

  /// «Вдвоём · сегодня с 19:00 · до 15 000 ₸ · спокойно».
  String requestSummary(EveningRequest request, {DateTime? now}) {
    final budget = request.budget;
    final budgetText = budget == null
        ? tr('бюджет не важен', 'бюджет маңызды емес')
        : upToTenge(budget);
    final day = requestDay(request, now: now);
    final start = fromTime(request.startMinutes);
    final when = tr('$day $start', '$day, $start');
    return '${_company(request.company)} · $when · $budgetText · '
        '${_mood(request.mood).toLowerCase()}';
  }

  /// Название собранного плана: «Спокойный вечер вдвоём» / «Екеуге арналған тыныш кеш».
  String planTitle(Mood mood, Company company) {
    if (isKk) {
      final who = switch (company) {
        Company.solo => 'Өзіңе арналған',
        Company.pair => 'Екеуге арналған',
        Company.friends => 'Достармен',
        Company.family => 'Отбасымен',
      };
      final what = switch (mood) {
        Mood.calm => 'тыныш',
        Mood.active => 'белсенді',
        Mood.novelty => 'ерекше',
        Mood.culture => 'мәдени',
      };
      return '$who $what кеш';
    }
    final what = switch (mood) {
      Mood.calm => 'Спокойный',
      Mood.active => 'Активный',
      Mood.novelty => 'Необычный',
      Mood.culture => 'Культурный',
    };
    final who = switch (company) {
      Company.solo => 'для себя',
      Company.pair => 'вдвоём',
      Company.friends => 'с друзьями',
      Company.family => 'с семьёй',
    };
    return '$what вечер $who';
  }
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLanguage.tryParse(locale.languageCode) != null;

  @override
  Future<AppStrings> load(Locale locale) => SynchronousFuture<AppStrings>(
        AppStrings.forLanguage(
          AppLanguage.tryParse(locale.languageCode) ?? AppLanguage.ru,
        ),
      );

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}

extension AppStringsContext on BuildContext {
  /// Тексты на текущем языке: `context.l10n.save`, `context.l10n.home.title`.
  AppStrings get l10n => AppStrings.of(this);
}
