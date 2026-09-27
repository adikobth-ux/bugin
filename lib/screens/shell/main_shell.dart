import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bugin/navigation/app_tab.dart';
import 'package:bugin/screens/afisha/afisha_screen.dart';
import 'package:bugin/screens/favorites/favorites_screen.dart';
import 'package:bugin/screens/home/home_screen.dart';
import 'package:bugin/screens/profile/profile_screen.dart';
import 'package:bugin/services/app_services.dart';
import 'package:bugin/widgets/bottom_navigation.dart';

/// Оболочка с нижней навигацией. Вкладки живут в IndexedStack,
/// поэтому прокрутка и состояние сохраняются при переключении.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _tabs = <Widget>[
    HomeScreen(),
    AfishaScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context).state;
    return ValueListenableBuilder<AppTab>(
      valueListenable: state.tab,
      builder: (context, tab, _) => Scaffold(
        body: IndexedStack(index: tab.index, children: _tabs),
        bottomNavigationBar: BuginBottomNav(
          current: tab,
          onSelect: (next) {
            if (next != tab) {
              HapticFeedback.selectionClick();
              state.tab.value = next;
            }
          },
        ),
      ),
    );
  }
}
