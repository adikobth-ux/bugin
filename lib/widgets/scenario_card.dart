import 'package:flutter/material.dart';

import 'package:bugin/core/formatters.dart';
import 'package:bugin/l10n/app_strings.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_text.dart';
import 'package:bugin/widgets/app_image.dart';
import 'package:bugin/widgets/chips.dart';
import 'package:bugin/widgets/pressable.dart';

/// Готовый сценарий: «Спокойный день — Кофейня → работа».
class ScenarioCard extends StatelessWidget {
  const ScenarioCard({super.key, required this.scenario, required this.onTap});

  final Scenario scenario;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            SizedBox.square(
              dimension: 104,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(
                    scenario.cover,
                    width: 104,
                    height: 104,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: OverlayLabel(
                      context.l10n.scenario,
                      color: AppColors.primaryInk,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(scenario.title, style: AppText.title),
                  const SizedBox(height: 4),
                  Text(
                    scenario.route,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 14,
                    runSpacing: 4,
                    children: [
                      _Meta(
                        icon: Icons.schedule_rounded,
                        text: '≈ ${context.l10n.durationShort(scenario.durationMinutes)}',
                      ),
                      _Meta(
                        icon: Icons.account_balance_wallet_outlined,
                        text: Fmt.approxTenge(scenario.totalCost),
                      ),
                    ],
                  ),
                  if (scenario.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [for (final tag in scenario.tags) MiniTag(tag)],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.inkSecondary),
        const SizedBox(width: 4),
        Text(text, style: AppText.captionStrong),
      ],
    );
  }
}
