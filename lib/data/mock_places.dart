import 'package:bugin/core/app_images.dart';
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

  static List<Place> build({DateTime? now}) {
    final today = now ?? DateTime.now();
    DateTime daysAgo(int days) => today.subtract(Duration(days: days));

    return [
      Place(
        id: theGarden,
        name: 'The Garden',
        subtitle: 'Европейская кухня и завтраки весь день',
        description:
            'Уютное кафе в центре города: живая зелень, тёплый свет и европейская '
            'кухня. Днём здесь завтракают и работают, вечером ужинают вдвоём под '
            'тихую музыку. По пятницам — живые акустические сеты.',
        category: PlaceCategory.cafe,
        categoryDetail: 'европейская кухня',
        address: 'ул. Абая, 57',
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
        tags: const ['Европейская кухня', 'Завтраки', 'Кофе', 'Уютная атмосфера'],
        amenities: const [
          PlaceAmenity(AmenityType.wifi, 'Бесплатный'),
          PlaceAmenity(AmenityType.pets, 'Можно'),
          PlaceAmenity(AmenityType.smoking, 'Нельзя'),
          PlaceAmenity(AmenityType.payment, 'Карта, наличные'),
        ],
        distanceKm: 1.5,
        taxiMinutes: 6,
        bookingType: BookingType.table,
        pitch: 'Уютно, живая зелень и тихая музыка',
        goodFor: const {Occasion.date, Occasion.friends, Occasion.solo, Occasion.work},
        vibes: const {Vibe.beautiful, Vibe.calm},
        location: const GeoPoint(51.1283, 71.4305),
        reviews: [
          Review(
            author: 'Алина',
            rating: 5,
            text:
                'Очень уютно вечером, по пятницам живая музыка. Десерты — отдельная '
                'любовь, особенно чизкейк.',
            date: daysAgo(2),
          ),
          Review(
            author: 'Тимур',
            rating: 4.5,
            text:
                'Хорошее место для завтрака и спокойной встречи. В выходные лучше '
                'бронировать стол заранее.',
            date: daysAgo(9),
          ),
          Review(
            author: 'Дана',
            rating: 5,
            text: 'Красиво, тихо и вкусно. Брали пасту и лимонад — всё понравилось.',
            date: daysAgo(21),
          ),
        ],
      ),
      Place(
        id: coffeeLab,
        name: 'Coffee Lab',
        subtitle: 'Спешелти-кофе и домашние десерты',
        description:
            'Кофейня с собственной обжаркой. Большие столы, розетки у каждого места '
            'и тихая музыка — удобно поработать или встретиться за десертом.',
        category: PlaceCategory.coffeeShop,
        categoryDetail: 'десерты',
        address: 'пр. Мангилик Ел, 20',
        phone: '+7 701 555 20 20',
        rating: 4.7,
        reviewsCount: 892,
        priceLevel: 2,
        averageCheck: 4500,
        openingHours: const OpeningHours(7 * 60 + 30, 22 * 60),
        photos: const [AppImages.coffeeLab],
        tags: const ['Кофе', 'Десерты', 'Для работы'],
        amenities: const [
          PlaceAmenity(AmenityType.wifi, 'Бесплатный'),
          PlaceAmenity(AmenityType.sockets, 'У каждого стола'),
          PlaceAmenity(AmenityType.smoking, 'Нельзя'),
          PlaceAmenity(AmenityType.payment, 'Карта, QR'),
        ],
        distanceKm: 1.1,
        taxiMinutes: 5,
        bookingType: BookingType.none,
        pitch: 'Тихо и уютно',
        goodFor: const {Occasion.date, Occasion.work, Occasion.solo, Occasion.friends},
        vibes: const {Vibe.calm},
        location: const GeoPoint(51.1302, 71.4247),
        reviews: [
          Review(
            author: 'Ерлан',
            rating: 5,
            text: 'Лучший флэт уайт в районе, и никто не торопит, если сидишь с ноутбуком.',
            date: daysAgo(4),
          ),
        ],
      ),
      Place(
        id: galaxyBowling,
        name: 'Galaxy Bowling',
        subtitle: 'Боулинг, бильярд и кухня',
        description:
            '12 дорожек с неоновой подсветкой, бильярд и кухня. Хорошо на компанию: '
            'дорожку можно забронировать заранее и не ждать.',
        category: PlaceCategory.bowling,
        categoryDetail: '12 дорожек',
        address: 'ул. Кунаева, 12',
        phone: '+7 702 300 12 12',
        rating: 4.7,
        reviewsCount: 2310,
        priceLevel: 2,
        averageCheck: 4000,
        openingHours: const OpeningHours(12 * 60, 26 * 60),
        photos: const [AppImages.galaxyBowling],
        tags: const ['Боулинг', 'Друзья', 'Музыка'],
        amenities: const [
          PlaceAmenity(AmenityType.parking, 'Бесплатная'),
          PlaceAmenity(AmenityType.payment, 'Карта, наличные'),
          PlaceAmenity(AmenityType.smoking, 'Нельзя'),
          PlaceAmenity(AmenityType.wifi, 'Бесплатный'),
        ],
        distanceKm: 1.2,
        taxiMinutes: 5,
        bookingType: BookingType.lane,
        pitch: 'Весело и динамично',
        goodFor: const {Occasion.friends, Occasion.family, Occasion.date},
        vibes: const {Vibe.active},
        location: const GeoPoint(51.1265, 71.4371),
        reviews: [
          Review(
            author: 'Марат',
            rating: 4.5,
            text: 'Отмечали день рождения — дорожки новые, музыка громкая, кухня норм.',
            date: daysAgo(6),
          ),
        ],
      ),
      Place(
        id: skyLounge,
        name: 'Sky Lounge',
        subtitle: 'Ресторан с панорамным видом на город',
        description:
            'Ресторан на 24 этаже с панорамными окнами. Лучшие места — у окна на '
            'закате, их стоит бронировать заранее.',
        category: PlaceCategory.restaurant,
        categoryDetail: '24 этаж',
        address: 'пр. Туран, 37',
        phone: '+7 705 240 24 24',
        rating: 4.6,
        reviewsCount: 1210,
        priceLevel: 3,
        averageCheck: 8000,
        openingHours: const OpeningHours(12 * 60, 24 * 60),
        photos: const [AppImages.skyLounge],
        tags: const ['Панорамный вид', 'Коктейли', 'Ужин'],
        amenities: const [
          PlaceAmenity(AmenityType.wifi, 'Бесплатный'),
          PlaceAmenity(AmenityType.smoking, 'На террасе'),
          PlaceAmenity(AmenityType.payment, 'Карта'),
          PlaceAmenity(AmenityType.parking, 'Подземная'),
        ],
        distanceKm: 1.8,
        taxiMinutes: 8,
        bookingType: BookingType.table,
        pitch: 'Панорамный вид на город — красиво вечером',
        goodFor: const {Occasion.date, Occasion.friends},
        vibes: const {Vibe.beautiful},
        location: const GeoPoint(51.1244, 71.4198),
        reviews: [
          Review(
            author: 'Айгерим',
            rating: 5,
            text: 'Вид потрясающий, особенно на закате. Цены выше среднего, но оно того стоит.',
            date: daysAgo(3),
          ),
        ],
      ),
      Place(
        id: lunaCinema,
        name: 'Luna Cinema',
        subtitle: 'Кинотеатр с залом IMAX',
        description:
            'Современный кинотеатр с удобными креслами и залом IMAX. Вечерние сеансы '
            'начинаются в 20:00 и 21:30.',
        category: PlaceCategory.cinema,
        categoryDetail: '8 залов',
        address: 'ул. Сыганак, 10',
        phone: '+7 707 111 70 70',
        rating: 4.5,
        reviewsCount: 2280,
        priceLevel: 2,
        averageCheck: 5000,
        openingHours: const OpeningHours(10 * 60, 26 * 60),
        photos: const [AppImages.lunaCinema],
        tags: const ['Кино', 'Премьеры', 'IMAX'],
        amenities: const [
          PlaceAmenity(AmenityType.parking, 'Бесплатная'),
          PlaceAmenity(AmenityType.payment, 'Карта, наличные'),
        ],
        distanceKm: 1.9,
        taxiMinutes: 8,
        bookingType: BookingType.ticket,
        pitch: 'Вечерние сеансы в 20:00 и 21:30',
        goodFor: const {Occasion.date, Occasion.friends, Occasion.family},
        vibes: const {Vibe.calm},
        location: const GeoPoint(51.1219, 71.4282),
        reviews: [
          Review(
            author: 'Нурлан',
            rating: 4.5,
            text: 'Зал IMAX отличный, кресла удобные. Попкорн дорогой, как везде.',
            date: daysAgo(12),
          ),
        ],
      ),
      Place(
        id: esilEmbankment,
        name: 'Набережная Есиля',
        subtitle: 'Прогулочная зона вдоль реки',
        description:
            'Прогулочная зона вдоль реки: вечерняя подсветка, скамейки и виды на '
            'город. Удобно пройтись между ужином и кино.',
        category: PlaceCategory.park,
        categoryDetail: 'прогулка',
        address: 'Набережная Есиля',
        phone: '',
        rating: 4.9,
        reviewsCount: 3120,
        priceLevel: 1,
        averageCheck: 0,
        openingHours: const OpeningHours.always(),
        photos: const [],
        tags: const ['Прогулка', 'Виды', 'Бесплатно'],
        amenities: const [],
        distanceKm: 0.9,
        taxiMinutes: 4,
        bookingType: BookingType.none,
        pitch: 'Красивые виды и огни вечером',
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
        name: 'Студия «Холст»',
        subtitle: 'Мастер-классы по живописи для новичков',
        description:
            'Творческая студия, где проводят мастер-классы по живописи для новичков. '
            'Все материалы включены, картину забираете с собой.',
        category: PlaceCategory.studio,
        categoryDetail: 'мастер-классы',
        address: 'ул. Кенесары, 40',
        phone: '+7 708 456 78 90',
        rating: 4.9,
        reviewsCount: 346,
        priceLevel: 2,
        averageCheck: 7000,
        openingHours: const OpeningHours(11 * 60, 22 * 60),
        photos: const [AppImages.holstStudio],
        tags: const ['Для двоих', 'Все материалы', 'Опыт не нужен'],
        amenities: const [
          PlaceAmenity(AmenityType.payment, 'Карта, наличные'),
          PlaceAmenity(AmenityType.wifi, 'Бесплатный'),
        ],
        distanceKm: 2.1,
        taxiMinutes: 9,
        bookingType: BookingType.ticket,
        pitch: 'Необычный вариант для двоих — опыт не нужен',
        goodFor: const {Occasion.date, Occasion.friends, Occasion.solo},
        vibes: const {Vibe.novelty, Vibe.calm},
        location: const GeoPoint(51.1357, 71.4412),
      ),
      Place(
        id: bastauGallery,
        name: 'Галерея «Бастау»',
        subtitle: 'Современное искусство и фотография',
        description:
            'Небольшая галерея современного искусства и фотографии. Выставки '
            'меняются раз в месяц, по четвергам — бесплатные экскурсии.',
        category: PlaceCategory.gallery,
        categoryDetail: 'современное искусство',
        address: 'ул. Бейбитшилик, 18',
        phone: '+7 747 310 31 31',
        rating: 4.6,
        reviewsCount: 518,
        priceLevel: 1,
        averageCheck: 3000,
        openingHours: const OpeningHours(10 * 60, 22 * 60),
        photos: const [AppImages.bastauGallery],
        tags: const ['Выставки', 'Фотография'],
        amenities: const [
          PlaceAmenity(AmenityType.payment, 'Карта'),
        ],
        distanceKm: 3.0,
        taxiMinutes: 11,
        bookingType: BookingType.ticket,
        pitch: 'Тихо, красиво и есть о чём поговорить',
        goodFor: const {Occasion.date, Occasion.solo, Occasion.friends},
        vibes: const {Vibe.calm, Vibe.beautiful},
        location: const GeoPoint(51.1391, 71.4108),
      ),
    ];
  }
}
