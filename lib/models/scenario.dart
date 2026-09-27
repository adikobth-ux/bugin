import 'package:bugin/models/evening_request.dart';

/// Роль точки в плане — по ней подбираются альтернативы.
enum StopRole { coffee, walk, dinner, activity, culture, novelty, work }

enum TravelMode {
  walk('Пешком'),
  taxi('На такси');

  const TravelMode(this.label);

  final String label;
}

class TravelLeg {
  const TravelLeg(this.mode, this.minutes);

  final TravelMode mode;
  final int minutes;
}

/// Точка плана: место + время.
class PlanStop {
  const PlanStop({
    required this.role,
    required this.placeId,
    required this.title,
    required this.kindLabel,
    required this.startMinutes,
    required this.durationMinutes,
    required this.cost,
    this.routeLabel,
    this.rating,
    this.image = '',
  });

  final StopRole role;
  final String placeId;
  final String title;

  /// «Кофе и десерт», «Ужин», «Прогулка».
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

  PlanStop copyWith({int? startMinutes}) => PlanStop(
        role: role,
        placeId: placeId,
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

  Scenario copyWith({
    String? id,
    String? title,
    List<PlanStop>? stops,
    List<TravelLeg>? legs,
  }) =>
      Scenario(
        id: id ?? this.id,
        title: title ?? this.title,
        stops: stops ?? this.stops,
        legs: legs ?? this.legs,
        subtitle: subtitle,
        image: image,
        tags: tags,
        request: request,
      );
}
