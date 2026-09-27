/// Координаты. Пока нужны только для будущей карты и маршрутов.
class GeoPoint {
  const GeoPoint(this.lat, this.lng);

  factory GeoPoint.fromJson(Map<String, dynamic> json) => GeoPoint(
        (json['lat'] as num).toDouble(),
        (json['lng'] as num).toDouble(),
      );

  final double lat;
  final double lng;

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

/// Повод — для чего человек ищет место.
enum Occasion {
  date('Свидание'),
  friends('С друзьями'),
  work('Поработать'),
  family('С семьёй'),
  solo('Для себя');

  const Occasion(this.label);

  final String label;

  static Occasion? tryParse(String? name) {
    for (final value in Occasion.values) {
      if (value.name == name) {
        return value;
      }
    }
    return null;
  }
}

/// Настроение места или события. Коды совпадают с кодами параметров поиска.
enum Vibe {
  beautiful('Красиво'),
  calm('Спокойно'),
  active('Активно'),
  novelty('Что-то новое');

  const Vibe(this.label);

  final String label;

  static Vibe? tryParse(String? name) {
    for (final value in Vibe.values) {
      if (value.name == name) {
        return value;
      }
    }
    return null;
  }
}

Set<T> parseEnumSet<T extends Enum>(Object? raw, T? Function(String?) parse) {
  final result = <T>{};
  if (raw is List) {
    for (final item in raw) {
      final value = parse(item?.toString());
      if (value != null) {
        result.add(value);
      }
    }
  }
  return result;
}

List<String> parseStringList(Object? raw) =>
    raw is List ? raw.map((e) => e.toString()).toList() : const <String>[];
