enum Interest {
  dates('Свидания'),
  active('Активный отдых'),
  coffee('Кофе'),
  concerts('Концерты'),
  art('Искусство'),
  cinema('Кино'),
  food('Гастрономия');

  const Interest(this.label);

  final String label;
}

class UserProfile {
  const UserProfile({
    required this.name,
    required this.bio,
    required this.interests,
    required this.typicalBudget,
    required this.searchCount,
    this.notifications = const {
      'events': true,
      'bookings': true,
      'promo': false,
    },
  });

  final String name;
  final String bio;
  final List<Interest> interests;

  /// Обычная сумма на человека за выход.
  final int typicalBudget;
  final int searchCount;

  /// Настройки уведомлений: ключ → включено.
  final Map<String, bool> notifications;

  String get initials =>
      name.isEmpty ? '?' : String.fromCharCode(name.runes.first).toUpperCase();

  UserProfile copyWith({
    String? name,
    String? bio,
    List<Interest>? interests,
    int? typicalBudget,
    int? searchCount,
    Map<String, bool>? notifications,
  }) =>
      UserProfile(
        name: name ?? this.name,
        bio: bio ?? this.bio,
        interests: interests ?? this.interests,
        typicalBudget: typicalBudget ?? this.typicalBudget,
        searchCount: searchCount ?? this.searchCount,
        notifications: notifications ?? this.notifications,
      );
}
