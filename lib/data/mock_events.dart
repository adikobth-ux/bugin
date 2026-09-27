import 'package:bugin/core/app_images.dart';
import 'package:bugin/data/mock_places.dart';
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

  static List<Event> build({DateTime? now}) {
    final n = now ?? DateTime.now();
    DateTime at(int dayOffset, int hour, int minute) =>
        DateTime(n.year, n.month, n.day + dayOffset, hour, minute);

    // Ближайшая суббота (сегодня, если сегодня суббота) и воскресенье после неё.
    final toSaturday = (DateTime.saturday - n.weekday) % 7;
    final toSunday = (DateTime.sunday - n.weekday) % 7;

    return [
      Event(
        id: neonNights,
        title: 'Neon Nights',
        subtitle: 'Живой концерт электро-поп группы',
        description:
            'Neon Nights впервые выступают в Астане с новой программой: синтезаторы, '
            'живые барабаны и световое шоу. Два с половиной часа музыки без перерыва.',
        category: EventCategory.concert,
        startsAt: at(toSaturday, 20, 0),
        durationMinutes: 150,
        venueName: 'Sky Arena',
        address: 'пр. Туран, 50',
        location: const GeoPoint(51.1102, 71.4029),
        distanceKm: 4.2,
        priceFrom: 12000,
        image: AppImages.neonNights,
        tags: const ['Электро-поп', 'Живой звук', 'Танцпол'],
        ageLimit: 16,
        tickets: const [
          TicketCategory('Танцпартер', 12000),
          TicketCategory('Трибуна', 15000),
          TicketCategory('VIP', 30000),
        ],
        pitch: 'Живой звук и световое шоу',
        reasons: const [
          'Концерты — в твоих интересах',
          'Живой звук и световое шоу',
          'Хорошо для вечера с друзьями',
        ],
        occasions: const {Occasion.friends, Occasion.date},
        vibes: const {Vibe.active},
        isFeatured: true,
      ),
      Event(
        id: rooftopAcoustic,
        title: 'Акустика на крыше',
        subtitle: 'Живая музыка под открытым небом',
        description:
            'Камерный акустический концерт на крыше лофта: гитара, голос и виды на '
            'вечерний город. Пледы и горячий чай — на месте.',
        category: EventCategory.concert,
        startsAt: at(0, 20, 0),
        durationMinutes: 120,
        venueName: 'Лофт «Кенес»',
        address: 'ул. Сарайшык, 5',
        location: const GeoPoint(51.1297, 71.4156),
        distanceKm: 2.4,
        priceFrom: 5000,
        image: AppImages.rooftopAcoustic,
        tags: const ['Акустика', 'Под открытым небом'],
        ageLimit: 12,
        tickets: const [TicketCategory('Входной билет', 5000)],
        pitch: 'Камерно и красиво — вид на вечерний город',
        reasons: const [
          'Камерная атмосфера без толпы',
          'Билет от 5 000 ₸ — в твоём бюджете',
          'Красивый вид на вечерний город',
        ],
        occasions: const {Occasion.date, Occasion.friends, Occasion.solo},
        vibes: const {Vibe.beautiful, Vibe.calm},
      ),
      Event(
        id: steppeWind,
        title: 'Премьера «Степной ветер»',
        subtitle: 'Драма о большой дороге домой',
        description:
            'Новый фильм о путешествии через степь и возвращении домой. Показ в зале '
            'IMAX, после сеанса — короткая встреча с режиссёром.',
        category: EventCategory.cinema,
        startsAt: at(0, 21, 30),
        durationMinutes: 125,
        venueName: 'Luna Cinema',
        address: 'ул. Сыганак, 10',
        location: const GeoPoint(51.1219, 71.4282),
        distanceKm: 1.9,
        priceFrom: 2500,
        image: AppImages.lunaCinema,
        tags: const ['Драма', 'Премьера', 'IMAX'],
        ageLimit: 16,
        tickets: const [
          TicketCategory('Стандарт', 2500),
          TicketCategory('Комфорт', 3500),
        ],
        pitch: 'Премьера в IMAX и встреча с режиссёром',
        reasons: const [
          'Премьера — первые показы в городе',
          'Кино вдвоём — классика вечера',
          'Билет от 2 500 ₸',
        ],
        occasions: const {Occasion.date, Occasion.friends, Occasion.solo},
        vibes: const {Vibe.calm},
        venuePlaceId: MockPlaces.lunaCinema,
      ),
      Event(
        id: artEvening,
        title: 'Арт-вечер: живопись',
        subtitle: 'Мастер-класс для новичков',
        description:
            'Пишем картину маслом под руководством художника. Все материалы включены, '
            'опыт не нужен — результат забираете с собой.',
        category: EventCategory.workshop,
        startsAt: at(0, 19, 0),
        durationMinutes: 120,
        venueName: 'Студия «Холст»',
        address: 'ул. Кенесары, 40',
        location: const GeoPoint(51.1357, 71.4412),
        distanceKm: 2.1,
        priceFrom: 7000,
        image: AppImages.holstStudio,
        tags: const ['Для двоих', 'Все материалы', 'Опыт не нужен'],
        ageLimit: 14,
        tickets: const [TicketCategory('Участие', 7000)],
        pitch: 'Необычный вариант для двоих — опыт не нужен',
        reasons: const [
          'Необычный формат для свидания',
          'Все материалы уже включены',
          'Картину заберёте с собой',
        ],
        occasions: const {Occasion.date, Occasion.friends, Occasion.solo},
        vibes: const {Vibe.novelty, Vibe.calm},
        venuePlaceId: MockPlaces.holstStudio,
      ),
      Event(
        id: cityOfLight,
        title: 'Выставка «Город света»',
        subtitle: 'Ночная фотография мегаполисов',
        description:
            'Фотографии ночных городов мира: неон, отражения и длинная выдержка. '
            'По вечерам работает аудиогид.',
        category: EventCategory.exhibition,
        startsAt: at(0, 10, 0),
        durationMinutes: 720,
        venueName: 'Галерея «Бастау»',
        address: 'ул. Бейбитшилик, 18',
        location: const GeoPoint(51.1391, 71.4108),
        distanceKm: 3.0,
        priceFrom: 3000,
        image: AppImages.bastauGallery,
        tags: const ['Фотография', 'Современное искусство'],
        ageLimit: 0,
        tickets: const [TicketCategory('Входной билет', 3000)],
        pitch: 'Тихо, красиво и есть о чём поговорить',
        reasons: const [
          'Спокойный формат без спешки',
          'Можно прийти в любое время до 22:00',
          'Билет 3 000 ₸',
        ],
        occasions: const {Occasion.date, Occasion.solo, Occasion.friends},
        vibes: const {Vibe.calm, Vibe.beautiful},
        venuePlaceId: MockPlaces.bastauGallery,
      ),
      Event(
        id: jazz,
        title: 'Джаз на веранде',
        subtitle: 'Трио живого джаза',
        description:
            'Живой джаз на веранде The Garden: трио, лёгкие стандарты и авторские '
            'композиции. Столы у сцены лучше бронировать.',
        category: EventCategory.concert,
        startsAt: at(1, 19, 30),
        durationMinutes: 120,
        venueName: 'The Garden',
        address: 'ул. Абая, 57',
        location: const GeoPoint(51.1283, 71.4305),
        distanceKm: 1.5,
        priceFrom: 3000,
        image: AppImages.theGardenHall,
        tags: const ['Джаз', 'Живой звук'],
        ageLimit: 0,
        tickets: const [TicketCategory('Вход', 3000)],
        pitch: 'Живой джаз и ужин в одном месте',
        reasons: const [
          'Ужин и музыка без переездов',
          'Вход 3 000 ₸',
          'Спокойная атмосфера',
        ],
        occasions: const {Occasion.date, Occasion.friends},
        vibes: const {Vibe.calm, Vibe.beautiful},
        venuePlaceId: MockPlaces.theGarden,
      ),
      Event(
        id: standup,
        title: 'Стендап «Свои люди»',
        subtitle: 'Вечер открытого микрофона',
        description:
            'Молодые комики пробуют новый материал. Формат открытого микрофона: '
            'восемь выступлений по десять минут.',
        category: EventCategory.standup,
        startsAt: at(1, 20, 0),
        durationMinutes: 100,
        venueName: 'Бар «Сцена»',
        address: 'ул. Достык, 9',
        location: const GeoPoint(51.1271, 71.4459),
        distanceKm: 2.8,
        priceFrom: 4000,
        image: '',
        tags: const ['Юмор', 'Открытый микрофон'],
        ageLimit: 18,
        tickets: const [TicketCategory('Вход', 4000)],
        pitch: 'Посмеяться компанией',
        reasons: const [
          'Весёлый вечер с друзьями',
          'Билет 4 000 ₸',
        ],
        occasions: const {Occasion.friends},
        vibes: const {Vibe.active, Vibe.novelty},
      ),
      Event(
        id: seagull,
        title: 'Спектакль «Чайка»',
        subtitle: 'Классика в камерном зале',
        description:
            'Пьеса Чехова в современной постановке камерного театра. Зал на 80 мест, '
            'зрители сидят совсем близко к сцене.',
        category: EventCategory.theatre,
        startsAt: at(toSunday, 18, 0),
        durationMinutes: 150,
        venueName: 'Камерный театр «Арка»',
        address: 'ул. Иманова, 11',
        location: const GeoPoint(51.1702, 71.4203),
        distanceKm: 3.4,
        priceFrom: 6000,
        image: '',
        tags: const ['Классика', 'Камерный зал'],
        ageLimit: 12,
        tickets: const [
          TicketCategory('Партер', 6000),
          TicketCategory('Первые ряды', 9000),
        ],
        pitch: 'Классика совсем близко к сцене',
        reasons: const [
          'Камерный зал на 80 мест',
          'Классика в современной постановке',
        ],
        occasions: const {Occasion.date, Occasion.solo, Occasion.family},
        vibes: const {Vibe.calm, Vibe.beautiful},
      ),
    ];
  }
}
