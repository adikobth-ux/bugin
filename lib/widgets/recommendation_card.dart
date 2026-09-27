import 'package:flutter/material.dart';

import 'package:bugin/core/formatters.dart';
import 'package:bugin/l10n/app_strings.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/services/favorites_store.dart';
import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_text.dart';
import 'package:bugin/theme/visuals.dart';
import 'package:bugin/widgets/app_image.dart';
import 'package:bugin/widgets/favorite_button.dart';
import 'package:bugin/widgets/meta_line.dart';
import 'package:bugin/widgets/pressable.dart';
import 'package:bugin/widgets/recommendation_reason.dart';

/// Карточка в выдаче AI-поиска: место или событие + причина выбора.
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({super.key, required this.item, required this.onTap});

  final Recommendation item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final place = item.place;
    final event = item.event;

    final l10n = context.l10n;
    final String overline;
    final Widget meta;
    final IconData placeholderIcon;
    final Tone placeholderTone;
    final FavoriteKind kind;
    final bool highlightOverline;

    if (place != null) {
      overline = place.categoryDetail.isEmpty
          ? l10n.label(place.category)
          : '${l10n.label(place.category)} · ${place.categoryDetail}';
      meta = MetaLine(
        rating: place.rating,
        parts: [
          Fmt.distance(place.distanceKm),
          l10n.averageCheck(place.averageCheck),
        ],
      );
      placeholderIcon = Visuals.placeIcon(place.category);
      placeholderTone = Visuals.placeTone(place.category);
      kind = FavoriteKind.place;
      highlightOverline = false;
    } else {
      final e = event!;
      overline = '${l10n.label(e.category)} · ${l10n.eventWhen(e.startsAt).toLowerCase()}';
      meta = MetaLine(
        parts: [Fmt.distance(e.distanceKm), l10n.fromTenge(e.priceFrom)],
      );
      placeholderIcon = Visuals.eventIcon(e.category);
      placeholderTone = Visuals.eventTone(e.category);
      kind = FavoriteKind.event;
      highlightOverline = true;
    }

    return Pressable(
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 96,
              height: 118,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(
                    item.image,
                    width: 96,
                    height: 118,
                    borderRadius: BorderRadius.circular(14),
                    placeholderIcon: placeholderIcon,
                    placeholderTone: placeholderTone,
                  ),
                  Positioned(
                    right: -1,
                    top: -1,
                    child: FavoriteButton(kind: kind, id: item.id, size: 30),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    overline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.micro.copyWith(
                      color: highlightOverline
                          ? AppColors.primaryInk
                          : AppColors.inkSecondary,
                      fontWeight: highlightOverline ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.title,
                  ),
                  const SizedBox(height: 3),
                  meta,
                  const SizedBox(height: 8),
                  RecommendationReason(item.reason),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
