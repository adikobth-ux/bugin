import 'package:flutter/foundation.dart';

import 'package:bugin/models/models.dart';

enum FavoriteKind { place, event, scenario }

/// Избранное: места, события и сохранённые сценарии.
///
/// Сейчас живёт в памяти. Для backend достаточно подключить сохранение
/// в методах изменения — экраны слушают этот объект и ничего не заметят.
class FavoritesStore extends ChangeNotifier {
  FavoritesStore({
    Iterable<String> placeIds = const [],
    Iterable<String> eventIds = const [],
    Iterable<Scenario> scenarios = const [],
  })  : _placeIds = List.of(placeIds),
        _eventIds = List.of(eventIds),
        _scenarios = List.of(scenarios);

  final List<String> _placeIds;
  final List<String> _eventIds;
  final List<Scenario> _scenarios;

  List<String> get placeIds => List.unmodifiable(_placeIds);
  List<String> get eventIds => List.unmodifiable(_eventIds);
  List<Scenario> get scenarios => List.unmodifiable(_scenarios);

  int count(FavoriteKind kind) => switch (kind) {
        FavoriteKind.place => _placeIds.length,
        FavoriteKind.event => _eventIds.length,
        FavoriteKind.scenario => _scenarios.length,
      };

  List<String> _ids(FavoriteKind kind) => switch (kind) {
        FavoriteKind.place => _placeIds,
        FavoriteKind.event => _eventIds,
        FavoriteKind.scenario => _scenarios.map((s) => s.id).toList(),
      };

  bool isFavorite(FavoriteKind kind, String id) => _ids(kind).contains(id);

  /// Переключает место или событие. Возвращает новое состояние.
  bool toggle(FavoriteKind kind, String id) {
    assert(kind != FavoriteKind.scenario, 'Сценарии сохраняются через saveScenario');
    final ids = kind == FavoriteKind.place ? _placeIds : _eventIds;
    final bool active;
    if (ids.contains(id)) {
      ids.remove(id);
      active = false;
    } else {
      ids.insert(0, id);
      active = true;
    }
    notifyListeners();
    return active;
  }

  /// Удаляет и возвращает позицию — для «Вернуть».
  int remove(FavoriteKind kind, String id) {
    final index = switch (kind) {
      FavoriteKind.place => _placeIds.indexOf(id),
      FavoriteKind.event => _eventIds.indexOf(id),
      FavoriteKind.scenario => _scenarios.indexWhere((s) => s.id == id),
    };
    if (index >= 0) {
      switch (kind) {
        case FavoriteKind.place:
          _placeIds.removeAt(index);
        case FavoriteKind.event:
          _eventIds.removeAt(index);
        case FavoriteKind.scenario:
          _scenarios.removeAt(index);
      }
      notifyListeners();
    }
    return index;
  }

  void restore(FavoriteKind kind, String id, int index) {
    assert(kind != FavoriteKind.scenario, 'Для сценариев — restoreScenario');
    final ids = kind == FavoriteKind.place ? _placeIds : _eventIds;
    if (ids.contains(id)) {
      return;
    }
    ids.insert(index.clamp(0, ids.length).toInt(), id);
    notifyListeners();
  }

  bool hasScenario(String id) => _scenarios.any((s) => s.id == id);

  /// Сохраняет новый сценарий или обновляет уже сохранённый.
  void saveScenario(Scenario scenario) {
    final index = _scenarios.indexWhere((s) => s.id == scenario.id);
    if (index >= 0) {
      _scenarios[index] = scenario;
    } else {
      _scenarios.insert(0, scenario);
    }
    notifyListeners();
  }

  void restoreScenario(Scenario scenario, int index) {
    if (hasScenario(scenario.id)) {
      return;
    }
    _scenarios.insert(index.clamp(0, _scenarios.length).toInt(), scenario);
    notifyListeners();
  }
}
