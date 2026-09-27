import 'package:flutter/material.dart';

import 'package:bugin/theme/app_colors.dart';

/// Типографическая шкала: 32 / 28 / 24 / 20 / 18 / 17 / 16 / 15 / 14 / 13 / 12.
/// Минимальный размер текста — 12.
abstract final class AppText {
  static const family = 'Manrope';

  static const display = TextStyle(
    fontFamily: family,
    fontSize: 28,
    height: 1.22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    color: AppColors.ink,
  );

  static const heroTitle = TextStyle(
    fontFamily: family,
    fontSize: 32,
    height: 1.18,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    color: Colors.white,
  );

  static const h1 = TextStyle(
    fontFamily: family,
    fontSize: 24,
    height: 1.25,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.ink,
  );

  static const h2 = TextStyle(
    fontFamily: family,
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    color: AppColors.ink,
  );

  static const h3 = TextStyle(
    fontFamily: family,
    fontSize: 18,
    height: 1.33,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
  );

  static const title = TextStyle(
    fontFamily: family,
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const titleSmall = TextStyle(
    fontFamily: family,
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const body = TextStyle(
    fontFamily: family,
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.inkBody,
  );

  static const bodyStrong = TextStyle(
    fontFamily: family,
    fontSize: 15,
    height: 1.35,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const label = TextStyle(
    fontFamily: family,
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const caption = TextStyle(
    fontFamily: family,
    fontSize: 13,
    height: 1.38,
    fontWeight: FontWeight.w500,
    color: AppColors.inkSecondary,
  );

  static const captionStrong = TextStyle(
    fontFamily: family,
    fontSize: 13,
    height: 1.38,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const micro = TextStyle(
    fontFamily: family,
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w600,
    color: AppColors.inkSecondary,
  );
}
