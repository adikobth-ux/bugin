import 'package:flutter/material.dart';

import 'package:bugin/theme/app_colors.dart';

/// Мягкая пульсация для скелетонов загрузки.
class SkeletonPulse extends StatefulWidget {
  const SkeletonPulse({super.key, required this.child});

  final Widget child;

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _opacity =
      Tween<double>(begin: 0.45, end: 1).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Загрузка',
      child: FadeTransition(opacity: _opacity, child: widget.child),
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, required this.height, this.radius = 8});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.skeleton,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Скелетон строки-карточки (выдача, избранное, афиша).
class SkeletonRowCard extends StatelessWidget {
  const SkeletonRowCard({super.key, this.imageSize = 72});

  final double imageSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          SkeletonBox(width: imageSize, height: imageSize, radius: 14),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: 0.7,
                  child: SkeletonBox(height: 14, radius: 7),
                ),
                SizedBox(height: 10),
                FractionallySizedBox(
                  widthFactor: 0.45,
                  child: SkeletonBox(height: 12, radius: 6),
                ),
                SizedBox(height: 10),
                FractionallySizedBox(
                  widthFactor: 0.85,
                  child: SkeletonBox(height: 12, radius: 6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Несколько скелетонов подряд.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 3, this.imageSize = 72});

  final int count;
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: Column(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            SkeletonRowCard(imageSize: imageSize),
          ],
        ],
      ),
    );
  }
}
