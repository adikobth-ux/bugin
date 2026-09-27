import 'package:bugin/models/models.dart';

/// Профиль пользователя. Mock хранит данные в памяти.
abstract interface class ProfileRepository {
  Future<UserProfile> fetch();

  Future<void> save(UserProfile profile);
}
