import 'package:flutter/material.dart';

import 'package:bugin/l10n/app_strings.dart';
import 'package:bugin/theme/app_text.dart';
import 'package:bugin/widgets/buttons.dart';

/// Заголовок секции с необязательной ссылкой «Все».
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(16, 28, 12, 8),
    this.style,
  });

  final String title;
  /// Подпись ссылки; по умолчанию «Все».
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;
  final EdgeInsets padding;
  final TextStyle? style;

  /// Вариант для экранов, где горизонтальный отступ уже задан контейнером.
  const SectionHeader.inset({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
    this.style = AppText.h3,
  }) : padding = const EdgeInsets.only(top: 28, bottom: 8);

  @override
  Widget build(BuildContext context) {
    final action = onAction;
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: style ?? AppText.h2),
            ),
          ),
          if (trailing != null) trailing!,
          if (action != null)
            LinkButton(label: actionLabel ?? context.l10n.all, onTap: action),
        ],
      ),
    );
  }
}
