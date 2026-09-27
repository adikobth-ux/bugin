import 'package:flutter/material.dart';

import 'package:bugin/core/formatters.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/services/favorites_store.dart';
import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_text.dart';
import 'package:bugin/theme/visuals.dart';
import 'package:bugin/widgets/app_image.dart';
import 'package:bugin/widgets/chips.dart';
import 'package:bugin/widgets/favorite_button.dart';
import 'package:bugin/widgets/media_row_card.dart';
import 'package:bugin/widgets/meta_line.dart';
import 'package:bugin/widgets/pressable.dart';

enum _EventCardVariant { row, featured, compact }

/// Карточка события в трёх вариантах: строка афиши, «главное на неделе»
/// и компактная для каруселей.
class EventCard extends StatelessWidget {
  const EventCard.row({
    super.key,
    required this.event,
    required this.onTap,
    this.showDay = false,
  })  : _variant = _EventCardVariant.row,
        width = null;

  const EventCard.featured({super.key, required this.event, required this.onTap})
      : _variant = _EventCardVariant.featured,
        showDay = true,
        width = null;

  const EventCard.compact({
    super.key,
    required this.event,
    required this.onTap,
    this.width = 170,
  })  : _variant = _EventCardVariant.compact,
        showDay = true;

  final Event event;
  final VoidCallback onTap;

  /// Показывать день («Сб, 3 окт»), а не только время.
  final bool showDay;
  final double? width;
  final _EventCardVariant _variant;

  String get _when {
    if (event.isLongRunning) {
      final prefix = showDay ? '${Fmt.relativeDay(event.startsAt)}, до' : 'До';
      return '$prefix ${Fmt.time(event.endsAt)}';
    }
    return showDay ? Fmt.eventWhen(event.startsAt) : Fmt.time(event.startsAt);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_variant) {
      _EventCardVariant.row => _buildRow(),
      _EventCardVariant.featured => _buildFeatured(),
      _EventCardVariant.compact => _buildCompact(),
    };
  }

  Widget _buildRow() {
    return MediaRowCard(
      image: event.image,
      imageSize: 76,
      placeholderIcon: Visuals.eventIcon(event.category),
      placeholderTone: Visuals.eventTone(event.category),
      overline: '$_when · ${event.category.label}',
      title: event.title,
      lines: [
        Text(
          '${event.venueName} · ${Fmt.distance(event.distanceKm)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.caption,
        ),
        Text(Fmt.fromTenge(event.priceFrom), style: AppText.captionStrong),
      ],
      trailing: FavoriteButton(
        kind: FavoriteKind.event,
        id: event.id,
        style: FavoriteButtonStyle.plain,
      ),
      onTap: onTap,
    );
  }

  Widget _buildFeatured() {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.98,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: 210,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppImage(
                event.image,
                placeholderIcon: Visuals.eventIcon(event.category),
                placeholderTone: Visuals.eventTone(event.category),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.heroScrimClear, AppColors.heroScrimBottom],
                    stops: [0.3, 1],
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: FavoriteButton(kind: FavoriteKind.event, id: event.id),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BrandBadge(event.category.label),
                          const SizedBox(height: 6),
                          Text(
                            event.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.h2.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_when · ${event.venueName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.caption.copyWith(
                              color: AppColors.onImageText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    PriceBadge(Fmt.fromTenge(event.priceFrom)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompact() {
    return Pressable(
      onTap: onTap,
      child: Container(
        width: width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppImage(
              event.image,
              height: 104,
              placeholderIcon: Visuals.eventIcon(event.category),
              placeholderTone: Visuals.eventTone(event.category),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.label.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(_when, style: AppText.micro),
                  const SizedBox(height: 3),
                  Text(Fmt.fromTenge(event.priceFrom), style: AppText.captionStrong),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Мета-строка события для других карточек.
class EventMeta extends StatelessWidget {
  const EventMeta({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return MetaLine(
      parts: [
        event.venueName,
        Fmt.distance(event.distanceKm),
        Fmt.fromTenge(event.priceFrom),
      ],
    );
  }
}
