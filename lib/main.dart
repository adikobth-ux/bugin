import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bugin/app.dart';
import 'package:bugin/l10n/app_language.dart';
import 'package:bugin/services/app_services.dart';
import 'package:bugin/services/storage/shared_prefs_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Сохранённые избранное, профиль и настройки читаем до первого кадра.
  final storage = await SharedPrefsStore.open();
  final deviceLanguage = AppLanguage.fromLocales(
    WidgetsBinding.instance.platformDispatcher.locales,
  );

  runApp(
    BuginApp(
      services: AppServices.mock(storage: storage, deviceLanguage: deviceLanguage),
    ),
  );
}
