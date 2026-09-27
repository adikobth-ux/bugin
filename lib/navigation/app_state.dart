import 'package:flutter/foundation.dart';

import 'package:bugin/core/constants.dart';
import 'package:bugin/l10n/app_language.dart';
import 'package:bugin/navigation/app_tab.dart';
import 'package:bugin/services/storage/key_value_store.dart';

/// Состояние оболочки приложения: язык, город, активная вкладка, раздел избранного.
///
/// Язык и город сохраняются на устройстве. Язык по умолчанию — язык телефона,
/// пока пользователь не выберет другой в профиле.
class AppState {
  factory AppState({
    KeyValueStore? storage,
    AppLanguage language = AppLanguage.ru,
    String city = kDefaultCity,
  }) {
    final saved = storage?.readJson(StorageKeys.settings) ?? const <String, dynamic>{};
    final savedCity = saved['city'];
    return AppState._(
      storage,
      language: AppLanguage.tryParse(saved['language'] as String?) ?? language,
      city: savedCity is String && kCities.contains(savedCity) ? savedCity : city,
    );
  }

  AppState._(
    this._storage, {
    required AppLanguage language,
    required String city,
  })  : language = ValueNotifier<AppLanguage>(language),
        city = ValueNotifier<String>(city) {
    this.language.addListener(_save);
    this.city.addListener(_save);
  }

  final KeyValueStore? _storage;

  final ValueNotifier<AppLanguage> language;
  final ValueNotifier<String> city;
  final ValueNotifier<AppTab> tab = ValueNotifier<AppTab>(AppTab.home);
  final ValueNotifier<FavoritesSection> favoritesSection =
      ValueNotifier<FavoritesSection>(FavoritesSection.places);

  void _save() {
    _storage?.writeJson(StorageKeys.settings, {
      'language': language.value.code,
      'city': city.value,
    });
  }
}
