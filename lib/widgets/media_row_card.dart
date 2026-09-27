import 'package:flutter/material.dart';

import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_text.dart';
import 'package:bugin/widgets/app_image.dart';
import 'package:bugin/widgets/pressable.dart';

/// Строка-карточка: фото слева, текст справа, действие в конце.
/// Общая основа для списков афиши и избранного.
class MediaRowCard extends StatelessWidget {
  const MediaRowCard({
    super.key,
    required this.image,
    required this.title,
    this.overline,
    this.lines = const [],
    this.trailing,
    this.onTap,
    this.imageSize = 84,
    this.placeholderIcon = Icons.image_outlined,
    this.placeholderTone = Tone.brand,
  });

  final String image;
  final String title;

  /// Цветная строка над заголовком: «20:00 · Концерт».
  final String? overline;
  final List<Widget> lines;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double imageSize;
  final IconData placeholderIcon;
  final Tone placeholderTone;

  @override
  Widget build(BuildContext context) {
    final overlineText = overline;
    return Pressable(
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 10, trailing != null ? 2 : 12, 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            AppImage(
              image,
              width: imageSize,
              height: imageSize,
              borderRadius: BorderRadius.circular(14),
              placeholderIcon: placeholderIcon,
              placeholderTone: placeholderTone,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (overlineText != null) ...[
                    Text(
                      overlineText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.micro.copyWith(
                        color: AppColors.primaryInk,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.titleSmall,
                  ),
                  for (final line in lines) ...[
                    const SizedBox(height: 3),
                    line,
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
