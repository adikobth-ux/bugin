import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bugin/core/formatters.dart';
import 'package:bugin/l10n/app_strings.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/navigation/app_navigator.dart';
import 'package:bugin/navigation/app_routes.dart';
import 'package:bugin/navigation/app_tab.dart';
import 'package:bugin/services/app_services.dart';
import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_spacing.dart';
import 'package:bugin/theme/app_text.dart';
import 'package:bugin/theme/app_theme.dart';
import 'package:bugin/theme/visuals.dart';
import 'package:bugin/widgets/app_image.dart';
import 'package:bugin/widgets/app_sheet.dart';
import 'package:bugin/widgets/buttons.dart';
import 'package:bugin/widgets/chips.dart';
import 'package:bugin/widgets/info_card.dart';
import 'package:bugin/widgets/layout.dart';
import 'package:bugin/widgets/meta_line.dart';
import 'package:bugin/widgets/pressable.dart';
import 'package:bugin/widgets/skeleton.dart';
import 'package:bugin/widgets/snack.dart';
import 'package:bugin/widgets/state_views.dart';
import 'package:bugin/widgets/sticky_action_bar.dart';

/// План вечера: сводка параметров, итог, таймлайн с переездами и заменой точек.
class EveningPlanScreen extends StatefulWidget {
  const EveningPlanScreen({super.key, this.request, this.scenario});

  /// Если задан — план собирается заново по этим параметрам.
  final EveningRequest? request;

  /// Если задан — открывается готовый сценарий.
  final Scenario? scenario;

  @override
  State<EveningPlanScreen> createState() => _EveningPlanScreenState();
}

class _EveningPlanScreenState extends State<EveningPlanScreen> {
  Scenario? _scenario;
  bool _failed = false;
  bool _replacing = false;

  bool get _fromForm => widget.request != null;

  @override
  void initState() {
    super.initState();
    _scenario = widget.scenario;
    if (_scenario == null) {
      _generate();
    }
  }

  Future<void> _generate() async {
    final request = widget.request;
    if (request == null) {
      return;
    }
    final planner = AppScope.of(context).planner;
    if (_failed) {
      setState(() => _failed = false);
    }
    try {
      final scenario = await planner.plan(request);
      if (!mounted) {
        return;
      }
      HapticFeedback.lightImpact();
      setState(() => _scenario = scenario);
    } catch (_) {
      if (mounted) {
        setState(() => _failed = true);
      }
    }
  }

  String _altSubtitle(AppStrings l10n, PlanStop stop) {
    final parts = <String>[stop.kindLabel];
    final rating = stop.rating;
    if (rating != null) {
      parts.add('★ ${Fmt.rating(rating)}');
    }
    parts.add(l10n.averageCheck(stop.cost));
    return parts.join(' · ');
  }

