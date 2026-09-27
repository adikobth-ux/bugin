import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bugin/l10n/app_strings.dart';
import 'package:bugin/services/app_services.dart';
import 'package:bugin/services/favorites_store.dart';
import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_spacing.dart';
import 'package:bugin/widgets/pressable.dart';

enum FavoriteButtonStyle {
  /// Белый круг поверх фото.
  onImage,

  /// Полупрозрачный тёмный круг в шапке детального экрана.
  overlay,

  /// Без подложки — в списках.
  plain,

  /// Белый круг с рамкой — в свёрнутой шапке.
  surface,
}

/// Сердечко «в избранное» с анимацией и тактильным откликом.
/// Состояние берётся из [FavoritesStore], поэтому везде синхронно.
class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    super.key,
    required this.kind,
    required this.id,
    this.style = FavoriteButtonStyle.onImage,
    this.size = 36,
    this.onChanged,
  }) : assert(kind != FavoriteKind.scenario);

  final FavoriteKind kind;
  final String id;
  final FavoriteButtonStyle style;

  /// Видимый размер круга. Зона нажатия — не меньше 44.
  final double size;
  final ValueChanged<bool>? onChanged;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _bump = false;

  void _toggle(FavoritesStore store) {
    HapticFeedback.lightImpact();
    final active = store.toggle(widget.kind, widget.id);
    widget.onChanged?.call(active);
    setState(() => _bump = true);
    Future<void>.delayed(const Duration(milliseconds: 160), () {
      if (mounted) {
        setState(() => _bump = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context).favorites;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final active = store.isFavorite(widget.kind, widget.id);
        final (Color background, Color idle) = switch (widget.style) {
          FavoriteButtonStyle.onImage => (AppColors.onImageSurface, AppColors.ink),
          FavoriteButtonStyle.overlay => (AppColors.overlayButton, Colors.white),
          FavoriteButtonStyle.plain => (Colors.transparent, AppColors.inkSecondary),
          FavoriteButtonStyle.surface => (AppColors.surface, AppColors.ink),
        };
        final activeColor = widget.style == FavoriteButtonStyle.overlay
            ? Colors.white
            : AppColors.primary;
        final hit = widget.size < kMinTapTarget ? kMinTapTarget : widget.size;

        return Pressable(
          onTap: () => _toggle(store),
          pressedScale: 0.9,
          semanticLabel: active
              ? context.l10n.removeFromFavorites
              : context.l10n.addToFavorites,
          child: SizedBox.square(
            dimension: hit,
            child: Center(
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: background,
                  border: widget.style == FavoriteButtonStyle.surface
                      ? Border.all(color: AppColors.line)
                      : null,
                ),
                child: AnimatedScale(
                  scale: _bump ? 1.25 : 1,
                  duration: AppMotion.fast,
                  curve: Curves.easeOutBack,
                  child: Icon(
                    active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: widget.size * 0.5,
                    color: active ? activeColor : idle,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
