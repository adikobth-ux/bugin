import 'package:flutter/material.dart';

import 'package:bugin/l10n/app_strings.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/navigation/app_routes.dart';
import 'package:bugin/services/app_services.dart';
import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_text.dart';
import 'package:bugin/theme/app_theme.dart';
import 'package:bugin/theme/visuals.dart';
import 'package:bugin/widgets/buttons.dart';
import 'package:bugin/widgets/chips.dart';
import 'package:bugin/widgets/layout.dart';
import 'package:bugin/widgets/skeleton.dart';
import 'package:bugin/widgets/state_views.dart';

/// Экран «думаю»: показывает, что AI понял, и как идёт подбор.
class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key, required this.query});

  final String query;

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

enum _Step { understanding, searching, ranking }

class _ProcessingScreenState extends State<ProcessingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  _Step _step = _Step.understanding;
  SearchIntent? _intent;
  int _found = 0;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _retry() async {
    setState(() {
      _failed = false;
      _step = _Step.understanding;
      _intent = null;
    });
    await _run();
  }

  Future<void> _run() async {
    final services = AppScope.of(context);
    final navigator = Navigator.of(context);
    try {
      final intent = await services.search.understand(widget.query);
      if (!mounted) {
        return;
      }
      setState(() {
        _intent = intent;
        _step = _Step.searching;
      });

      final items = await services.search.recommend(intent);
      if (!mounted) {
        return;
      }
      setState(() {
        _found = items.length;
        _step = _Step.ranking;
      });

      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) {
        return;
      }
      services.search.remember(widget.query);
      services.profile.countSearch();
      navigator.pushReplacementNamed(
        AppRoutes.results,
        arguments: ResultsArgs(intent: intent, items: items),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _failed = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final intent = _intent;
    final l10n = context.l10n;
    final s = l10n.search;
    return AnnotatedRegion(
      value: AppTheme.overlayOnLight,
      child: Scaffold(
        body: SafeArea(
          child: ContentWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppBackButton(
                    icon: Icons.close_rounded,
                    semanticLabel: s.cancelSearch,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.yourQuery, style: AppText.micro),
                      const SizedBox(height: 4),
                      Text(
                        widget.query,
                        style: AppText.bodyStrong.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                if (_failed)
                  ErrorState(onRetry: _retry)
                else ...[
                  Center(
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.94, end: 1.06).animate(
                        CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                      ),
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                          color: AppColors.primarySoft,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowPrimary,
                                blurRadius: 24,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    s.processingTitle,
                    textAlign: TextAlign.center,
                    style: AppText.h1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.processingHint,
                    textAlign: TextAlign.center,
                    style: AppText.caption,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StepRow(
                          state: _stateOf(_Step.understanding),
                          label: s.stepUnderstood,
                          activeLabel: s.stepUnderstanding,
                          child: intent == null
                              ? null
                              : Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    for (final p in intent.params)
                                      MiniTag(l10n.paramLabel(p), tone: Visuals.param(p).$2),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 14),
                        _StepRow(
                          state: _stateOf(_Step.searching),
                          label: s.stepFound(_found),
                          activeLabel: s.stepSearching,
                        ),
                        const SizedBox(height: 14),
                        _StepRow(
                          state: _stateOf(_Step.ranking),
                          label: s.stepRanking,
                          activeLabel: s.stepRanking,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SkeletonList(count: 2),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  _StepState _stateOf(_Step step) {
    if (step.index < _step.index) {
      return _StepState.done;
    }
    if (step == _step) {
      return _StepState.active;
    }
    return _StepState.pending;
  }
}

enum _StepState { done, active, pending }

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.state,
    required this.label,
    required this.activeLabel,
    this.child,
  });

  final _StepState state;
  final String label;
  final String activeLabel;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final Widget indicator = switch (state) {
      _StepState.done => Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
        ),
      _StepState.active => const SizedBox(
          width: 24,
          height: 24,
          child: Padding(
            padding: EdgeInsets.all(2),
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary,
              backgroundColor: AppColors.primarySoft,
            ),
          ),
        ),
      _StepState.pending => Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.line, width: 2),
          ),
        ),
    };
    final extra = child;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: KeyedSubtree(key: ValueKey(state), child: indicator)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  state == _StepState.done ? label : activeLabel,
                  style: AppText.bodyStrong.copyWith(
                    fontWeight: FontWeight.w600,
                    color: state == _StepState.pending ? AppColors.inkMuted : AppColors.ink,
                  ),
                ),
              ),
              if (extra != null && state == _StepState.done) ...[
                const SizedBox(height: 8),
                extra,
              ],
            ],
          ),
        ),
      ],
    );
  }
}
