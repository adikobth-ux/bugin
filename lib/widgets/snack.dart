import 'package:flutter/material.dart';

import 'package:bugin/l10n/app_strings.dart';

/// Короткое сообщение внизу экрана с необязательным действием («Вернуть»).
void showAppSnack(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(label: actionLabel, onPressed: onAction)
            : null,
      ),
    );
}

/// Сообщение для функций, которые появятся вместе с backend.
void showDemoSnack(BuildContext context, String message) =>
    showAppSnack(context, context.l10n.demo(message));
