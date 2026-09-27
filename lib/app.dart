import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:bugin/navigation/app_router.dart';
import 'package:bugin/navigation/app_routes.dart';
import 'package:bugin/services/app_services.dart';
import 'package:bugin/theme/app_theme.dart';

class BuginApp extends StatelessWidget {
  const BuginApp({super.key, required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: services,
      child: MaterialApp(
        title: 'Bugin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        locale: const Locale('ru'),
        supportedLocales: const [Locale('ru'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        initialRoute: AppRoutes.shell,
        onGenerateRoute: AppRouter.onGenerateRoute,
        onUnknownRoute: AppRouter.onUnknownRoute,
        builder: (context, child) {
          // Системный шрифт учитываем, но не даём ему разломать вёрстку.
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(
              textScaler: media.textScaler.clamp(
                minScaleFactor: 0.9,
                maxScaleFactor: 1.3,
              ),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
