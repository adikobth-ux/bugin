import 'package:bugin/models/models.dart';
import 'package:bugin/services/api/api_client.dart';
import 'package:bugin/services/places_repository.dart';

/// Места с сервера: `GET /v1/places…` (контракт — docs/api.md в bugin-backend).
class ApiPlacesRepository implements PlacesRepository {
  ApiPlacesRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<Place>> nearby({int limit = 6}) async => _places(
        await _api.get('/v1/places/nearby', query: {'limit': '$limit'}),
      );

  /// Неизвестный id — [ApiException] с кодом `not_found`.
  @override
  Future<Place> byId(String id) async => Place.fromJson(
        jsonObject(await _api.get('/v1/places/${Uri.encodeComponent(id)}')),
      );

  @override
  Future<List<Place>> byIds(List<String> ids) async {
    // Пустой список не запрашиваем — ответ и так известен.
    if (ids.isEmpty) {
      return <Place>[];
    }
    return _places(await _api.get('/v1/places', query: {'ids': ids.join(',')}));
  }

  static List<Place> _places(Object? json) =>
      jsonList(json).map(Place.fromJson).toList();
}
