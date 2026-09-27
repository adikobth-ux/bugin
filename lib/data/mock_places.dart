import 'package:bugin/core/app_images.dart';
import 'package:bugin/l10n/app_language.dart';
import 'package:bugin/models/models.dart';

/// Каталог мест для прототипа. Один источник правды: все экраны
/// берут место по id, поэтому цены, расстояния и рейтинги везде совпадают.
abstract final class MockPlaces {
  static const theGarden = 'the_garden';
  static const coffeeLab = 'coffee_lab';
  static const galaxyBowling = 'galaxy_bowling';
  static const skyLounge = 'sky_lounge';
  static const lunaCinema = 'luna_cinema';
  static const esilEmbankment = 'esil_embankment';
  static const holstStudio = 'holst_studio';
  static const bastauGallery = 'bastau_gallery';

  /// Порядок блока «Сейчас рядом» на главной.
  static const nearbyOrder = [
    theGarden,
    coffeeLab,
    galaxyBowling,
    skyLounge,
    lunaCinema,
    holstStudio,
  ];

  static List<Place> build({
    DateTime? now,
    AppLanguage language = AppLanguage.ru,
  }) {
    final today = now ?? DateTime.now();
    // Каждый текст — парой «русский, казахский».
    String t(String ru, String kk) => language == AppLanguage.kk ? kk : ru;
    DateTime daysAgo(int days) => today.subtract(Duration(days: days));

    return [
      Place(
        id: theGarden,
        name: 'The Garden',
        subtitle: t(
          'Европейская кухня и завтраки весь день',
          'Еуропа асханасы және күні бойы таңғы ас',
        ),
        description: t(
          'Уютное кафе в центре города: живая зелень, тёплый свет и европейская '
              'кухня. Днём здесь завтракают и работают, вечером ужинают вдвоём под '
              'тихую музыку. По пятницам — живые акустические сеты.',
          'Қала орталығындағы жайлы кафе: жасыл өсімдіктер, жылы жарық және '
              'еуропа асханасы. Күндіз мұнда таңғы ас ішіп, жұмыс істейді, кешке '
              'тыныш әуен астында екеулеп кешкі ас ішеді. Жұма сайын — жанды '
              'акустикалық сеттер.',
        ),
        category: PlaceCategory.cafe,
        categoryDetail: t('европейская кухня', 'еуропа асханасы'),
        address: t('ул. Абая, 57', 'Абай көшесі, 57'),
        phone: '+7 700 123 45 67',
        rating: 4.8,
        reviewsCount: 1540,
        priceLevel: 2,
        averageCheck: 6000,
        openingHours: const OpeningHours(8 * 60, 23 * 60),
        photos: const [
          AppImages.theGarden,
          AppImages.theGardenHall,
          AppImages.theGardenCoffee,
          AppImages.theGardenFood,
          AppImages.theGardenNeon,
        ],
        tags: [
          t('Европейская кухня', 'Еуропа асханасы'),
          t('Завтраки', 'Таңғы ас'),
          t('Кофе', 'Кофе'),
          t('Уютная атмосфера', 'Жайлы атмосфера'),
        ],
        amenities: [
          PlaceAmenity(AmenityType.wifi, t('Бесплатный', 'Тегін')),
          PlaceAmenity(AmenityType.pets, t('Можно', 'Болады')),
          PlaceAmenity(AmenityType.smoking, t('Нельзя', 'Болмайды')),
          PlaceAmenity(AmenityType.payment, t('Карта, наличные', 'Карта, қолма-қол')),
        ],
        distanceKm: 1.5,
        taxiMinutes: 6,
        bookingType: BookingType.table,
        pitch: t(
          'Уютно, живая зелень и тихая музыка',
          'Жайлы, жасыл өсімдіктер мен тыныш музыка',
        ),
        goodFor: const {Occasion.date, Occasion.friends, Occasion.solo, Occasion.work},
        vibes: const {Vibe.beautiful, Vibe.calm},
        location: const GeoPoint(51.1283, 71.4305),
        reviews: [
          Review(
            author: 'Алина',
            rating: 5,
            text: t(
              'Очень уютно вечером, по пятницам живая музыка. Десерты — отдельная '
                  'любовь, особенно чизкейк.',
              'Кешке өте жайлы, жұма сайын жанды музыка. Десерттері — бөлек '
                  'әңгіме, әсіресе чизкейк.',
            ),
            date: daysAgo(2),
          ),
          Review(
            author: 'Тимур',
            rating: 4.5,
            text: t(
              'Хорошее место для завтрака и спокойной встречи. В выходные лучше '
                  'бронировать стол заранее.',
              'Таңғы асқа және тыныш кездесуге жақсы орын. Демалыс күндері '
                  'үстелді алдын ала брондаған дұрыс.',
            ),
            date: daysAgo(9),
          ),
          Review(
            author: 'Дана',
            rating: 5,
            text: t(
              'Красиво, тихо и вкусно. Брали пасту и лимонад — всё понравилось.',
              'Әдемі, тыныш әрі дәмді. Паста мен лимонад алдық — бәрі ұнады.',
            ),
            date: daysAgo(21),
          ),
        ],
      ),
      Place(
        id: coffeeLab,
        name: 'Coffee Lab',
        subtitle: t(
          'Спешелти-кофе и домашние десерты',
          'Спешелти-кофе және үй десерттері',
        ),
        description: t(
          'Кофейня с собственной обжаркой. Большие столы, розетки у каждого места '
              'и тихая музыка — удобно поработать или встретиться за десертом.',
          'Кофені өздері қуыратын кофехана. Үлкен үстелдер, әр орында розетка '
              'және тыныш музыка — жұмыс істеуге немесе десерт үстінде '
              'кездесуге ыңғайлы.',
        ),
        category: PlaceCategory.coffeeShop,
        categoryDetail: t('десерты', 'десерттер'),
        address: t('пр. Мангилик Ел, 20', 'Мәңгілік Ел даңғылы, 20'),
        phone: '+7 701 555 20 20',
        rating: 4.7,
        reviewsCount: 892,
        priceLevel: 2,
        averageCheck: 4500,
        openingHours: const OpeningHours(7 * 60 + 30, 22 * 60),
        photos: const [AppImages.coffeeLab],
        tags: [
          t('Кофе', 'Кофе'),
          t('Десерты', 'Десерттер'),
          t('Для работы', 'Жұмыс үшін'),
        ],
        amenities: [
          PlaceAmenity(AmenityType.wifi, t('Бесплатный', 'Тегін')),
          PlaceAmenity(AmenityType.sockets, t('У каждого стола', 'Әр үстелде')),
          PlaceAmenity(AmenityType.smoking, t('Нельзя', 'Болмайды')),
          PlaceAmenity(AmenityType.payment, t('Карта, QR', 'Карта, QR')),
        ],
        distanceKm: 1.1,
        taxiMinutes: 5,
        bookingType: BookingType.none,
        pitch: t('Тихо и уютно', 'Тыныш әрі жайлы'),
        goodFor: const {Occasion.date, Occasion.work, Occasion.solo, Occasion.friends},
        vibes: const {Vibe.calm},
        location: const GeoPoint(51.1302, 71.4247),
        reviews: [
          Review(
            author: 'Ерлан',
            rating: 5,
            text: t(
              'Лучший флэт уайт в районе, и никто не торопит, если сидишь с ноутбуком.',
              'Аудандағы ең жақсы флэт уайт, ноутбукпен отырсаң да ешкім '
                  'асықтырмайды.',
            ),
            date: daysAgo(4),
          ),
        ],
      ),
      Place(
        id: galaxyBowling,
        name: 'Galaxy Bowling',
        subtitle: t('Боулинг, бильярд и кухня', 'Боулинг, бильярд және тағамдар'),
        description: t(
          '12 дорожек с неоновой подсветкой, бильярд и кухня. Хорошо на компанию: '
              'дорожку можно забронировать заранее и не ждать.',
          'Неон жарығы бар 12 жолақ, бильярд және тағамдар. Топпен келуге '
              'жақсы: жолақты алдын ала брондап, кезек күтпеуге болады.',
        ),
        category: PlaceCategory.bowling,
        categoryDetail: t('12 дорожек', '12 жолақ'),
        address: t('ул. Кунаева, 12', 'Қонаев көшесі, 12'),
        phone: '+7 702 300 12 12',
        rating: 4.7,
        reviewsCount: 2310,
        priceLevel: 2,
        averageCheck: 4000,
        openingHours: const OpeningHours(12 * 60, 26 * 60),
        photos: const [AppImages.galaxyBowling],
        tags: [
          t('Боулинг', 'Боулинг'),
          t('Друзья', 'Достар'),
          t('Музыка', 'Музыка'),
        ],
        amenities: [
          PlaceAmenity(AmenityType.parking, t('Бесплатная', 'Тегін')),
          PlaceAmenity(AmenityType.payment, t('Карта, наличные', 'Карта, қолма-қол')),
          PlaceAmenity(AmenityType.smoking, t('Нельзя', 'Болмайды')),
          PlaceAmenity(AmenityType.wifi, t('Бесплатный', 'Тегін')),
        ],
        distanceKm: 1.2,
        taxiMinutes: 5,
        bookingType: BookingType.lane,
        pitch: t('Весело и динамично', 'Көңілді әрі серпінді'),
        goodFor: const {Occasion.friends, Occasion.family, Occasion.date},
        vibes: const {Vibe.active},
        location: const GeoPoint(51.1265, 71.4371),
        reviews: [
          Review(
            author: 'Марат',
            rating: 4.5,
            text: t(
              'Отмечали день рождения — дорожки новые, музыка громкая, кухня норм.',
              'Туған күнді атап өттік — жолақтары жаңа, музыкасы қатты, тамағы '
                  'да жаман емес.',
            ),
            date: daysAgo(6),
          ),
        ],
      ),
      Place(
        id: skyLounge,
        name: 'Sky Lounge',
        subtitle: t(
          'Ресторан с панорамным видом на город',
          'Қаланың панорамалық көрінісі бар мейрамхана',
        ),
        description: t(
          'Ресторан на 24 этаже с панорамными окнами. Лучшие места — у окна на '
              'закате, их стоит бронировать заранее.',
          '24-қабаттағы панорамалық терезелері бар мейрамхана. Ең жақсы '
              'орындар — күн батарда терезе жанында, оларды алдын ала брондаған '
              'жөн.',
        ),
        category: PlaceCategory.restaurant,
        categoryDetail: t('24 этаж', '24-қабат'),
        address: t('пр. Туран, 37', 'Тұран даңғылы, 37'),
        phone: '+7 705 240 24 24',
        rating: 4.6,
        reviewsCount: 1210,
        priceLevel: 3,
        averageCheck: 8000,
        openingHours: const OpeningHours(12 * 60, 24 * 60),
        photos: const [AppImages.skyLounge],
        tags: [
          t('Панорамный вид', 'Панорамалық көрініс'),
          t('Коктейли', 'Коктейльдер'),
          t('Ужин', 'Кешкі ас'),
        ],
        amenities: [
          PlaceAmenity(AmenityType.wifi, t('Бесплатный', 'Тегін')),
          PlaceAmenity(AmenityType.smoking, t('На террасе', 'Террасада')),
          PlaceAmenity(AmenityType.payment, t('Карта', 'Карта')),
          PlaceAmenity(AmenityType.parking, t('Подземная', 'Жерасты')),
        ],
        distanceKm: 1.8,
        taxiMinutes: 8,
        bookingType: BookingType.table,
        pitch: t(
          'Панорамный вид на город — красиво вечером',
          'Қаланың панорамалық көрінісі — кешке әдемі',
        ),
        goodFor: const {Occasion.date, Occasion.friends},
        vibes: const {Vibe.beautiful},
        location: const GeoPoint(51.1244, 71.4198),
        reviews: [
          Review(
            author: 'Айгерим',
            rating: 5,
            text: t(
              'Вид потрясающий, особенно на закате. Цены выше среднего, но оно того стоит.',
              'Көрінісі керемет, әсіресе күн батқанда. Бағасы орташадан жоғары, '
                  'бірақ соған тұрарлық.',
            ),
            date: daysAgo(3),
          ),
        ],
      ),
      Place(
        id: lunaCinema,
        name: 'Luna Cinema',
        subtitle: t('Кинотеатр с залом IMAX', 'IMAX залы бар кинотеатр'),
        description: t(
          'Современный кинотеатр с удобными креслами и залом IMAX. Вечерние сеансы '
              'начинаются в 20:00 и 21:30.',
          'Жайлы орындықтары мен IMAX залы бар заманауи кинотеатр. Кешкі '
              'сеанстар 20:00 мен 21:30-да басталады.',
        ),
        category: PlaceCategory.cinema,
        categoryDetail: t('8 залов', '8 зал'),
        address: t('ул. Сыганак, 10', 'Сығанақ көшесі, 10'),
        phone: '+7 707 111 70 70',
        rating: 4.5,
        reviewsCount: 2280,
        priceLevel: 2,
        averageCheck: 5000,
        openingHours: const OpeningHours(10 * 60, 26 * 60),
        photos: const [AppImages.lunaCinema],
        tags: [
          t('Кино', 'Кино'),
          t('Премьеры', 'Премьералар'),
          'IMAX',
        ],
        amenities: [
          PlaceAmenity(AmenityType.parking, t('Бесплатная', 'Тегін')),
          PlaceAmenity(AmenityType.payment, t('Карта, наличные', 'Карта, қолма-қол')),
        ],
        distanceKm: 1.9,
        taxiMinutes: 8,
        bookingType: BookingType.ticket,
        pitch: t(
          'Вечерние сеансы в 20:00 и 21:30',
          'Кешкі сеанстар 20:00 мен 21:30-да',
        ),
        goodFor: const {Occasion.date, Occasion.friends, Occasion.family},
        vibes: const {Vibe.calm},
        location: const GeoPoint(51.1219, 71.4282),
        reviews: [
          Review(
            author: 'Нурлан',
            rating: 4.5,
            text: t(
              'Зал IMAX отличный, кресла удобные. Попкорн дорогой, как везде.',
              'IMAX залы керемет, орындықтары жайлы. Попкорны қымбат, басқа '
                  'жерлердегідей.',
            ),
            date: daysAgo(12),
          ),
        ],
      ),
      Place(
        id: esilEmbankment,
        name: t('Набережная Есиля', 'Есіл жағалауы'),
        subtitle: t('Прогулочная зона вдоль реки', 'Өзен бойындағы серуен аймағы'),
        description: t(
          'Прогулочная зона вдоль реки: вечерняя подсветка, скамейки и виды на '
              'город. Удобно пройтись между ужином и кино.',
          'Өзен бойындағы серуен аймағы: кешкі жарықтандыру, орындықтар және '
              'қала көріністері. Кешкі ас пен кино арасында серуендеуге ыңғайлы.',
        ),
        category: PlaceCategory.park,
        categoryDetail: t('прогулка', 'серуен'),
        address: t('Набережная Есиля', 'Есіл жағалауы'),
        phone: '',
        rating: 4.9,
        reviewsCount: 3120,
        priceLevel: 1,
        averageCheck: 0,
        openingHours: const OpeningHours.always(),
        photos: const [],
        tags: [
          t('Прогулка', 'Серуен'),
          t('Виды', 'Көріністер'),
          t('Бесплатно', 'Тегін'),
        ],
        amenities: const [],
        distanceKm: 0.9,
        taxiMinutes: 4,
        bookingType: BookingType.none,
        pitch: t(
          'Красивые виды и огни вечером',
          'Әдемі көріністер мен кешкі шамдар',
        ),
        goodFor: const {
          Occasion.date,
          Occasion.friends,
          Occasion.family,
          Occasion.solo,
        },
        vibes: const {Vibe.beautiful, Vibe.calm},
        location: const GeoPoint(51.1331, 71.4201),
      ),
      Place(
        id: holstStudio,
        name: t('Студия «Холст»', '«Холст» студиясы'),
        subtitle: t(
          'Мастер-классы по живописи для новичков',
          'Бастаушыларға кескіндемеден шеберлік сабақтары',
        ),
        description: t(
          'Творческая студия, где проводят мастер-классы по живописи для новичков. '
              'Все материалы включены, картину забираете с собой.',
          'Бастаушыларға кескіндемеден шеберлік сабақтарын өткізетін '
              'шығармашылық студия. Барлық материалдар бағаға қосылған, салған '
              'суретті өздеріңмен алып кетесіңдер.',
        ),
        category: PlaceCategory.studio,
        categoryDetail: t('мастер-классы', 'шеберлік сабақтары'),
        address: t('ул. Кенесары, 40', 'Кенесары көшесі, 40'),
        phone: '+7 708 456 78 90',
        rating: 4.9,
        reviewsCount: 346,
        priceLevel: 2,
        averageCheck: 7000,
        openingHours: const OpeningHours(11 * 60, 22 * 60),
        photos: const [AppImages.holstStudio],
        tags: [
          t('Для двоих', 'Екі адамға'),
          t('Все материалы', 'Барлық материалдар'),
          t('Опыт не нужен', 'Тәжірибе керек емес'),
        ],
        amenities: [
          PlaceAmenity(AmenityType.payment, t('Карта, наличные', 'Карта, қолма-қол')),
          PlaceAmenity(AmenityType.wifi, t('Бесплатный', 'Тегін')),
        ],
        distanceKm: 2.1,
        taxiMinutes: 9,
        bookingType: BookingType.ticket,
        pitch: t(
          'Необычный вариант для двоих — опыт не нужен',
          'Екі адамға ерекше нұсқа — тәжірибе керек емес',
        ),
        goodFor: const {Occasion.date, Occasion.friends, Occasion.solo},
        vibes: const {Vibe.novelty, Vibe.calm},
        location: const GeoPoint(51.1357, 71.4412),
      ),
      Place(
        id: bastauGallery,
        name: t('Галерея «Бастау»', '«Бастау» галереясы'),
        subtitle: t(
          'Современное искусство и фотография',
          'Заманауи өнер және фотография',
        ),
        description: t(
          'Небольшая галерея современного искусства и фотографии. Выставки '
              'меняются раз в месяц, по четвергам — бесплатные экскурсии.',
          'Заманауи өнер мен фотографияның шағын галереясы. Көрмелер айына бір '
              'рет ауысады, бейсенбі сайын — тегін экскурсиялар.',
        ),
        category: PlaceCategory.gallery,
        categoryDetail: t('современное искусство', 'заманауи өнер'),
        address: t('ул. Бейбитшилик, 18', 'Бейбітшілік көшесі, 18'),
        phone: '+7 747 310 31 31',
        rating: 4.6,
        reviewsCount: 518,
        priceLevel: 1,
        averageCheck: 3000,
        openingHours: const OpeningHours(10 * 60, 22 * 60),
        photos: const [AppImages.bastauGallery],
        tags: [
          t('Выставки', 'Көрмелер'),
          t('Фотография', 'Фотография'),
        ],
        amenities: [
          PlaceAmenity(AmenityType.payment, t('Карта', 'Карта')),
        ],
        distanceKm: 3.0,
        taxiMinutes: 11,
        bookingType: BookingType.ticket,
        pitch: t(
          'Тихо, красиво и есть о чём поговорить',
          'Тыныш, әдемі және сөйлесетін тақырып көп',
        ),
        goodFor: const {Occasion.date, Occasion.solo, Occasion.friends},
        vibes: const {Vibe.calm, Vibe.beautiful},
        location: const GeoPoint(51.1391, 71.4108),
      ),
    ];
  }
}
