import 'package:bugin/models/common.dart';
import 'package:bugin/models/review.dart';

/// Подписи категорий, удобств и других справочников — в `AppStrings.label`.
enum PlaceCategory {
  cafe,
  coffeeShop,
  restaurant,
  bowling,
  cinema,
  park,
  gallery,
  studio;

  static PlaceCategory parse(String? name) => PlaceCategory.values.firstWhere(
        (c) => c.name == name,
        orElse: () => PlaceCategory.cafe,
      );
}

enum AmenityType {
  wifi,
  sockets,
  pets,
  smoking,
  payment,
  parking;

  static AmenityType parse(String? name) => AmenityType.values.firstWhere(
        (a) => a.name == name,
        orElse: () => AmenityType.wifi,
      );
}

/// Как можно «попасть» в место — от этого зависит главная кнопка карточки.
enum BookingType {
  table,
  ticket,
  lane,
  none;

  static BookingType parse(String? name) => BookingType.values.firstWhere(
        (b) => b.name == name,
        orElse: () => BookingType.none,
      );
}

class PlaceAmenity {
  const PlaceAmenity(this.type, this.value);

  factory PlaceAmenity.fromJson(Map<String, dynamic> json) => PlaceAmenity(
        AmenityType.parse(json['type'] as String?),
        json['value'] as String,
      );

  final AmenityType type;
  final String value;

  Map<String, dynamic> toJson() => {'type': type.name, 'value': value};
}

/// Часы работы в минутах от начала суток. [closesAt] может быть больше 1440,
/// если место закрывается после полуночи.
class OpeningHours {
  const OpeningHours(this.opensAt, this.closesAt);

  const OpeningHours.always()
      : opensAt = 0,
        closesAt = 1440;

  factory OpeningHours.fromJson(Map<String, dynamic> json) => OpeningHours(
        json['opensAt'] as int,
        json['closesAt'] as int,
      );

  final int opensAt;
  final int closesAt;

  bool get isAlwaysOpen => opensAt == 0 && closesAt >= 1440;

  bool isOpenAt(DateTime moment) {
    if (isAlwaysOpen) {
      return true;
    }
    final m = moment.hour * 60 + moment.minute;
    if (closesAt <= 1440) {
      return m >= opensAt && m < closesAt;
    }
    return m >= opensAt || m < closesAt - 1440;
  }

  bool isOpenAtMinute(int minuteOfDay) {
    final now = DateTime.now();
    return isOpenAt(
      DateTime(now.year, now.month, now.day, minuteOfDay ~/ 60, minuteOfDay % 60),
    );
  }

  Map<String, dynamic> toJson() => {'opensAt': opensAt, 'closesAt': closesAt};
}

class Place {
  const Place({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.categoryDetail,
    required this.address,
    required this.phone,
    required this.rating,
    required this.reviewsCount,
    required this.priceLevel,
    required this.averageCheck,
    required this.openingHours,
    required this.photos,
    required this.tags,
    required this.amenities,
    required this.distanceKm,
    required this.taxiMinutes,
    required this.bookingType,
    required this.pitch,
    required this.goodFor,
    required this.vibes,
    required this.location,
    this.reviews = const [],
    this.bookingUrl,
  });

  factory Place.fromJson(Map<String, dynamic> json) => Place(
        id: json['id'] as String,
        name: json['name'] as String,
        subtitle: json['subtitle'] as String? ?? '',
        description: json['description'] as String? ?? '',
        category: PlaceCategory.parse(json['category'] as String?),
        categoryDetail: json['categoryDetail'] as String? ?? '',
        address: json['address'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        rating: (json['rating'] as num? ?? 0).toDouble(),
        reviewsCount: json['reviewsCount'] as int? ?? 0,
        priceLevel: json['priceLevel'] as int? ?? 1,
        averageCheck: json['averageCheck'] as int? ?? 0,
        openingHours: OpeningHours.fromJson(
          json['openingHours'] as Map<String, dynamic>,
        ),
        photos: parseStringList(json['photos']),
        tags: parseStringList(json['tags']),
        amenities: (json['amenities'] as List? ?? const [])
            .map((e) => PlaceAmenity.fromJson(e as Map<String, dynamic>))
            .toList(),
        distanceKm: (json['distanceKm'] as num? ?? 0).toDouble(),
        taxiMinutes: json['taxiMinutes'] as int? ?? 0,
        bookingType: BookingType.parse(json['bookingType'] as String?),
        pitch: json['pitch'] as String? ?? '',
        goodFor: parseEnumSet(json['goodFor'], Occasion.tryParse),
        vibes: parseEnumSet(json['vibes'], Vibe.tryParse),
        location: GeoPoint.fromJson(json['location'] as Map<String, dynamic>),
        reviews: (json['reviews'] as List? ?? const [])
            .map((e) => Review.fromJson(e as Map<String, dynamic>))
            .toList(),
        bookingUrl: json['bookingUrl'] as String?,
      );

  final String id;
  final String name;

  /// Короткая строка под названием: «Европейская кухня и завтраки весь день».
  final String subtitle;
  final String description;
  final PlaceCategory category;

  /// Уточнение категории: «европейская кухня», «24 этаж».
  final String categoryDetail;
  final String address;
  final String phone;
  final double rating;
  final int reviewsCount;

  /// 1–4, как «₸», «₸₸» и т.д.
  final int priceLevel;

  /// Средний чек на человека в тенге.
  final int averageCheck;
  final OpeningHours openingHours;

  /// Первое фото — обложка.
  final List<String> photos;
  final List<String> tags;
  final List<PlaceAmenity> amenities;
  final double distanceKm;
  final int taxiMinutes;
  final BookingType bookingType;

  /// Главная «фишка» места — из неё собираются объяснения рекомендаций.
  final String pitch;
  final Set<Occasion> goodFor;
  final Set<Vibe> vibes;
  final GeoPoint location;
  final List<Review> reviews;

  /// Где купить билет или забронировать у самого заведения или оператора
  /// (для кинотеатра — Kino.kz). Bugin сам ничего не продаёт.
  final String? bookingUrl;

  String get cover => photos.isEmpty ? '' : photos.first;

  bool get isFree => averageCheck == 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subtitle': subtitle,
        'description': description,
        'category': category.name,
        'categoryDetail': categoryDetail,
        'address': address,
        'phone': phone,
        'rating': rating,
        'reviewsCount': reviewsCount,
        'priceLevel': priceLevel,
        'averageCheck': averageCheck,
        'openingHours': openingHours.toJson(),
        'photos': photos,
        'tags': tags,
        'amenities': amenities.map((a) => a.toJson()).toList(),
        'distanceKm': distanceKm,
        'taxiMinutes': taxiMinutes,
        'bookingType': bookingType.name,
        'pitch': pitch,
        'goodFor': goodFor.map((o) => o.name).toList(),
        'vibes': vibes.map((v) => v.name).toList(),
        'location': location.toJson(),
        'reviews': reviews.map((r) => r.toJson()).toList(),
        'bookingUrl': bookingUrl,
      };
}
