import 'package:flutter/material.dart';

/// Вкладки нижней навигации: Главная | Афиша | Избранное | Профиль.
/// Подписи вкладок — в `AppStrings.label`.
enum AppTab {
  home(Icons.home_outlined, Icons.home_rounded),
  afisha(Icons.confirmation_number_outlined, Icons.confirmation_number_rounded),
  favorites(Icons.favorite_border_rounded, Icons.favorite_rounded),
  profile(Icons.person_outline_rounded, Icons.person_rounded);

  const AppTab(this.icon, this.activeIcon);

  final IconData icon;
  final IconData activeIcon;
}

/// Разделы экрана «Избранное».
enum FavoritesSection { places, events, scenarios }
