import 'package:flutter/material.dart';

import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_spacing.dart';
import 'package:bugin/theme/app_text.dart';
import 'package:bugin/widgets/pressable.dart';

/// Быстрый выбор на главной: иконка + подпись в тоне категории.
class IntentChip extends StatelessWidget {
  const IntentChip({
    super.key,
    required this.icon,
    required this.label,
    required this.tone,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Tone tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.fromLTRB(12, 8, 14, 8),
        decoration: BoxDecoration(
          color: tone.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: tone.foreground),
            const SizedBox(width: 8),
            Text(label, style: AppText.label),
          ],
        ),
      ),
    );
  }
}

enum SelectChipStyle { solid, soft }

/// Чип выбора: в формах, фильтрах, сортировке.
class SelectChip extends StatelessWidget {
  const SelectChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.style = SelectChipStyle.solid,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final SelectChipStyle style;

  @override
  Widget build(BuildContext context) {
    final solid = style == SelectChipStyle.solid;
    final background = selected
        ? (solid ? AppColors.primary : AppColors.primarySoft)
        : (solid ? AppColors.surface : Colors.transparent);
    final foreground = selected
        ? (solid ? Colors.white : AppColors.primaryInk)
        : (solid ? AppColors.ink : AppColors.inkBody);
    final borderColor = selected
        ? (solid ? AppColors.primary : AppColors.primaryBorder)
        : (solid ? AppColors.line : Colors.transparent);

    return Semantics(
      selected: selected,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: Curves.easeOut,
          constraints: BoxConstraints(minHeight: solid ? 40 : 36),
          padding: EdgeInsets.symmetric(horizontal: solid ? 16 : 12, vertical: 8),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(solid ? 20 : 12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: foreground),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppText.label.copyWith(
                  color: foreground,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: solid ? 14 : 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Статичный тег в карточках: «Европейская кухня».
class TagChip extends StatelessWidget {
  const TagChip(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(label, style: AppText.captionStrong.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}

/// Мелкий серый тег: «Wi-Fi», «Тихо».
class MiniTag extends StatelessWidget {
  const MiniTag(this.label, {super.key, this.tone});

  final String label;
  final Tone? tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tone?.background ?? AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppText.micro.copyWith(
          color: tone == null ? AppColors.inkSecondary : AppColors.ink,
        ),
      ),
    );
  }
}

/// Подпись поверх фото: «Кафе».
class OverlayLabel extends StatelessWidget {
  const OverlayLabel(this.label, {super.key, this.color = AppColors.ink});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.onImageSurface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppText.micro.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Фиолетовый бейдж категории на обложке.
class BrandBadge extends StatelessWidget {
  const BrandBadge(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppText.micro.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Горизонтальный ряд чипов с прокруткой до края экрана.
class ChipRow extends StatelessWidget {
  const ChipRow({
    super.key,
    required this.children,
    this.spacing = 8,
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
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            children[i],
          ],
        ],
      ),
    );
  }
}
