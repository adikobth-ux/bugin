import 'package:bugin/models/common.dart';

/// Подписи — в `AppStrings.label` и `AppStrings.eventCategoryPlural`.
enum EventCategory {
  concert,
  cinema,
  theatre,
  exhibition,
  workshop,
  standup;

  static EventCategory parse(String? name) => EventCategory.values.firstWhere(
        (c) => c.name == name,
        orElse: () => EventCategory.concert,
      );
}

/// Фильтр дней в афише.
enum EventDayFilter { today, tomorrow, weekend, date }

class TicketCategory {
  const TicketCategory(this.name, this.price);

  factory TicketCategory.fromJson(Map<String, dynamic> json) =>
      TicketCategory(json['name'] as String, json['price'] as int);

  final String name;
  final int price;

  Map<String, dynamic> toJson() => {'name': name, 'price': price};
}

class Event {
  const Event({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.startsAt,
    required this.durationMinutes,
    required this.venueName,
    required this.address,
    required this.location,
    required this.distanceKm,
    required this.priceFrom,
    required this.image,
    required this.tags,
    required this.ageLimit,
    required this.tickets,
    required this.pitch,
    required this.reasons,
    required this.occasions,
    required this.vibes,
    this.venuePlaceId,
    this.isFeatured = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String? ?? '',
        description: json['description'] as String? ?? '',
        category: EventCategory.parse(json['category'] as String?),
        startsAt: DateTime.parse(json['startsAt'] as String),
        durationMinutes: json['durationMinutes'] as int? ?? 120,
        venueName: json['venueName'] as String? ?? '',
        address: json['address'] as String? ?? '',
        location: GeoPoint.fromJson(json['location'] as Map<String, dynamic>),
        distanceKm: (json['distanceKm'] as num? ?? 0).toDouble(),
        priceFrom: json['priceFrom'] as int? ?? 0,
        image: json['image'] as String? ?? '',
        tags: parseStringList(json['tags']),
        ageLimit: json['ageLimit'] as int? ?? 0,
        tickets: (json['tickets'] as List? ?? const [])
            .map((e) => TicketCategory.fromJson(e as Map<String, dynamic>))
            .toList(),
        pitch: json['pitch'] as String? ?? '',
        reasons: parseStringList(json['reasons']),
        occasions: parseEnumSet(json['occasions'], Occasion.tryParse),
        vibes: parseEnumSet(json['vibes'], Vibe.tryParse),
        venuePlaceId: json['venuePlaceId'] as String?,
        isFeatured: json['isFeatured'] as bool? ?? false,
      );

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final EventCategory category;
  final DateTime startsAt;
  final int durationMinutes;
  final String venueName;
  final String address;
  final GeoPoint location;
  final double distanceKm;
  final int priceFrom;
  final String image;
  final List<String> tags;
  final int ageLimit;
  final List<TicketCategory> tickets;

  /// Короткая «фишка» события для объяснений AI.
  final String pitch;

  /// Персональные причины «Почему тебе понравится» (с backend придут готовыми).
  final List<String> reasons;
  final Set<Occasion> occasions;
  final Set<Vibe> vibes;

  /// Если событие проходит в месте из каталога.
  final String? venuePlaceId;
  final bool isFeatured;

  DateTime get endsAt => startsAt.add(Duration(minutes: durationMinutes));

  /// Выставки и другие события «весь день».
  bool get isLongRunning => durationMinutes >= 360;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'category': category.name,
        'startsAt': startsAt.toIso8601String(),
        'durationMinutes': durationMinutes,
        'venueName': venueName,
        'address': address,
        'location': location.toJson(),
        'distanceKm': distanceKm,
        'priceFrom': priceFrom,
        'image': image,
        'tags': tags,
        'ageLimit': ageLimit,
        'tickets': tickets.map((t) => t.toJson()).toList(),
        'pitch': pitch,
        'reasons': reasons,
        'occasions': occasions.map((o) => o.name).toList(),
        'vibes': vibes.map((v) => v.name).toList(),
        'venuePlaceId': venuePlaceId,
        'isFeatured': isFeatured,
      };
}
