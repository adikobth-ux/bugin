import 'package:bugin/models/models.dart';
import 'package:bugin/services/mock/simulated_network.dart';
import 'package:bugin/services/profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  MockProfileRepository(this._profile, {required this.latency});

  UserProfile _profile;
  final Duration latency;

  @override
  Future<UserProfile> fetch() => simulateNetwork(latency, () => _profile);

  @override
  Future<void> save(UserProfile profile) =>
      simulateNetwork(latency, () => _profile = profile);
}
