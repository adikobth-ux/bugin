import 'package:flutter/material.dart';

/// Вкладки нижней навигации: Главная | Афиша | Избранное | Профиль.
enum AppTab {
  home('Главная', Icons.home_outlined, Icons.home_rounded),
  afisha(
    'Афиша',
    Icons.confirmation_number_outlined,
    Icons.confirmation_number_rounded,
  ),
  favorites('Избранное', Icons.favorite_border_rounded, Icons.favorite_rounded),
  profile('Профиль', Icons.person_outline_rounded, Icons.person_rounded);

  const AppTab(this.label, this.icon, this.activeIcon);

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// Разделы экрана «Избранное».
enum FavoritesSection {
  places('Места'),
  events('События'),
  scenarios('Сценарии');

  const FavoritesSection(this.label);

  final String label;
}
