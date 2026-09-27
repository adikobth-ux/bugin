import 'package:bugin/data/mock_places.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/services/mock/simulated_network.dart';
import 'package:bugin/services/places_repository.dart';

class MockPlacesRepository implements PlacesRepository {
  MockPlacesRepository(this._places, {required this.latency});

  final List<Place> _places;
  final Duration latency;

  Place? _find(String id) {
    for (final place in _places) {
      if (place.id == id) {
        return place;
      }
    }
    return null;
  }

  @override
  Future<List<Place>> nearby({int limit = 6}) => simulateNetwork(latency, () {
        final result = <Place>[];
        for (final id in MockPlaces.nearbyOrder) {
          final place = _find(id);
          if (place != null) {
            result.add(place);
          }
        }
        return result.take(limit).toList();
      });

  @override
  Future<Place> byId(String id) => simulateNetwork(latency, () {
        final place = _find(id);
        if (place == null) {
          throw StateError('Место $id не найдено');
        }
        return place;
      });

  @override
  Future<List<Place>> byIds(List<String> ids) => simulateNetwork(latency, () {
        final result = <Place>[];
        for (final id in ids) {
          final place = _find(id);
          if (place != null) {
            result.add(place);
          }
        }
        return result;
      });
}
