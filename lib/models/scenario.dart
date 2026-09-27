import 'package:bugin/models/common.dart';
import 'package:bugin/models/evening_request.dart';

/// Роль точки в плане — по ней подбираются альтернативы.
enum StopRole {
  coffee,
  walk,
  dinner,
  activity,
  culture,
  novelty,
  work;

  static StopRole parse(String? name) => StopRole.values.firstWhere(
        (r) => r.name == name,
        orElse: () => StopRole.activity,
      );
}

/// Подписи — в `AppStrings.label`.
enum TravelMode {
  walk,
  taxi;

  static TravelMode parse(String? name) => TravelMode.values.firstWhere(
        (m) => m.name == name,
        orElse: () => TravelMode.taxi,
      );
}

class TravelLeg {
  const TravelLeg(this.mode, this.minutes);

  factory TravelLeg.fromJson(Map<String, dynamic> json) => TravelLeg(
        TravelMode.parse(json['mode'] as String?),
        json['minutes'] as int? ?? 10,
      );

  final TravelMode mode;
  final int minutes;

  Map<String, dynamic> toJson() => {'mode': mode.name, 'minutes': minutes};
}

/// Точка плана: место + время.
class PlanStop {
  const PlanStop({
    required this.role,
    required this.placeId,
    required this.kind,
    required this.title,
    required this.kindLabel,
    required this.startMinutes,
    required this.durationMinutes,
    required this.cost,
    this.routeLabel,
    this.rating,
    this.image = '',
  });

  factory PlanStop.fromJson(Map<String, dynamic> json) => PlanStop(
        role: StopRole.parse(json['role'] as String?),
        placeId: json['placeId'] as String,
        kind: json['kind'] as String? ?? '',
        title: json['title'] as String? ?? '',
        kindLabel: json['kindLabel'] as String? ?? '',
        startMinutes: json['startMinutes'] as int? ?? 0,
        durationMinutes: json['durationMinutes'] as int? ?? 60,
        cost: json['cost'] as int? ?? 0,
        routeLabel: json['routeLabel'] as String?,
        rating: (json['rating'] as num?)?.toDouble(),
        image: json['image'] as String? ?? '',
      );

  final StopRole role;
  final String placeId;

  /// Код занятия: `dinner`, `walk`, `bowling`… По нему план переводится
  /// на другой язык и подбираются замены.
  final String kind;
  final String title;

  /// «Кофе и десерт», «Ужин», «Прогулка» — на языке, на котором план собран.
  final String kindLabel;
  final int startMinutes;
  final int durationMinutes;

  /// Стоимость на человека.
  final int cost;

  /// Короткое имя для строки маршрута: «набережная».
  final String? routeLabel;
  final double? rating;
  final String image;

  int get endMinutes => startMinutes + durationMinutes;

  String get shortTitle => routeLabel ?? title;

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'placeId': placeId,
        'kind': kind,
        'title': title,
        'kindLabel': kindLabel,
        'startMinutes': startMinutes,
        'durationMinutes': durationMinutes,
        'cost': cost,
        'routeLabel': routeLabel,
        'rating': rating,
        'image': image,
      };

  PlanStop copyWith({int? startMinutes}) => PlanStop(
        role: role,
        placeId: placeId,
        kind: kind,
        title: title,
        kindLabel: kindLabel,
        startMinutes: startMinutes ?? this.startMinutes,
        durationMinutes: durationMinutes,
        cost: cost,
        routeLabel: routeLabel,
        rating: rating,
        image: image,
      );
}

/// Сценарий — собранный план (вечер или день). Хранится в избранном.
class Scenario {
  const Scenario({
    required this.id,
    required this.title,
    required this.stops,
    required this.legs,
    this.subtitle,
    this.image,
    this.tags = const [],
    this.request,
  });

  factory Scenario.fromJson(Map<String, dynamic> json) {
    final request = json['request'];
    return Scenario(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      image: json['image'] as String?,
      stops: (json['stops'] as List? ?? const [])
          .map((e) => PlanStop.fromJson(e as Map<String, dynamic>))
          .toList(),
      legs: (json['legs'] as List? ?? const [])
          .map((e) => TravelLeg.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: parseStringList(json['tags']),
      request: request is Map<String, dynamic>
          ? EveningRequest.fromJson(request)
          : null,
    );
  }

  final String id;
  final String title;

  /// Если задан — заменяет автоматическую строку маршрута.
  final String? subtitle;
  final String? image;
  final List<PlanStop> stops;

  /// Переезды между точками: legs[i] — от stops[i] к stops[i + 1].
  final List<TravelLeg> legs;
  final List<String> tags;

  /// Параметры, по которым план собран (если собран конструктором).
  final EveningRequest? request;

  int get totalCost => stops.fold<int>(0, (sum, s) => sum + s.cost);

  int get startMinutes => stops.isEmpty ? 0 : stops.first.startMinutes;

  int get endMinutes => stops.isEmpty ? 0 : stops.last.endMinutes;

  int get durationMinutes => endMinutes - startMinutes;

  String get route => subtitle ?? stops.map((s) => s.shortTitle).join(' → ');

  String get cover {
    if (image != null && image!.isNotEmpty) {
      return image!;
    }
    for (final stop in stops) {
      if (stop.image.isNotEmpty) {
        return stop.image;
      }
    }
    return '';
  }

  bool? get fitsBudget {
    final budget = request?.budget;
    if (budget == null) {
      return null;
    }
    return totalCost <= budget;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'image': image,
        'stops': stops.map((s) => s.toJson()).toList(),
        'legs': legs.map((l) => l.toJson()).toList(),
        'tags': tags,
        'request': request?.toJson(),
      };

  Scenario copyWith({
    String? id,
    String? title,
    String? subtitle,
    List<String>? tags,
    List<PlanStop>? stops,
    List<TravelLeg>? legs,
  }) =>
      Scenario(
        id: id ?? this.id,
        title: title ?? this.title,
        stops: stops ?? this.stops,
        legs: legs ?? this.legs,
        subtitle: subtitle ?? this.subtitle,
        image: image,
        tags: tags ?? this.tags,
        request: request,
      );
}