  Future<void> _replace(int index) async {
    final scenario = _scenario;
    if (scenario == null) {
      return;
    }
    final l10n = context.l10n;
    final s = l10n.evening;
    final planner = AppScope.of(context).planner;
    final alternatives = await planner.alternatives(scenario, index);
    if (!mounted) {
      return;
    }
    final current = scenario.stops[index];
    final picked = await showAppSheet<PlanStop>(
      context,
      title: s.replaceTitle(current.title),
      subtitle: scenario.request?.budget != null ? s.onlyWithinBudget : null,
      builder: (sheetContext) => alternatives.isEmpty
          ? Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                s.noAlternatives,
                style: AppText.caption,
              ),
            )
          : Column(
              children: [
                for (final alt in alternatives)
                  SheetOption(
                    label: alt.title,
                    subtitle: _altSubtitle(l10n, alt),
                    selected: false,
                    onTap: () => Navigator.of(sheetContext).pop(alt),
                  ),
              ],
            ),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _replacing = true);
    try {
      final next = await planner.replaceStop(scenario, index, picked);
      if (!mounted) {
        return;
      }
      HapticFeedback.selectionClick();
      setState(() => _scenario = next);
      showAppSnack(context, s.replaced(picked.title));
    } finally {
      if (mounted) {
        setState(() => _replacing = false);
      }
    }
  }

  void _save() {
    final scenario = _scenario;
    if (scenario == null) {
      return;
    }
    final s = context.l10n.evening;
    final services = AppScope.of(context);
    final navigator = Navigator.of(context);
    services.favorites.saveScenario(scenario);
    HapticFeedback.mediumImpact();
    showAppSnack(
      context,
      s.savedToFavorites,
      actionLabel: s.open,
      onAction: () {
        services.state.favoritesSection.value = FavoritesSection.scenarios;
        services.state.tab.value = AppTab.favorites;
        navigator.popUntil((route) => route.isFirst);
      },
    );
  }

  void _edit() {
    if (_fromForm) {
      Navigator.of(context).maybePop();
      return;
    }
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.eveningForm,
      arguments: _scenario?.request,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scenario = _scenario;
    final favorites = AppScope.of(context).favorites;
    final l10n = context.l10n;
    final strings = l10n.evening;

    return AnnotatedRegion(
      value: AppTheme.overlayOnLight,
      child: Scaffold(
        bottomNavigationBar: scenario == null
            ? null
            : StickyActionBar(
                child: ListenableBuilder(
                  listenable: favorites,
                  builder: (context, _) {
                    final saved = favorites.hasScenario(scenario.id);
                    final upToDate = saved &&
                        identical(
                          favorites.scenarios.firstWhere((s) => s.id == scenario.id),
                          scenario,
                        );
                    return Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: upToDate ? strings.saved : (saved ? strings.update : l10n.save),
                            icon: upToDate
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            variant: ButtonVariant.outline,
                            onPressed: upToDate ? null : _save,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PrimaryButton(
                            label: l10n.route,
                            icon: Icons.near_me_outlined,
                            onPressed: () => showDemoSnack(
                              context,
                              strings.routeDemo,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
        body: SafeArea(
          bottom: false,
          child: ContentWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Row(
                  children: [
                    const AppBackButton(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _fromForm ? strings.yourEvening : l10n.scenario,
                        style: AppText.title,
                      ),
                    ),
                    LinkButton(
                      label: strings.edit,
                      icon: Icons.edit_outlined,
                      onTap: _edit,
                    ),
                  ],
                ),
                if (_failed)
                  ErrorState(onRetry: _generate)
                else if (scenario == null)
                  const _PlanLoading()
                else
                  ..._content(scenario),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _content(Scenario scenario) {
    final l10n = context.l10n;
    final request = scenario.request;
    final chips = request == null
        ? scenario.tags
        : [
            l10n.label(request.company),
            '${_capitalize(l10n.requestDay(request))} ${l10n.fromTime(request.startMinutes)}',
            request.budget == null ? l10n.evening.budgetAny : l10n.upToTenge(request.budget!),
            l10n.label(request.mood),
          ];

    return [
      const SizedBox(height: 16),
      Semantics(header: true, child: Text(scenario.title, style: AppText.h1)),
      if (chips.isNotEmpty) ...[
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [for (final chip in chips) TagChip(chip)],
        ),
      ],
      const SizedBox(height: 14),
      _TotalCard(scenario: scenario),
      const SizedBox(height: 20),
      AnimatedOpacity(
        opacity: _replacing ? 0.5 : 1,
        duration: AppMotion.fast,
        child: _Timeline(
          scenario: scenario,
          onReplace: _replace,
          onOpen: (stop) => AppNavigator.openPlace(context, stop.placeId),
        ),
      ),
    ];
  }

  static String _capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
}

class _PlanLoading extends StatelessWidget {
  const _PlanLoading();

  @override
  Widget build(BuildContext context) {
    final s = context.l10n.evening;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        Center(
          child: SkeletonPulse(
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, size: 32, color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(s.building, textAlign: TextAlign.center, style: AppText.h3),
        const SizedBox(height: 4),
        Text(
          s.buildingHint,
          textAlign: TextAlign.center,
          style: AppText.caption,
        ),
        const SizedBox(height: 24),
        const SkeletonList(count: 3),
      ],
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.scenario});

  final Scenario scenario;

  @override
  Widget build(BuildContext context) {
    final s = context.l10n.evening;
    final fits = scenario.fitsBudget;
    final count = scenario.stops.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          const IconWell(
            Icons.account_balance_wallet_outlined,
            size: 40,
            background: AppColors.mintBg,
            color: AppColors.mintFg,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.perPerson(Fmt.approxTenge(scenario.totalCost)),
                  style: AppText.title.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    style: AppText.caption,
                    children: [
                      TextSpan(
                        text: '${s.stopsCount(count)} · '
                            '${Fmt.hm(scenario.startMinutes)}–${Fmt.hm(scenario.endMinutes)}',
                      ),
                      if (fits != null)
                        TextSpan(
                          text: ' · ${fits ? s.withinBudget : s.overBudget}',
                          style: TextStyle(
                            color: fits ? AppColors.success : AppColors.danger,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.scenario,
    required this.onReplace,
    required this.onOpen,
  });

  final Scenario scenario;
  final ValueChanged<int> onReplace;
  final ValueChanged<PlanStop> onOpen;

  @override
  Widget build(BuildContext context) {
    final stops = scenario.stops;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < stops.length; i++) ...[
          _StopRow(
            stop: stops[i],
            isLast: i == stops.length - 1,
            onReplace: () => onReplace(i),
            onOpen: () => onOpen(stops[i]),
          ),
          if (i < scenario.legs.length) _LegRow(leg: scenario.legs[i]),
        ],
      ],
    );
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({
    required this.stop,
    required this.isLast,
    required this.onReplace,
    required this.onOpen,
  });

  final PlanStop stop;
  final bool isLast;
  final VoidCallback onReplace;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isWalk = stop.role == StopRole.walk;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 56,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    Fmt.hm(stop.startMinutes),
                    style: AppText.captionStrong.copyWith(
                      color: AppColors.primaryInk,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.only(top: 6),
                      color: AppColors.timeline,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Pressable(
              onTap: onOpen,
              pressedScale: 0.98,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppImage(
                      stop.image,
                      width: 72,
                      height: 72,
                      borderRadius: BorderRadius.circular(12),
                      placeholderIcon:
                          isWalk ? Icons.directions_walk_rounded : Icons.place_outlined,
                      placeholderTone: isWalk ? Tone.mint : Tone.brand,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(stop.kindLabel, style: AppText.micro),
                          const SizedBox(height: 2),
                          Text(
                            stop.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          MetaLine(
                            rating: stop.rating,
                            parts: [
                              if (stop.rating == null) l10n.duration(stop.durationMinutes),
                              l10n.averageCheck(stop.cost),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Pressable(
                            onTap: onReplace,
                            semanticLabel: l10n.evening.replaceLabel(stop.title),
                            child: Container(
                              height: 36,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryTint,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.swap_horiz_rounded,
                                    size: 16,
                                    color: AppColors.primaryInk,
                                  ),
                                  const SizedBox(width: 5),
                                  // На узком экране с крупным шрифтом подпись
                                  // сокращается, а не вылезает за кнопку.
                                  Flexible(
                                    child: ExcludeSemantics(
                                      child: Text(
                                        l10n.evening.replace,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppText.captionStrong.copyWith(
                                          color: AppColors.primaryInk,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegRow extends StatelessWidget {
  const _LegRow({required this.leg});

  final TravelLeg leg;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Center(
              child: Container(width: 2, height: 40, color: AppColors.timeline),
            ),
          ),
          const SizedBox(width: 10),
          Icon(Visuals.travelIcon(leg.mode), size: 16, color: AppColors.inkSecondary),
          const SizedBox(width: 6),
          Text(
            '${l10n.label(leg.mode)} ${l10n.durationShort(leg.minutes)}',
            style: AppText.micro,
          ),
        ],
      ),
    );
  }
}
