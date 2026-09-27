import 'package:flutter/material.dart';

import 'package:bugin/theme/app_colors.dart';

/// Закреплённая нижняя панель с главным действием экрана.
class StickyActionBar extends StatelessWidget {
  const StickyActionBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: Offset(0, -6)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, bottomInset > 0 ? bottomInset : 12),
        child: child,
      ),
    );
  }
}
