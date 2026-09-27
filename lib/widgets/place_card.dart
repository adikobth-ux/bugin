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
import 'package:bugin/widgets/meta_line.dart';
import 'package:bugin/widgets/pressable.dart';

/// Вертикальная карточка места для каруселей.
class PlaceCard extends StatelessWidget {
  const PlaceCard({
    super.key,
    required this.place,
    required this.onTap,
    this.width = 220,
  });

  final Place place;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
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
            SizedBox(
              height: 132,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(
                    place.cover,
                    height: 132,
                    placeholderIcon: Visuals.placeIcon(place.category),
                    placeholderTone: Visuals.placeTone(place.category),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: OverlayLabel(place.category.label),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: FavoriteButton(kind: FavoriteKind.place, id: place.id),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    place.name,
                    style: AppText.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  MetaLine(
                    rating: place.rating,
                    parts: [
                      Fmt.distance(place.distanceKm),
                      Fmt.averageCheck(place.averageCheck),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
