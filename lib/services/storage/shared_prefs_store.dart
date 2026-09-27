import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bugin/services/storage/key_value_store.dart';

/// [KeyValueStore] на shared_preferences: SharedPreferences/DataStore на Android,
/// NSUserDefaults на iOS, localStorage в браузере.
class SharedPrefsStore implements KeyValueStore {
  SharedPrefsStore._(this._prefs);

  final SharedPreferencesWithCache _prefs;

  /// Открывает хранилище и читает сохранённые данные в память.
  /// Если хранилище недоступно, приложение работает без сохранения.
  static Future<KeyValueStore> open() async {
    try {
      final prefs = await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(
          allowList: StorageKeys.all,
        ),
      );
      return SharedPrefsStore._(prefs);
    } catch (error) {
      debugPrint('Хранилище недоступно, данные не сохранятся: $error');
      return MemoryKeyValueStore();
    }
  }

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) => _prefs.setString(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}
