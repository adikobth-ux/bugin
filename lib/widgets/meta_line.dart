import 'package:flutter/material.dart';

import 'package:bugin/core/formatters.dart';
import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_text.dart';

/// Строка метаданных: ★ 4,8 · 1,5 км · ≈ 6 000 ₸.
/// Переносится и масштабируется вместе с системным шрифтом.
class MetaLine extends StatelessWidget {
  const MetaLine({
    super.key,
    this.rating,
    this.reviewsCount,
    this.parts = const [],
    this.onImage = false,
    this.maxLines = 1,
    this.style,
  });

  final double? rating;
  final int? reviewsCount;
  final List<String> parts;
  final bool onImage;
  final int maxLines;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base = style ??
        AppText.caption.copyWith(
          color: onImage ? AppColors.onImageText : AppColors.inkSecondary,
        );
    final spans = <InlineSpan>[];
    final value = rating;
    if (value != null) {
      spans
        ..add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Icon(
                Icons.star_rounded,
                size: (base.fontSize ?? 13) + 2,
                color: onImage ? AppColors.starOnImage : AppColors.star,
              ),
            ),
          ),
        )
        ..add(
          TextSpan(
            text: Fmt.rating(value),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: onImage ? Colors.white : AppColors.ink,
            ),
          ),
        );
      final count = reviewsCount;
      if (count != null) {
        spans.add(TextSpan(text: ' (${Fmt.compactCount(count)})'));
      }
    }
    for (final part in parts) {
      if (spans.isNotEmpty) {
        spans.add(const TextSpan(text: ' · '));
      }
      spans.add(TextSpan(text: part));
    }
    return Text.rich(
      TextSpan(style: base, children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Цена на белой плашке поверх фото.
class PriceBadge extends StatelessWidget {
  const PriceBadge(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppText.captionStrong.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
