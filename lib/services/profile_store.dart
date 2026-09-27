import 'package:flutter/foundation.dart';

import 'package:bugin/models/models.dart';
import 'package:bugin/services/profile_repository.dart';

/// Профиль, который видят экраны. Изменения сразу применяются в UI
/// и отправляются в репозиторий.
class ProfileStore extends ChangeNotifier {
  ProfileStore(this._profile, this._repository);

  UserProfile _profile;
  final ProfileRepository _repository;

  UserProfile get profile => _profile;

  void _update(UserProfile next) {
    _profile = next;
    notifyListeners();
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
}
