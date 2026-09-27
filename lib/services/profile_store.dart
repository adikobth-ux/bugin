import 'package:flutter/foundation.dart';

import 'package:bugin/models/models.dart';
import 'package:bugin/services/profile_repository.dart';
import 'package:bugin/services/storage/key_value_store.dart';

/// Профиль, который видят экраны. Изменения сразу применяются в UI,
/// сохраняются на устройстве и отправляются в репозиторий.
class ProfileStore extends ChangeNotifier {
  ProfileStore(
    UserProfile initial,
    this._repository, {
    KeyValueStore? storage,
  })  : _storage = storage,
        _profile = _restore(storage) ?? initial;

  UserProfile _profile;
  final ProfileRepository _repository;
  final KeyValueStore? _storage;

  UserProfile get profile => _profile;

  static UserProfile? _restore(KeyValueStore? storage) {
    final saved = storage?.readJson(StorageKeys.profile);
    if (saved == null) {
      return null;
    }
    try {
      return UserProfile.fromJson(saved);
    } catch (error) {
      debugPrint('Профиль не прочитан, берём по умолчанию: $error');
      return null;
    }
  }

  void _update(UserProfile next) {
    _profile = next;
    notifyListeners();
    _storage?.writeJson(StorageKeys.profile, next.toJson());
    _repository.save(next);
  }

  void updateBudget(int value) => _update(_profile.copyWith(typicalBudget: value));

  void updateInterests(List<Interest> value) =>
      _update(_profile.copyWith(interests: value));

  void setNotification(String key, bool enabled) {
    final next = Map<String, bool>.of(_profile.notifications)..[key] = enabled;
    _update(_profile.copyWith(notifications: next));
  }

  void countSearch() =>
      _update(_profile.copyWith(searchCount: _profile.searchCount + 1));

  /// Возвращает профиль к начальному состоянию.
  void reset(UserProfile initial) => _update(initial);
}
