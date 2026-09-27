import 'package:flutter/material.dart';

import 'package:bugin/theme/app_colors.dart';

/// Картинка из ассетов или сети с аккуратным плейсхолдером,
/// если фото нет или оно не загрузилось.
class AppImage extends StatelessWidget {
  const AppImage(
    this.src, {
    super.key,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
    this.fit = BoxFit.cover,
    this.placeholderIcon = Icons.image_outlined,
    this.placeholderTone = Tone.brand,
    this.semanticLabel,
  });

  final String src;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final BoxFit fit;
  final IconData placeholderIcon;
  final Tone placeholderTone;
  final String? semanticLabel;

  double get _iconSize {
    final w = width;
    final h = height;
    final double base =
        (w != null && h != null) ? (w < h ? w : h) : (w ?? h ?? 72.0);
    final size = base * 0.34;
    if (size < 18) {
      return 18;
    }
    if (size > 56) {
      return 56;
    }
    return size;
  }

  Widget _placeholder() => Container(
        width: width,
        height: height,
        color: placeholderTone.background,
        alignment: Alignment.center,
        child: Icon(
          placeholderIcon,
          size: _iconSize,
          color: placeholderTone.foreground,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final Widget image;
    if (src.isEmpty) {
      image = _placeholder();
    } else if (src.startsWith('http')) {
      image = Image.network(
        src,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: semanticLabel,
        excludeFromSemantics: semanticLabel == null,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : Container(width: width, height: height, color: AppColors.skeleton),
      );
    } else {
      image = Image.asset(
        src,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: semanticLabel,
        excludeFromSemantics: semanticLabel == null,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }
    if (borderRadius == BorderRadius.zero) {
      return image;
    }
    return ClipRRect(borderRadius: borderRadius, child: image);
  }
}
