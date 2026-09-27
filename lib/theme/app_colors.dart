import 'package:flutter/material.dart';

/// Палитра Bugin. Все цвета интерфейса берутся только отсюда.
abstract final class AppColors {
  // Фон и поверхности
  static const background = Color(0xFFF5F6FB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF5F6FB);
  static const segmentTrack = Color(0xFFE9EAF4);
  static const skeleton = Color(0xFFE9EBF3);

  // Текст (контраст вторичного текста ≥ 4.5:1 на фоне)
  static const ink = Color(0xFF151833);
  static const inkSecondary = Color(0xFF5B6178);
  static const inkBody = Color(0xFF3F4460);
  static const inkMuted = Color(0xFF6B7185);

  // Линии
  static const line = Color(0xFFE7E9F2);
  static const divider = Color(0xFFEEF0F6);
  static const timeline = Color(0xFFDADCF0);

  // Бренд
  static const primary = Color(0xFF5B5BF0);
  static const primarySoft = Color(0xFFEEEEFD);
  static const primaryTint = Color(0xFFF3F3FE);
  static const primaryInk = Color(0xFF4441D4);
  static const primaryBorder = Color(0xFFD9D8FB);
  static const primaryDashed = Color(0xFF8F8DF2);

  // Статусы
  static const success = Color(0xFF177A4C);
  static const danger = Color(0xFFC0304A);
  static const star = Color(0xFFE89A1C);
  static const starOnImage = Color(0xFFFFC24D);

  // Всплывающие сообщения
  static const snackbar = Color(0xFF151833);
  static const snackbarAction = Color(0xFFB9B7FF);

  // Поверх фото
  static const overlayButton = Color(0x80151833);
  static const onImageSurface = Color(0xF0FFFFFF);
  static const onImageText = Color(0xF0FFFFFF);
  static const heroScrimTop = Color(0x590C0E1E);
  static const heroScrimClear = Color(0x000C0E1E);
  static const heroScrimMid = Color(0x1A0C0E1E);
  static const heroScrimBottom = Color(0xD90C0E1E);
  static const whiteGlass = Color(0x29FFFFFF);

  // Тени
  static const shadow = Color(0x0F151833);
  static const shadowStrong = Color(0x40151833);
  static const shadowPrimary = Color(0x595B5BF0);

  // Тональные пары категорий
  static const pinkBg = Color(0xFFFDECF1);
  static const pinkFg = Color(0xFFD63C6E);
  static const violetBg = Color(0xFFEEEAFE);
  static const violetFg = Color(0xFF6D4FE8);
  static const mintBg = Color(0xFFE5F5EC);
  static const mintFg = Color(0xFF1B8A57);
  static const peachBg = Color(0xFFFFF0E2);
  static const peachFg = Color(0xFFD2641C);
  static const blueBg = Color(0xFFE6EFFD);
  static const blueFg = Color(0xFF2C64CF);
}

/// Пара «фон + акцент» для категорий, чипов и плейсхолдеров.
class Tone {
  const Tone(this.background, this.foreground);

  final Color background;
  final Color foreground;

  static const pink = Tone(AppColors.pinkBg, AppColors.pinkFg);
  static const violet = Tone(AppColors.violetBg, AppColors.violetFg);
  static const mint = Tone(AppColors.mintBg, AppColors.mintFg);
  static const peach = Tone(AppColors.peachBg, AppColors.peachFg);
  static const blue = Tone(AppColors.blueBg, AppColors.blueFg);
  static const brand = Tone(AppColors.primarySoft, AppColors.primaryInk);
  static const neutral = Tone(AppColors.surfaceMuted, AppColors.inkSecondary);
}
