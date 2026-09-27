import 'package:flutter/material.dart';

import 'package:bugin/l10n/app_strings.dart';
import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_text.dart';
import 'package:bugin/widgets/pressable.dart';

/// Схематичная мини-карта с пином. Настоящая карта подключится вместе
/// с геосервисом — интерфейс виджета останется тем же.
class MiniMap extends StatelessWidget {
  const MiniMap({super.key, this.height = 120, this.onRoute, this.variant = 0});

  final double height;
  final VoidCallback? onRoute;

  /// Разные «районы», чтобы карты мест не были одинаковыми.
  final int variant;

  @override
  Widget build(BuildContext context) {
    final route = onRoute;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _MapPainter(variant)),
            ),
            if (route != null)
              Positioned(
                right: 10,
                bottom: 10,
                child: Pressable(
                  onTap: route,
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.near_me_outlined,
                          size: 16,
                          color: AppColors.primaryInk,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          context.l10n.route,
                          style: AppText.captionStrong.copyWith(
                            color: AppColors.primaryInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  const _MapPainter(this.variant);

  final int variant;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final flip = variant.isOdd;

    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFECEEF6));

    // Парк
    final park = Paint()..color = const Color(0xFFDCEFE3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(flip ? w * 0.08 : w * 0.6, h * 0.32, w * 0.18, h * 0.24),
        const Radius.circular(6),
      ),
      park,
    );

    // Река
    final river = Path();
    if (flip) {
      river
        ..moveTo(0, h * 0.12)
        ..cubicTo(w * 0.3, h * 0.3, w * 0.6, 0, w, h * 0.16)
        ..lineTo(w, 0)
        ..lineTo(0, 0)
        ..close();
    } else {
      river
        ..moveTo(0, h * 0.84)
        ..cubicTo(w * 0.25, h * 0.74, w * 0.46, h * 0.94, w, h * 0.78)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
    }
    canvas.drawPath(river, Paint()..color = const Color(0xFFD6E4F7));

    // Улицы
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;
    canvas
      ..drawLine(Offset(0, h * 0.26), Offset(w, h * 0.26), road)
      ..drawLine(Offset(0, h * 0.64), Offset(w, h * 0.64), road)
      ..drawLine(Offset(w * 0.2, 0), Offset(w * 0.2, h), road)
      ..drawLine(Offset(w * 0.46, 0), Offset(w * 0.46, h), road)
      ..drawLine(Offset(w * 0.84, 0), Offset(w * 0.84, h), road)
      ..drawLine(
        Offset(flip ? w : 0, 0),
        Offset(flip ? w * 0.6 : w * 0.34, h),
        road,
      );

    // Пин
    final cx = w * 0.46;
    final cy = h * 0.46;
    canvas.drawCircle(
      Offset(cx, cy),
      16,
      Paint()..color = const Color(0x2E5B5BF0),
    );
    final pin = Path()
      ..moveTo(cx, cy + 12)
      ..quadraticBezierTo(cx - 9, cy + 2, cx - 9, cy - 4)
      ..arcToPoint(Offset(cx + 9, cy - 4), radius: const Radius.circular(9))
      ..quadraticBezierTo(cx + 9, cy + 2, cx, cy + 12)
      ..close();
    canvas
      ..drawPath(pin, Paint()..color = AppColors.primary)
      ..drawCircle(Offset(cx, cy - 4), 3.2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) =>
      oldDelegate.variant != variant;
}
