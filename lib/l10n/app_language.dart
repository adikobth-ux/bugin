import 'package:flutter/widgets.dart';

/// Языки приложения. Русский — основной, казахский — полный перевод.
enum AppLanguage {
  ru('ru', 'Русский'),
  kk('kk', 'Қазақша');

  const AppLanguage(this.code, this.nativeName);

  /// Код ISO 639-1: он же уходит в заголовок Accept-Language для backend.
  final String code;

  /// Название языка на нём самом — так его и показываем в настройках.
  final String nativeName;

  Locale get locale => Locale(code);

  static AppLanguage? tryParse(String? code) {
    for (final value in AppLanguage.values) {
      if (value.code == code) {
        return value;
      }
    }
    return null;
  }

  /// Первый поддерживаемый язык из настроек устройства, иначе русский.
  static AppLanguage fromLocales(Iterable<Locale> locales) {
    for (final locale in locales) {
      final match = tryParse(locale.languageCode);
      if (match != null) {
        return match;
      }
    }
    return AppLanguage.ru;
  }
}

/// Текущий язык приложения. Сервисы спрашивают его при каждом запросе:
/// mock отдаёт данные на этом языке, backend получит его в Accept-Language.
typedef CurrentLanguage = AppLanguage Function();
