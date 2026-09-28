import 'package:bugin/core/app_images.dart';
import 'package:bugin/data/mock_places.dart';
import 'package:bugin/l10n/app_language.dart';
import 'package:bugin/models/models.dart';

/// События прототипа. Даты считаются от текущего дня,
/// поэтому афиша всегда «свежая».
abstract final class MockEvents {
  static const neonNights = 'neon_nights';
  static const rooftopAcoustic = 'rooftop_acoustic';
  static const steppeWind = 'steppe_wind';
  static const artEvening = 'art_evening';
  static const cityOfLight = 'city_of_light';
  static const standup = 'standup_evening';
  static const jazz = 'jazz_on_terrace';
  static const seagull = 'seagull_play';

  // События вымышленные, поэтому ссылки ведут на разделы афиши операторов.
  // С backend придёт ссылка на страницу конкретного события.
  static const _ticketonAstana = 'https://ticketon.kz/astana';
  static const _ticketonTheatres = 'https://ticketon.kz/astana/theatres';
  static const _kinoMovies = 'https://kino.kz/ru/movie';
  static const _kinoArt = 'https://kino.kz/ru/art';
  static const _kinoStandup = 'https://kino.kz/ru/standup';

  static List<Event> build({
    DateTime? now,
    AppLanguage language = AppLanguage.ru,
  }) {
    final n = now ?? DateTime.now();
    // Каждый текст — парой «русский, казахский».
    String t(String ru, String kk) => language == AppLanguage.kk ? kk : ru;
    DateTime at(int dayOffset, int hour, int minute) =>
        DateTime(n.year, n.month, n.day + dayOffset, hour, minute);

    // Ближайшая суббота (сегодня, если сегодня суббота) и воскресенье после неё.
    final toSaturday = (DateTime.saturday - n.weekday) % 7;
    final toSunday = (DateTime.sunday - n.weekday) % 7;

    return [
      Event(
        id: neonNights,
        title: 'Neon Nights',
        subtitle: t(
          'Живой концерт электро-поп группы',
          'Электро-поп тобының жанды концерті',
        ),
        description: t(
          'Neon Nights впервые выступают в Астане с новой программой: синтезаторы, '
              'живые барабаны и световое шоу. Два с половиной часа музыки без перерыва.',
          'Neon Nights Астанада алғаш рет жаңа бағдарламамен өнер көрсетеді: '
              'синтезаторлар, жанды барабандар және жарық шоуы. Екі жарым сағат '
              'үзіліссіз музыка.',
        ),
        category: EventCategory.concert,
        startsAt: at(toSaturday, 20, 0),
        durationMinutes: 150,
        venueName: 'Sky Arena',
        address: t('пр. Туран, 50', 'Тұран даңғылы, 50'),
        location: const GeoPoint(51.1102, 71.4029),
        distanceKm: 4.2,
        priceFrom: 12000,
        image: AppImages.neonNights,
        tags: [
          t('Электро-поп', 'Электро-поп'),
          t('Живой звук', 'Жанды дыбыс'),
          t('Танцпол', 'Би алаңы'),
        ],
        ageLimit: 16,
        tickets: [
          TicketCategory(t('Танцпартер', 'Би партері'), 12000),
          TicketCategory(t('Трибуна', 'Трибуна'), 15000),
          const TicketCategory('VIP', 30000),
        ],
        pitch: t('Живой звук и световое шоу', 'Жанды дыбыс және жарық шоуы'),
        reasons: [
          t('Концерты — в твоих интересах', 'Концерттер — сенің қызығушылықтарыңның бірі'),
          t('Живой звук и световое шоу', 'Жанды дыбыс және жарық шоуы'),
          t('Хорошо для вечера с друзьями', 'Достармен кеш өткізуге жақсы'),
        ],
        ticketUrl: _ticketonAstana,
        occasions: const {Occasion.friends, Occasion.date},
        vibes: const {Vibe.active},
        isFeatured: true,
      ),
      Event(
        id: rooftopAcoustic,
        title: t('Акустика на крыше', 'Шатырдағы акустика'),
        subtitle: t(
          'Живая музыка под открытым небом',
          'Ашық аспан астындағы жанды музыка',
        ),
        description: t(
          'Камерный акустический концерт на крыше лофта: гитара, голос и виды на '
              'вечерний город. Пледы и горячий чай — на месте.',
          'Лофт шатырындағы камералық акустикалық концерт: гитара, дауыс және '
              'кешкі қала көріністері. Плед пен ыстық шай — сол жерде.',
        ),
        category: EventCategory.concert,
        startsAt: at(0, 20, 0),
        durationMinutes: 120,
        venueName: t('Лофт «Кенес»', '«Кеңес» лофты'),
        address: t('ул. Сарайшык, 5', 'Сарайшық көшесі, 5'),
        location: const GeoPoint(51.1297, 71.4156),
        distanceKm: 2.4,
        priceFrom: 5000,
        image: AppImages.rooftopAcoustic,
        tags: [
          t('Акустика', 'Акустика'),
          t('Под открытым небом', 'Ашық аспан астында'),
        ],
        ageLimit: 12,
        tickets: [TicketCategory(t('Входной билет', 'Кіру билеті'), 5000)],
        pitch: t(
          'Камерно и красиво — вид на вечерний город',
          'Оңаша әрі әдемі — кешкі қала көрінісі',
        ),
        reasons: [
          t('Камерная атмосфера без толпы', 'Көп адамсыз оңаша атмосфера'),
          t(
            'Билет от 5 000 ₸ — в твоём бюджете',
            'Билет 5 000 ₸-ден бастап — бюджетіңе сай',
          ),
          t('Красивый вид на вечерний город', 'Кешкі қаланың әдемі көрінісі'),
        ],
        ticketUrl: _ticketonAstana,
        occasions: const {Occasion.date, Occasion.friends, Occasion.solo},
        vibes: const {Vibe.beautiful, Vibe.calm},
      ),
      Event(
        id: steppeWind,
        title: t('Премьера «Степной ветер»', '«Дала желі» премьерасы'),
        subtitle: t(
          'Драма о большой дороге домой',
          'Үйге апаратын ұзақ жол туралы драма',
        ),
        description: t(
          'Новый фильм о путешествии через степь и возвращении домой. Показ в зале '
              'IMAX, после сеанса — короткая встреча с режиссёром.',
          'Дала арқылы саяхат пен үйге оралу туралы жаңа фильм. Көрсетілім IMAX '
              'залында, сеанстан кейін — режиссермен қысқа кездесу.',
        ),
        category: EventCategory.cinema,
        startsAt: at(0, 21, 30),
        durationMinutes: 125,
        venueName: 'Luna Cinema',
        address: t('ул. Сыганак, 10', 'Сығанақ көшесі, 10'),
        location: const GeoPoint(51.1219, 71.4282),
        distanceKm: 1.9,
        priceFrom: 2500,
        image: AppImages.lunaCinema,
        tags: [
          t('Драма', 'Драма'),
          t('Премьера', 'Премьера'),
          'IMAX',
        ],
        ageLimit: 16,
        tickets: [
          TicketCategory(t('Стандарт', 'Стандарт'), 2500),
          TicketCategory(t('Комфорт', 'Комфорт'), 3500),
        ],
        pitch: t(
          'Премьера в IMAX и встреча с режиссёром',
          'IMAX-тағы премьера және режиссермен кездесу',
        ),
        reasons: [
          t(
            'Премьера — первые показы в городе',
            'Премьера — қаладағы алғашқы көрсетілімдер',
          ),
          t('Кино вдвоём — классика вечера', 'Екеулеп кино көру — кештің классикасы'),
          t('Билет от 2 500 ₸', 'Билет 2 500 ₸-ден бастап'),
        ],
        ticketUrl: _kinoMovies,
        occasions: const {Occasion.date, Occasion.friends, Occasion.solo},
        vibes: const {Vibe.calm},
        venuePlaceId: MockPlaces.lunaCinema,
      ),
      Event(
        id: artEvening,
        title: t('Арт-вечер: живопись', 'Арт-кеш: кескіндеме'),
        subtitle: t('Мастер-класс для новичков', 'Бастаушыларға шеберлік сабағы'),
        description: t(
          'Пишем картину маслом под руководством художника. Все материалы включены, '
              'опыт не нужен — результат забираете с собой.',
          'Суретшінің жетекшілігімен майлы бояумен сурет саламыз. Барлық '
              'материалдар бағаға қосылған, тәжірибе керек емес — дайын суретті '
              'өздеріңмен алып кетесіңдер.',
        ),
        category: EventCategory.workshop,
        startsAt: at(0, 19, 0),
        durationMinutes: 120,
        venueName: t('Студия «Холст»', '«Холст» студиясы'),
        address: t('ул. Кенесары, 40', 'Кенесары көшесі, 40'),
        location: const GeoPoint(51.1357, 71.4412),
        distanceKm: 2.1,
        priceFrom: 7000,
        image: AppImages.holstStudio,
        tags: [
          t('Для двоих', 'Екі адамға'),
          t('Все материалы', 'Барлық материалдар'),
          t('Опыт не нужен', 'Тәжірибе керек емес'),
        ],
        ageLimit: 14,
        tickets: [TicketCategory(t('Участие', 'Қатысу'), 7000)],
        pitch: t(
          'Необычный вариант для двоих — опыт не нужен',
          'Екі адамға ерекше нұсқа — тәжірибе керек емес',
        ),
        reasons: [
          t('Необычный формат для свидания', 'Кездесуге арналған ерекше формат'),
          t('Все материалы уже включены', 'Барлық материалдар бағаға қосылған'),
          t('Картину заберёте с собой', 'Суретті өздеріңмен алып кетесіңдер'),
        ],
        ticketUrl: _ticketonAstana,
        occasions: const {Occasion.date, Occasion.friends, Occasion.solo},
        vibes: const {Vibe.novelty, Vibe.calm},
        venuePlaceId: MockPlaces.holstStudio,
      ),
      Event(
        id: cityOfLight,
        title: t('Выставка «Город света»', '«Жарық қаласы» көрмесі'),
        subtitle: t(
          'Ночная фотография мегаполисов',
          'Мегаполистердің түнгі фотосуреттері',
        ),
        description: t(
          'Фотографии ночных городов мира: неон, отражения и длинная выдержка. '
              'По вечерам работает аудиогид.',
          'Әлемнің түнгі қалаларының фотосуреттері: неон, шағылысулар және ұзақ '
              'экспозиция. Кешке аудиогид жұмыс істейді.',
        ),
        category: EventCategory.exhibition,
        startsAt: at(0, 10, 0),
        durationMinutes: 720,
        venueName: t('Галерея «Бастау»', '«Бастау» галереясы'),
        address: t('ул. Бейбитшилик, 18', 'Бейбітшілік көшесі, 18'),
        location: const GeoPoint(51.1391, 71.4108),
        distanceKm: 3.0,
        priceFrom: 3000,
        image: AppImages.bastauGallery,
        tags: [
          t('Фотография', 'Фотография'),
          t('Современное искусство', 'Заманауи өнер'),
        ],
        ageLimit: 0,
        tickets: [TicketCategory(t('Входной билет', 'Кіру билеті'), 3000)],
        pitch: t(
          'Тихо, красиво и есть о чём поговорить',
          'Тыныш, әдемі және сөйлесетін тақырып көп',
        ),
        reasons: [
          t('Спокойный формат без спешки', 'Асығыссыз, тыныш формат'),
          t(
            'Можно прийти в любое время до 22:00',
            '22:00-ге дейін кез келген уақытта келуге болады',
          ),
          t('Билет 3 000 ₸', 'Билет 3 000 ₸'),
        ],
        ticketUrl: _kinoArt,
        occasions: const {Occasion.date, Occasion.solo, Occasion.friends},
        vibes: const {Vibe.calm, Vibe.beautiful},
        venuePlaceId: MockPlaces.bastauGallery,
      ),
      Event(
        id: jazz,
        title: t('Джаз на веранде', 'Верандадағы джаз'),
        subtitle: t('Трио живого джаза', 'Жанды джаз триосы'),
        description: t(
          'Живой джаз на веранде The Garden: трио, лёгкие стандарты и авторские '
              'композиции. Столы у сцены лучше бронировать.',
          'The Garden верандасында жанды джаз: трио, жеңіл стандарттар және '
              'авторлық композициялар. Сахна жанындағы үстелдерді брондаған дұрыс.',
        ),
        category: EventCategory.concert,
        startsAt: at(1, 19, 30),
        durationMinutes: 120,
        venueName: 'The Garden',
        address: t('ул. Абая, 57', 'Абай көшесі, 57'),
        location: const GeoPoint(51.1283, 71.4305),
        distanceKm: 1.5,
        priceFrom: 3000,
        image: AppImages.theGardenHall,
        tags: [
          t('Джаз', 'Джаз'),
          t('Живой звук', 'Жанды дыбыс'),
        ],
        ageLimit: 0,
        tickets: [TicketCategory(t('Вход', 'Кіру'), 3000)],
        pitch: t(
          'Живой джаз и ужин в одном месте',
          'Жанды джаз бен кешкі ас бір жерде',
        ),
        reasons: [
          t('Ужин и музыка без переездов', 'Кешкі ас пен музыка бір жерде'),
          t('Вход 3 000 ₸', 'Кіру 3 000 ₸'),
          t('Спокойная атмосфера', 'Тыныш атмосфера'),
        ],
        ticketUrl: _ticketonAstana,
        occasions: const {Occasion.date, Occasion.friends},
        vibes: const {Vibe.calm, Vibe.beautiful},
        venuePlaceId: MockPlaces.theGarden,
      ),
      Event(
        id: standup,
        title: t('Стендап «Свои люди»', '«Өзіміздікілер» стендапы'),
        subtitle: t('Вечер открытого микрофона', 'Ашық микрофон кеші'),
        description: t(
          'Молодые комики пробуют новый материал. Формат открытого микрофона: '
              'восемь выступлений по десять минут.',
          'Жас комиктер жаңа материалын сынап көреді. Ашық микрофон форматы: '
              'әрқайсысы он минуттық сегіз нөмір.',
        ),
        category: EventCategory.standup,
        startsAt: at(1, 20, 0),
        durationMinutes: 100,
        venueName: t('Бар «Сцена»', '«Сцена» бары'),
        address: t('ул. Достык, 9', 'Достық көшесі, 9'),
        location: const GeoPoint(51.1271, 71.4459),
        distanceKm: 2.8,
        priceFrom: 4000,
        image: '',
        tags: [
          t('Юмор', 'Әзіл'),
          t('Открытый микрофон', 'Ашық микрофон'),
        ],
        ageLimit: 18,
        tickets: [TicketCategory(t('Вход', 'Кіру'), 4000)],
        pitch: t('Посмеяться компанией', 'Достармен бірге күліп алу'),
        reasons: [
          t('Весёлый вечер с друзьями', 'Достармен көңілді кеш'),
          t('Билет 4 000 ₸', 'Билет 4 000 ₸'),
        ],
        ticketUrl: _kinoStandup,
        occasions: const {Occasion.friends},
        vibes: const {Vibe.active, Vibe.novelty},
      ),
      Event(
        id: seagull,
        title: t('Спектакль «Чайка»', '«Шағала» спектаклі'),
        subtitle: t('Классика в камерном зале', 'Камералық залдағы классика'),
        description: t(
          'Пьеса Чехова в современной постановке камерного театра. Зал на 80 мест, '
              'зрители сидят совсем близко к сцене.',
          'Чеховтың пьесасы камералық театрдың заманауи қойылымында. 80 орындық '
              'зал, көрермендер сахнаға өте жақын отырады.',
        ),
        category: EventCategory.theatre,
        startsAt: at(toSunday, 18, 0),
        durationMinutes: 150,
        venueName: t('Камерный театр «Арка»', '«Арқа» камералық театры'),
        address: t('ул. Иманова, 11', 'Иманов көшесі, 11'),
        location: const GeoPoint(51.1702, 71.4203),
        distanceKm: 3.4,
        priceFrom: 6000,
        image: '',
        tags: [
          t('Классика', 'Классика'),
          t('Камерный зал', 'Камералық зал'),
        ],
        ageLimit: 12,
        tickets: [
          TicketCategory(t('Партер', 'Партер'), 6000),
          TicketCategory(t('Первые ряды', 'Алдыңғы қатарлар'), 9000),
        ],
        pitch: t('Классика совсем близко к сцене', 'Сахнаның дәл жанында классика'),
        reasons: [
          t('Камерный зал на 80 мест', '80 орындық камералық зал'),
          t('Классика в современной постановке', 'Заманауи қойылымдағы классика'),
        ],
        ticketUrl: _ticketonTheatres,
        occasions: const {Occasion.date, Occasion.solo, Occasion.family},
        vibes: const {Vibe.calm, Vibe.beautiful},
      ),
    ];
  }
}
