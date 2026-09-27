import 'package:bugin/models/common.dart';

/// Интересы из профиля. Подписи — в `AppStrings.label`.
enum Interest {
  dates,
  active,
  coffee,
  concerts,
  art,
  cinema,
  food;

  static Interest? tryParse(String? name) {
    for (final value in Interest.values) {
      if (value.name == name) {
        return value;
      }
    }
    return null;
  }
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

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String? ?? '',
        bio: json['bio'] as String? ?? '',
        interests: parseEnumSet(json['interests'], Interest.tryParse).toList(),
        typicalBudget: json['typicalBudget'] as int? ?? 10000,
        searchCount: json['searchCount'] as int? ?? 0,
        notifications: {
          for (final entry
              in (json['notifications'] as Map<String, dynamic>? ?? const {}).entries)
            if (entry.value is bool) entry.key: entry.value as bool,
        },
      );

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

  Map<String, dynamic> toJson() => {
        'name': name,
        'bio': bio,
        'interests': interests.map((i) => i.name).toList(),
        'typicalBudget': typicalBudget,
        'searchCount': searchCount,
        'notifications': notifications,
      };

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
