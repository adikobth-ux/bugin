import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_spacing.dart';
import 'package:bugin/theme/app_theme.dart';

/// Основа экрана-вкладки: светлый фон, тёмный статус-бар, безопасные отступы.
class TabPage extends StatelessWidget {
  const TabPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayOnLight,
      child: ColoredBox(
        color: AppColors.background,
        child: SafeArea(bottom: false, child: ContentWidth(child: child)),
      ),
    );
  }
}

/// Ограничивает ширину контента на планшетах, на телефонах не мешает.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth = 640});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Горизонтальная карусель карточек одинаковой высоты.
/// Высота берётся из содержимого — не ломается при крупном шрифте.
class HorizontalCarousel extends StatelessWidget {
  const HorizontalCarousel({
    super.key,
    required this.children,
    this.spacing = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: AppInsets.screen),
  });

  final List<Widget> children;
  final double spacing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: padding,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(width: spacing),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Ширина карточки в карусели: примерно 58% экрана, но в разумных пределах.
double carouselCardWidth(BuildContext context, {double min = 200, double max = 260}) {
  final width = MediaQuery.sizeOf(context).width * 0.58;
  if (width < min) {
    return min;
  }
  if (width > max) {
    return max;
  }
  return width;
}
