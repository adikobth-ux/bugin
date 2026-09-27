import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:bugin/models/models.dart';
import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_text.dart';
import 'package:bugin/theme/visuals.dart';
import 'package:bugin/widgets/pressable.dart';

/// Пунктирная рамка со скруглением (во Flutter её нет из коробки).
class DashedBorder extends StatelessWidget {
  const DashedBorder({
    super.key,
    required this.child,
    this.color = AppColors.primaryDashed,
    this.radius = 17,
    this.strokeWidth = 1.5,
  });

  final Widget child;
  final Color color;
  final double radius;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashedRRectPainter(
        color: color,
        radius: radius,
        strokeWidth: strokeWidth,
      ),
      child: child,
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  final Color color;
  final double radius;
  final double strokeWidth;

  static const _dash = 4.0;
  static const _gap = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + _dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.strokeWidth != strokeWidth;
}

/// Распознанный параметр запроса: нажать — изменить, крестик — убрать.
/// Додуманные AI параметры обведены пунктиром.
class ParamChip extends StatelessWidget {
  const ParamChip({
    super.key,
    required this.param,
    required this.onEdit,
    required this.onRemove,
  });

  final IntentParam param;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final (icon, tone) = Visuals.param(param);
    final content = Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: param.inferred ? const Color(0xFFF7F7FF) : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Pressable(
            onTap: onEdit,
            semanticLabel: 'Изменить: ${param.label}',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: tone.foreground),
                const SizedBox(width: 6),
                ExcludeSemantics(
                  child: Text(
                    param.label,
                    style: AppText.captionStrong.copyWith(
                      fontWeight: FontWeight.w600,
                      color: param.inferred ? AppColors.inkBody : AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Pressable(
            onTap: onRemove,
            semanticLabel: 'Убрать: ${param.label}',
            pressedScale: 0.85,
            child: const SizedBox(
              width: 32,
              height: 36,
              child: Icon(Icons.close_rounded, size: 15, color: AppColors.inkSecondary),
            ),
          ),
        ],
      ),
    );
    if (!param.inferred) {
      return content;
    }
    return DashedBorder(radius: 18, child: content);
  }
}

/// Чип «+ Уточнить».
class AddParamChip extends StatelessWidget {
  const AddParamChip({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: DashedBorder(
        color: AppColors.primary,
        radius: 18,
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.fromLTRB(10, 0, 12, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, size: 16, color: AppColors.primaryInk),
              const SizedBox(width: 4),
              Text(
                'Уточнить',
                style: AppText.captionStrong.copyWith(color: AppColors.primaryInk),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
