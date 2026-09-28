import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Открывает внешние ссылки: покупку билета на Ticketon или Kino.kz,
/// бронь на сайте заведения. Bugin сам ничего не продаёт.
abstract interface class ExternalLinks {
  /// Открывает ссылку в приложении оператора, если оно установлено,
  /// иначе в браузере. Возвращает false, если открыть не удалось.
  Future<bool> open(Uri uri);
}

class UrlLauncherLinks implements ExternalLinks {
  const UrlLauncherLinks();

  @override
  Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (error) {
      debugPrint('Не удалось открыть $uri: $error');
      return false;
    }
  }
}

/// Для тестов: запоминает ссылки вместо открытия.
class RecordingLinks implements ExternalLinks {
  final List<Uri> opened = [];

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return true;
  }
}

/// Название оператора по ссылке: «Ticketon», «Kino.kz» или домен сайта.
String linkProviderName(Uri uri) {
  final host = uri.host.toLowerCase().replaceFirst(RegExp(r'^www\.'), '');
  if (host == 'ticketon.kz' || host.endsWith('.ticketon.kz')) {
    return 'Ticketon';
  }
  if (host == 'kino.kz' || host.endsWith('.kino.kz')) {
    return 'Kino.kz';
  }
  return host;
}
