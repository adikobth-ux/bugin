import 'package:flutter/widgets.dart';

/// Сетка отступов 4/8 pt.
abstract final class AppInsets {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double section = 28;

  /// Горизонтальный отступ экрана.
  static const double screen = 16;
}

/// Скругления.
abstract final class AppRadii {
  static const double sm = 12;
  static const double md = 16;
  static const double card = 18;
  static const double lg = 20;
  static const double xl = 24;
  static const double pill = 999;

  static const smAll = BorderRadius.all(Radius.circular(sm));
  static const mdAll = BorderRadius.all(Radius.circular(md));
  static const cardAll = BorderRadius.all(Radius.circular(card));
  static const lgAll = BorderRadius.all(Radius.circular(lg));
  static const xlAll = BorderRadius.all(Radius.circular(xl));
}

/// Длительности анимаций.
abstract final class AppMotion {
  static const fast = Duration(milliseconds: 140);
  static const normal = Duration(milliseconds: 240);
  static const slow = Duration(milliseconds: 400);
}

/// Минимальная зона нажатия (iOS HIG / Material).
const double kMinTapTarget = 44;
