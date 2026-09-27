import 'package:flutter/material.dart';

import 'package:bugin/l10n/app_strings.dart';
import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_text.dart';
import 'package:bugin/widgets/buttons.dart';

/// Пустое состояние: что здесь будет и что сделать.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: AppColors.primaryInk),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppText.title, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(message, style: AppText.caption, textAlign: TextAlign.center),
          if (label != null && onAction != null) ...[
            const SizedBox(height: 16),
            PrimaryButton(
              label: label,
              onPressed: onAction,
              variant: ButtonVariant.soft,
              height: 44,
              expand: false,
            ),
          ],
        ],
      ),
    );
  }
}

/// Ошибка загрузки с повтором.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EmptyState(
      icon: Icons.wifi_off_rounded,
      title: l10n.loadErrorTitle,
      message: l10n.loadErrorMessage,
      actionLabel: l10n.retry,
      onAction: onRetry,
    );
  }
}
