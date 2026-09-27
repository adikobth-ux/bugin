import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:bugin/l10n/app_language.dart';
import 'package:bugin/l10n/app_strings.dart';
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
      child: ValueListenableBuilder<AppLanguage>(
        valueListenable: services.state.language,
        // При смене языка приложение пересобирается целиком: экраны заново
        // загружают данные на новом языке. Открытая вкладка сохраняется.
        builder: (context, language, _) => MaterialApp(
          key: ValueKey<AppLanguage>(language),
          onGenerateTitle: (context) => context.l10n.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          locale: language.locale,
          supportedLocales: AppStrings.supportedLocales,
          localizationsDelegates: const [
            AppStrings.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          initialRoute: AppRoutes.shell,
          onGenerateRoute: AppRouter.onGenerateRoute,
          onUnknownRoute: AppRouter.onUnknownRoute,
          builder: (context, child) {
            // Системный размер шрифта учитываем, но не даём ему разломать вёрстку.
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
      ),
    );
  }
}
