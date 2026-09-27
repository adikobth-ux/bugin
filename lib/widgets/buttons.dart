import 'package:flutter/material.dart';

import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_spacing.dart';
import 'package:bugin/theme/app_text.dart';
import 'package:bugin/widgets/pressable.dart';

enum ButtonVariant { filled, outline, soft }

/// Основная кнопка. Высота 54 — главное действие экрана, 44 — второстепенное.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = ButtonVariant.filled,
    this.height = 54,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonVariant variant;
  final double height;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final background = switch (variant) {
      ButtonVariant.filled => AppColors.primary,
      ButtonVariant.outline => AppColors.surface,
      ButtonVariant.soft => AppColors.primarySoft,
    };
    final foreground =
        variant == ButtonVariant.filled ? Colors.white : AppColors.primaryInk;
    final border = variant == ButtonVariant.outline
        ? Border.all(color: AppColors.primary, width: 1.5)
        : null;
    final fontSize = height >= 50 ? 16.0 : 14.0;

    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppText.bodyStrong.copyWith(color: foreground, fontSize: fontSize),
    );

    // Flexible — только когда ширина ограничена (expand), иначе Row в
    // неограниченной ширине (например, рядом с Expanded) упадёт с ошибкой.
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: foreground),
          const SizedBox(width: 8),
        ],
        if (expand) Flexible(child: text) else text,
      ],
    );

    return AnimatedOpacity(
      opacity: onPressed == null ? 0.45 : 1,
      duration: AppMotion.fast,
      child: Pressable(
        onTap: onPressed,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(height >= 50 ? 16 : 14),
            border: border,
          ),
          child: content,
        ),
      ),
    );
  }
}

enum CircleButtonStyle { surface, overlay, soft, primary, plain }

/// Круглая иконка-кнопка. Видимый размер — [size], зона нажатия не меньше 44.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.style = CircleButtonStyle.surface,
    this.size = 44,
    this.iconSize = 20,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final CircleButtonStyle style;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground) = switch (style) {
      CircleButtonStyle.surface => (AppColors.surface, AppColors.ink),
      CircleButtonStyle.overlay => (AppColors.overlayButton, Colors.white),
      CircleButtonStyle.soft => (AppColors.primarySoft, AppColors.primaryInk),
      CircleButtonStyle.primary => (AppColors.primary, Colors.white),
      CircleButtonStyle.plain => (Colors.transparent, AppColors.ink),
    };
    final hit = size < kMinTapTarget ? kMinTapTarget : size;

    return Pressable(
      onTap: onPressed,
      semanticLabel: semanticLabel,
      pressedScale: 0.9,
      child: SizedBox.square(
        dimension: hit,
        child: Center(
          child: AnimatedOpacity(
            opacity: onPressed == null ? 0.45 : 1,
            duration: AppMotion.fast,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: background,
                border: style == CircleButtonStyle.surface
                    ? Border.all(color: AppColors.line)
                    : null,
              ),
              child: Icon(icon, size: iconSize, color: foreground),
            ),
          ),
        ),
      ),
    );
  }
}

/// Единая кнопка «Назад» для всех экранов.
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.style = CircleButtonStyle.surface,
    this.icon = Icons.arrow_back_rounded,
    this.semanticLabel = 'Назад',
  });

  final CircleButtonStyle style;
  final IconData icon;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return CircleIconButton(
      icon: icon,
      style: style,
      semanticLabel: semanticLabel,
      onPressed: () => Navigator.of(context).maybePop(),
    );
  }
}

/// Текстовая ссылка «Все →», «Изменить», «Очистить».
class LinkButton extends StatelessWidget {
  const LinkButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.showChevron = true,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinTapTarget),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.primaryInk),
                const SizedBox(width: 6),
              ],
              Text(label, style: AppText.label.copyWith(color: AppColors.primaryInk)),
              if (showChevron && icon == null)
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.primaryInk,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
