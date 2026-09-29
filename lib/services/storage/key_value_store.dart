import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Хранилище «ключ → строка» на устройстве.
///
/// Чтение синхронное: всё загружается при старте приложения.
/// Реализации: [MemoryKeyValueStore] для тестов и `SharedPrefsStore` на телефоне.
abstract interface class KeyValueStore {
  String? getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
}

/// Ключи сохранённых данных. Версия в ключе — чтобы безопасно менять формат.
abstract final class StorageKeys {
  static const settings = 'bugin.settings.v1';
  static const favorites = 'bugin.favorites.v1';
  static const profile = 'bugin.profile.v1';
  static const searchHistory = 'bugin.search_history.v1';
  static const location = 'bugin.location.v1';

  static const all = {settings, favorites, profile, searchHistory, location};
}

/// Хранилище в памяти: для тестов и как запасной вариант,
/// если хранилище устройства недоступно.
class MemoryKeyValueStore implements KeyValueStore {
  MemoryKeyValueStore([Map<String, String>? initial])
      : _values = Map.of(initial ?? const {});

  final Map<String, String> _values;

  @override
  String? getString(String key) => _values[key];

  @override
  Future<void> setString(String key, String value) async => _values[key] = value;

  @override
  Future<void> remove(String key) async => _values.remove(key);
}

extension JsonKeyValueStore on KeyValueStore {
  /// JSON-объект по ключу или null, если данных нет или они повреждены.
  Map<String, dynamic>? readJson(String key) {
    final raw = getString(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException catch (error) {
      debugPrint('Повреждённые данные в $key: $error');
      return null;
    }
  }

  /// Сохраняет JSON. Ошибку записи не пробрасываем: данные останутся в памяти.
  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    try {
      await setString(key, jsonEncode(value));
    } catch (error) {
      debugPrint('Не удалось сохранить $key: $error');
    }
  }
}
