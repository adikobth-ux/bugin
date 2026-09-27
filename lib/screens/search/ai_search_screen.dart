import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bugin/l10n/app_strings.dart';
import 'package:bugin/navigation/app_routes.dart';
import 'package:bugin/services/app_services.dart';
import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_spacing.dart';
import 'package:bugin/theme/app_text.dart';
import 'package:bugin/theme/app_theme.dart';
import 'package:bugin/widgets/buttons.dart';
import 'package:bugin/widgets/info_card.dart';
import 'package:bugin/widgets/layout.dart';
import 'package:bugin/widgets/pressable.dart';

/// Полноэкранный ввод запроса на естественном языке.
class AiSearchScreen extends StatefulWidget {
  const AiSearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<AiSearchScreen> createState() => _AiSearchScreenState();
}

class _AiSearchScreenState extends State<AiSearchScreen> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialQuery);
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_rebuild);
    _focus.addListener(_rebuild);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_rebuild)
      ..dispose();
    _focus
      ..removeListener(_rebuild)
      ..dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  void _submit([String? preset]) {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty) {
      return;
    }
    HapticFeedback.lightImpact();
    _focus.unfocus();
    Navigator.of(context).pushNamed(AppRoutes.processing, arguments: text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = l10n.search;
    final search = AppScope.of(context).search;
    final recent = search.recentQueries;
    final canSubmit = _controller.text.trim().isNotEmpty;

    return AnnotatedRegion(
      value: AppTheme.overlayOnLight,
      child: Scaffold(
        body: SafeArea(
          child: ContentWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                Row(
                  children: [
                    AppBackButton(icon: Icons.close_rounded, semanticLabel: l10n.close),
                    const SizedBox(width: 8),
                    Text(s.newQuery, style: AppText.title),
                  ],
                ),
                const SizedBox(height: 20),
                Semantics(
                  header: true,
                  child: Text(s.title, style: AppText.h1),
                ),
                const SizedBox(height: 12),
                AnimatedContainer(
                  duration: AppMotion.normal,
                  padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _focus.hasFocus ? AppColors.primary : AppColors.line,
                      width: _focus.hasFocus ? 2 : 1,
                    ),
                    boxShadow: _focus.hasFocus
                        ? const [BoxShadow(color: Color(0x1F5B5BF0), spreadRadius: 4)]
                        : const [],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _controller,
                        focusNode: _focus,
                        autofocus: widget.initialQuery.isEmpty,
                        minLines: 3,
                        maxLines: 5,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.search,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _submit(),
                        style: AppText.title.copyWith(fontWeight: FontWeight.w500, height: 1.4),
                        decoration: InputDecoration.collapsed(
                          hintText: s.inputHint,
                          hintStyle: AppText.title.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.inkMuted,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              s.writeLikeFriend,
                              style: AppText.caption,
                            ),
                          ),
                          CircleIconButton(
                            icon: Icons.arrow_forward_rounded,
                            style: CircleButtonStyle.primary,
                            size: 48,
                            iconSize: 22,
                            semanticLabel: s.find,
                            onPressed: canSubmit ? _submit : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(s.tryThis, style: AppText.title),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final suggestion in search.suggestions)
                      _SuggestionChip(
                        text: suggestion,
                        onTap: () => _submit(suggestion),
                      ),
                  ],
                ),
                if (recent.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(child: Text(s.recent, style: AppText.title)),
                      LinkButton(
                        label: s.clearHistory,
                        showChevron: false,
                        onTap: () => setState(search.clearHistory),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InfoCard(
                    children: [
                      for (final query in recent)
                        _RecentRow(query: query, onTap: () => _submit(query)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Text(text, style: AppText.label.copyWith(fontWeight: FontWeight.w500)),
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.query, required this.onTap});

  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.99,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 54),
        child: Row(
          children: [
            const Icon(Icons.history_rounded, size: 20, color: AppColors.inkSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                query,
                style: AppText.label.copyWith(fontWeight: FontWeight.w500, fontSize: 15),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.inkSecondary),
          ],
        ),
      ),
    );
  }
}
