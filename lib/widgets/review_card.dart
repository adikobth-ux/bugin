import 'package:flutter/material.dart';

import 'package:bugin/core/formatters.dart';
import 'package:bugin/l10n/app_strings.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_text.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review});

  final Review review;

  static const _tones = [
    Tone.pink,
    Tone.violet,
    Tone.mint,
    Tone.peach,
    Tone.blue,
  ];

  @override
  Widget build(BuildContext context) {
    final tone = _tones[review.author.hashCode.abs() % _tones.length];
    final initial = review.author.isEmpty
        ? '?'
        : String.fromCharCode(review.author.runes.first).toUpperCase();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: tone.background, shape: BoxShape.circle),
                child: Text(
                  initial,
                  style: AppText.label.copyWith(
                    color: tone.foreground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.author, style: AppText.label.copyWith(fontWeight: FontWeight.w700)),
                    Text(context.l10n.ago(review.date), style: AppText.micro),
                  ],
                ),
              ),
              const Icon(Icons.star_rounded, size: 16, color: AppColors.star),
              const SizedBox(width: 2),
              Text(Fmt.rating(review.rating), style: AppText.captionStrong),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.text, style: AppText.body.copyWith(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}
