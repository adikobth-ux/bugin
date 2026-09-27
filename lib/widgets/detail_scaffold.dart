import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_text.dart';
import 'package:bugin/theme/app_theme.dart';
import 'package:bugin/widgets/app_image.dart';
import 'package:bugin/widgets/buttons.dart';
import 'package:bugin/widgets/chips.dart';
import 'package:bugin/widgets/layout.dart';
import 'package:bugin/widgets/skeleton.dart';
import 'package:bugin/widgets/state_views.dart';

/// Строит кнопки шапки. [onImage] = true, пока шапка поверх фото.
typedef DetailActionsBuilder = List<Widget> Function(bool onImage);

/// Общий каркас карточки места и события: фото-шапка, которая при прокрутке
/// превращается в белую панель с названием, контент и закреплённая панель действий.
class DetailScaffold extends StatefulWidget {
  const DetailScaffold({
    super.key,
    required this.image,
    required this.title,
    required this.body,
    this.badge,
    this.subtitle,
    this.meta,
    this.bottomBar,
    this.actionsBuilder,
    this.placeholderIcon = Icons.image_outlined,
    this.placeholderTone = Tone.brand,
    this.heroHeight = 320,
    this.onImageTap,
  });

  final String image;
  final String title;
  final List<Widget> body;
  final String? badge;
  final String? subtitle;
  final Widget? meta;
  final Widget? bottomBar;
  final DetailActionsBuilder? actionsBuilder;
  final IconData placeholderIcon;
  final Tone placeholderTone;
  final double heroHeight;
  final VoidCallback? onImageTap;

  @override
  State<DetailScaffold> createState() => _DetailScaffoldState();
}

class _DetailScaffoldState extends State<DetailScaffold> {
  final _controller = ScrollController();
  final _collapse = ValueNotifier<double>(0);

  static const _barHeight = 60.0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    _collapse.dispose();
    super.dispose();
  }

  double _heroHeight(BuildContext context) {
    // При крупном системном шрифте шапка чуть выше, чтобы текст не упирался в кнопки.
    final scale = MediaQuery.textScalerOf(context).scale(10) / 10;
    final extra = (scale - 1).clamp(0.0, 0.5).toDouble() * 140;
    return widget.heroHeight + extra;
  }

  void _onScroll() {
    final top = MediaQuery.paddingOf(context).top;
    final start = _heroHeight(context) - top - _barHeight - 64;
    final t = ((_controller.offset - start) / 56).clamp(0.0, 1.0).toDouble();
    if ((t - _collapse.value).abs() > 0.02 || t == 0 || t == 1) {
      _collapse.value = t;
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final heroHeight = _heroHeight(context);

    return ValueListenableBuilder<double>(
      valueListenable: _collapse,
      builder: (context, t, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: t > 0.5 ? AppTheme.overlayOnLight : AppTheme.overlayOnDark,
        child: child!,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: widget.bottomBar,
        body: Stack(
          children: [
            ListView(
              controller: _controller,
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                _Hero(
                  height: heroHeight,
                  image: widget.image,
                  badge: widget.badge,
                  title: widget.title,
                  subtitle: widget.subtitle,
                  meta: widget.meta,
                  placeholderIcon: widget.placeholderIcon,
                  placeholderTone: widget.placeholderTone,
                  onTap: widget.onImageTap,
                ),
                ContentWidth(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: widget.body,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: ValueListenableBuilder<double>(
                valueListenable: _collapse,
                builder: (context, t, _) => _TopBar(
                  progress: t,
                  topInset: top,
                  height: _barHeight,
                  title: widget.title,
                  actionsBuilder: widget.actionsBuilder,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.height,
    required this.image,
    required this.title,
    required this.placeholderIcon,
    required this.placeholderTone,
    this.badge,
    this.subtitle,
    this.meta,
    this.onTap,
  });

  final double height;
  final String image;
  final String title;
  final String? badge;
  final String? subtitle;
  final Widget? meta;
  final IconData placeholderIcon;
  final Tone placeholderTone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final badgeText = badge;
    final subtitleText = subtitle;
    final metaWidget = meta;
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: onTap,
            child: AppImage(
              image,
              height: height,
              placeholderIcon: placeholderIcon,
              placeholderTone: placeholderTone,
            ),
          ),
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.heroScrimTop,
                    AppColors.heroScrimClear,
                    AppColors.heroScrimMid,
                    AppColors.heroScrimBottom,
                  ],
                  stops: [0, 0.3, 0.5, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 38,
            child: IgnorePointer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (badgeText != null) ...[
                    BrandBadge(badgeText),
                    const SizedBox(height: 8),
                  ],
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.heroTitle,
                    ),
                  ),
                  if (subtitleText != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitleText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body.copyWith(
                        color: AppColors.onImageText,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (metaWidget != null) ...[
                    const SizedBox(height: 8),
                    metaWidget,
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: -1,
            height: 25,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.progress,
    required this.topInset,
    required this.height,
    required this.title,
    this.actionsBuilder,
  });

  final double progress;
  final double topInset;
  final double height;
  final String title;
  final DetailActionsBuilder? actionsBuilder;

  @override
  Widget build(BuildContext context) {
    final onImage = progress < 0.5;
    final actions = actionsBuilder?.call(onImage) ?? const <Widget>[];
    return Container(
      padding: EdgeInsets.only(top: topInset),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha((progress * 255).round()),
        border: progress > 0.95
            ? const Border(bottom: BorderSide(color: AppColors.line))
            : null,
      ),
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              AppBackButton(
                style: onImage ? CircleButtonStyle.overlay : CircleButtonStyle.surface,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Opacity(
                  opacity: progress,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.title,
                  ),
                ),
              ),
              for (final action in actions) ...[
                const SizedBox(width: 4),
                action,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Загрузка детального экрана: скелетон шапки и контента.
class DetailLoading extends StatelessWidget {
  const DetailLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayOnLight,
      child: Scaffold(
        body: Stack(
          children: [
            const SkeletonPulse(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SkeletonBox(height: 320, radius: 0),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        SkeletonRowCard(),
                        SizedBox(height: 10),
                        SkeletonRowCard(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: const AppBackButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ошибка загрузки детального экрана.
class DetailError extends StatelessWidget {
  const DetailError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: AppBackButton(),
            ),
            Expanded(child: Center(child: ErrorState(onRetry: onRetry))),
          ],
        ),
      ),
    );
  }
}
