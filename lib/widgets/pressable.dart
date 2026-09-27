import 'package:flutter/widgets.dart';

import 'package:bugin/theme/app_spacing.dart';

/// Нажимаемая область с лёгким «вдавливанием» — общий микро-отклик
/// для карточек, чипов и кнопок.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.pressedScale = 0.97,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// Подпись для скринридера, если у виджета нет видимого текста.
  final String? semanticLabel;
  final double pressedScale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value && mounted) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: enabled,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? widget.pressedScale : 1,
          duration: AppMotion.fast,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
