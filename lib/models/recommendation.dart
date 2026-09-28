import 'package:bugin/models/common.dart';
import 'package:bugin/models/event.dart';
import 'package:bugin/models/place.dart';

enum RecommendationKind {
  place,
  event;

  static RecommendationKind? tryParse(String? name) {
    for (final value in RecommendationKind.values) {
      if (value.name == name) {
        return value;
      }
    }
    return null;
  }
}

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

  /// `kind` говорит, какое из полей `place` / `event` заполнено.
  factory Recommendation.fromJson(Map<String, dynamic> json) {
    final kind = RecommendationKind.tryParse(json['kind'] as String?);
    final place = json['place'];
    final event = json['event'];
    final reason = json['reason'] as String? ?? '';
    final details = parseStringList(json['details']);
    final score = (json['score'] as num? ?? 0).toDouble();
    if (kind != RecommendationKind.event && place is Map<String, dynamic>) {
      return Recommendation.place(
        Place.fromJson(place),
        reason: reason,
        details: details,
        score: score,
      );
    }
    if (kind != RecommendationKind.place && event is Map<String, dynamic>) {
      return Recommendation.event(
        Event.fromJson(event),
        reason: reason,
        details: details,
        score: score,
      );
    }
    throw FormatException('Рекомендация без места и события: ${json['kind']}');
  }

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

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'place': place?.toJson(),
        'event': event?.toJson(),
        'reason': reason,
        'details': details,
        'score': score,
      };
}
