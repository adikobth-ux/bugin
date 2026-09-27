import 'package:bugin/models/event.dart';
import 'package:bugin/models/place.dart';

enum RecommendationKind { place, event }

/// Элемент выдачи: место или событие + объяснение, почему оно подходит.
class Recommendation {
  const Recommendation.place(
    Place value, {
    required this.reason,
    this.details = const [],
    this.score = 0,
  })  : kind = RecommendationKind.place,
        place = value,
        event = null;

  const Recommendation.event(
    Event value, {
    required this.reason,
    this.details = const [],
    this.score = 0,
  })  : kind = RecommendationKind.event,
        event = value,
        place = null;

  final RecommendationKind kind;
  final Place? place;
  final Event? event;

  /// Одна строка для карточки в выдаче.
  final String reason;

  /// Развёрнутые причины для карточки места.
  final List<String> details;
  final double score;

  String get id => place?.id ?? event!.id;

  String get title => place?.name ?? event!.title;

  String get image => place?.cover ?? event!.image;

  double get distanceKm => place?.distanceKm ?? event!.distanceKm;

  /// Цена на человека: средний чек места или минимальная цена билета.
  int get price => place?.averageCheck ?? event!.priceFrom;

  double get rating => place?.rating ?? 0;
}
