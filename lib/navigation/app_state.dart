import 'package:flutter/foundation.dart';

import 'package:bugin/core/constants.dart';
import 'package:bugin/navigation/app_tab.dart';

/// Состояние оболочки приложения: город, активная вкладка, раздел избранного.
class AppState {
  AppState({String city = kDefaultCity}) : city = ValueNotifier<String>(city);

  final ValueNotifier<String> city;
  final ValueNotifier<AppTab> tab = ValueNotifier<AppTab>(AppTab.home);
  final ValueNotifier<FavoritesSection> favoritesSection =
      ValueNotifier<FavoritesSection>(FavoritesSection.places);
}
