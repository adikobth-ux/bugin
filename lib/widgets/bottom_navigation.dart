import 'package:flutter/material.dart';

import 'package:bugin/navigation/app_tab.dart';
import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_text.dart';

/// Нижняя навигация: одна и та же на всех экранах, где она видна.
class BuginBottomNav extends StatelessWidget {
  const BuginBottomNav({
    super.key,
    required this.current,
    required this.onSelect,
  });

  final AppTab current;
  final ValueChanged<AppTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 6, bottom: bottomInset > 0 ? bottomInset : 8),
        child: Row(
          children: [
            for (final tab in AppTab.values)
              Expanded(
                child: _NavItem(
                  tab: tab,
                  active: tab == current,
                  onTap: () => onSelect(tab),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.tab, required this.active, required this.onTap});

  final AppTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.inkSecondary;
    return Semantics(
      selected: active,
      button: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        highlightColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 50),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  active ? tab.activeIcon : tab.icon,
                  key: ValueKey<bool>(active),
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                tab.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.micro.copyWith(
                  color: color,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
