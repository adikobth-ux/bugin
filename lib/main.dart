import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bugin/app.dart';
import 'package:bugin/l10n/app_language.dart';
import 'package:bugin/services/app_services.dart';
import 'package:bugin/services/location.dart';
import 'package:bugin/services/storage/shared_prefs_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Сохранённые избранное, профиль и настройки читаем до первого кадра.
  final storage = await SharedPrefsStore.open();
  final deviceLanguage = AppLanguage.fromLocales(
    WidgetsBinding.instance.platformDispatcher.locales,
  );

  // Адрес сервера задаётся при сборке: --dart-define=BUGIN_API_URL=https://…
  // Без него приложение работает на тестовых данных прототипа.
  const apiUrl = String.fromEnvironment('BUGIN_API_URL');

  runApp(
    BuginApp(
      services: apiUrl.isEmpty
          ? AppServices.mock(storage: storage, deviceLanguage: deviceLanguage)
          : AppServices.api(
              baseUrl: Uri.parse(apiUrl),
              storage: storage,
              deviceLanguage: deviceLanguage,
              locationSource: const DeviceLocationSource(),
            ),
    ),
  );
}
