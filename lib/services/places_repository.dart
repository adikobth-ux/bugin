import 'package:bugin/models/models.dart';

/// Источник мест. Сейчас — mock, позже — REST API.
abstract interface class PlacesRepository {
  /// Места рядом для главной.
  Future<List<Place>> nearby({int limit = 6});

  Future<Place> byId(String id);

  /// Места по списку id в том же порядке (неизвестные id пропускаются).
  Future<List<Place>> byIds(List<String> ids);
}
