import 'package:flutter/foundation.dart';

import 'package:bugin/models/models.dart';
import 'package:bugin/services/storage/key_value_store.dart';

enum FavoriteKind { place, event, scenario }

/// Избранное: места, события и сохранённые сценарии.
///
/// Хранится на устройстве и переживает перезапуск. При первом запуске —
/// значения по умолчанию. Для backend достаточно добавить синхронизацию
/// в [_changed] — экраны слушают этот объект и ничего не заметят.
class FavoritesStore extends ChangeNotifier {
  FavoritesStore({
    KeyValueStore? storage,
    Iterable<String> placeIds = const [],
    Iterable<String> eventIds = const [],
    Iterable<Scenario> scenarios = const [],
  }) : _storage = storage {
    final saved = storage?.readJson(StorageKeys.favorites);
    if (saved != null) {
      _placeIds.addAll(parseStringList(saved['places']));
      _eventIds.addAll(parseStringList(saved['events']));
      for (final raw in saved['scenarios'] as List? ?? const []) {
        try {
          _scenarios.add(Scenario.fromJson(raw as Map<String, dynamic>));
        } catch (error) {
          debugPrint('Пропущен повреждённый сценарий: $error');
        }
      }
    } else {
      _fill(placeIds, eventIds, scenarios);
    }
  }

  final KeyValueStore? _storage;
  final List<String> _placeIds = [];
  final List<String> _eventIds = [];
  final List<Scenario> _scenarios = [];

  void _fill(
    Iterable<String> placeIds,
    Iterable<String> eventIds,
    Iterable<Scenario> scenarios,
  ) {
    _placeIds
      ..clear()
      ..addAll(placeIds);
    _eventIds
      ..clear()
      ..addAll(eventIds);
    _scenarios
      ..clear()
      ..addAll(scenarios);
  }

  void _changed() {
    notifyListeners();
    _storage?.writeJson(StorageKeys.favorites, {
      'places': _placeIds,
      'events': _eventIds,
      'scenarios': _scenarios.map((s) => s.toJson()).toList(),
    });
  }

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
    _changed();
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
      _changed();
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
    _changed();
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
    _changed();
  }

  void restoreScenario(Scenario scenario, int index) {
    if (hasScenario(scenario.id)) {
      return;
    }
    _scenarios.insert(index.clamp(0, _scenarios.length).toInt(), scenario);
    _changed();
  }

  /// Заменяет сохранённые сценарии обновлёнными версиями с теми же id
  /// (например, переведёнными на другой язык).
  void updateScenarios(Iterable<Scenario> updated) {
    final byId = {for (final s in updated) s.id: s};
    var changed = false;
    for (var i = 0; i < _scenarios.length; i++) {
      final next = byId[_scenarios[i].id];
      if (next != null) {
        _scenarios[i] = next;
        changed = true;
      }
    }
    if (changed) {
      _changed();
    }
  }

  /// Возвращает избранное к начальному состоянию.
  void reset({
    Iterable<String> placeIds = const [],
    Iterable<String> eventIds = const [],
    Iterable<Scenario> scenarios = const [],
  }) {
    _fill(placeIds, eventIds, scenarios);
    _changed();
  }
}
