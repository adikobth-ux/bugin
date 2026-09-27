import 'package:flutter/material.dart';

import 'package:bugin/l10n/app_strings.dart';
import 'package:bugin/l10n/sections/home_strings.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/navigation/app_navigator.dart';
import 'package:bugin/navigation/app_tab.dart';
import 'package:bugin/services/app_services.dart';
import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_text.dart';
import 'package:bugin/widgets/chips.dart';
import 'package:bugin/widgets/city_button.dart';
import 'package:bugin/widgets/layout.dart';
import 'package:bugin/widgets/place_card.dart';
import 'package:bugin/widgets/pressable.dart';
import 'package:bugin/widgets/scenario_card.dart';
import 'package:bugin/widgets/search_entry.dart';
import 'package:bugin/widgets/section_header.dart';
import 'package:bugin/widgets/skeleton.dart';
import 'package:bugin/widgets/state_views.dart';

class _Intent {
  const _Intent(this.label, this.icon, this.tone, this.query);

  final String label;
  final IconData icon;
  final Tone tone;

  /// Готовый запрос, который уходит в AI-поиск.
  final String query;
}

/// Быстрые намерения на текущем языке: подпись и запрос — из раздела текстов.
List<_Intent> _intents(HomeStrings s) => [
      _Intent(
        s.intentDate,
        Icons.favorite_border_rounded,
        Tone.pink,
        s.intentDateQuery,
      ),
      _Intent(s.intentCoffee, Icons.local_cafe_outlined, Tone.mint, s.intentCoffeeQuery),
      _Intent(
        s.intentActive,
        Icons.fitness_center_rounded,
        Tone.violet,
        s.intentActiveQuery,
      ),
      _Intent(s.intentNovelty, Icons.lightbulb_outline, Tone.peach, s.intentNoveltyQuery),
      _Intent(s.intentWork, Icons.laptop_outlined, Tone.blue, s.intentWorkQuery),
    ];

class _HomeData {
  const _HomeData(this.nearby, this.scenario);

  final List<Place> nearby;
  final Scenario scenario;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HomeData> _load() async {
    final services = AppScope.of(context);
    final nearby = services.places.nearby();
    final scenario = services.planner.featured();
    return _HomeData(await nearby, await scenario);
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() => _future = next);
    try {
      await next;
    } catch (_) {
      // Ошибку покажет FutureBuilder.
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final s = context.l10n.home;
    final name = services.profile.profile.name;
    final isEvening = DateTime.now().hour >= 17;

    return TabPage(
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Bugin',
                        style: AppText.display.copyWith(fontSize: 26),
                      ),
                    ),
                    const CityButton(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(s.greeting(name), style: AppText.display),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEvening ? s.eveningQuestion : s.dayQuestion,
                      style: AppText.body.copyWith(
                        fontSize: 16,
                        color: AppColors.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: SearchEntryCard(
                  onTap: () => AppNavigator.openSearch(context),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ChipRow(
                  children: [
                    for (final intent in _intents(s))
                      IntentChip(
                        icon: intent.icon,
                        label: intent.label,
                        tone: intent.tone,
                        onTap: () => AppNavigator.startSearch(context, intent.query),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _EveningBanner(
                  onTap: () => AppNavigator.openEveningForm(context),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FutureBuilder<_HomeData>(
                future: _future,
                builder: (context, snapshot) =>
                    _HomeFeed(snapshot: snapshot, onRetry: _refresh),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _EveningBanner extends StatelessWidget {
  const _EveningBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = context.l10n.home;
    return Pressable(
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.whiteGlass,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.eveningBannerTitle,
                    style: AppText.title.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.eveningBannerSubtitle,
                    style: AppText.caption.copyWith(color: AppColors.onImageText),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeFeed extends StatelessWidget {
  const _HomeFeed({required this.snapshot, required this.onRetry});

  final AsyncSnapshot<_HomeData> snapshot;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasError) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: ErrorState(onRetry: onRetry),
      );
    }
    final s = context.l10n.home;
    final data = snapshot.data;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: s.forYouToday,
          onAction: () => AppNavigator.goToTab(
            context,
            AppTab.favorites,
            section: FavoritesSection.scenarios,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: data == null
              ? const SkeletonPulse(child: SkeletonRowCard(imageSize: 104))
              : ScenarioCard(
                  scenario: data.scenario,
                  onTap: () => AppNavigator.openPlan(context, scenario: data.scenario),
                ),
        ),
        SectionHeader(
          title: s.nearbyNow,
          onAction: () => AppNavigator.startSearch(context, s.nearbyQuery),
        ),
        if (data == null)
          const _NearbySkeleton()
        else
          HorizontalCarousel(
            children: [
              for (final place in data.nearby)
                PlaceCard(
                  place: place,
                  width: carouselCardWidth(context),
                  onTap: () => AppNavigator.openPlace(context, place.id),
                ),
            ],
          ),
      ],
    );
  }
}

class _NearbySkeleton extends StatelessWidget {
  const _NearbySkeleton();

  @override
  Widget build(BuildContext context) {
    final width = carouselCardWidth(context);
    return SkeletonPulse(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            SkeletonBox(width: width, height: 196, radius: 18),
            const SizedBox(width: 12),
            SkeletonBox(width: width, height: 196, radius: 18),
          ],
        ),
      ),
    );
  }
}
