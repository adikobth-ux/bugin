import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bugin/core/formatters.dart';
import 'package:bugin/l10n/app_strings.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/navigation/app_navigator.dart';
import 'package:bugin/navigation/app_tab.dart';
import 'package:bugin/services/app_services.dart';
import 'package:bugin/services/favorites_store.dart';
import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_spacing.dart';
import 'package:bugin/theme/app_text.dart';
import 'package:bugin/theme/visuals.dart';
import 'package:bugin/widgets/layout.dart';
import 'package:bugin/widgets/media_row_card.dart';
import 'package:bugin/widgets/meta_line.dart';
import 'package:bugin/widgets/pressable.dart';
import 'package:bugin/widgets/segmented_tabs.dart';
import 'package:bugin/widgets/skeleton.dart';
import 'package:bugin/widgets/snack.dart';
import 'package:bugin/widgets/state_views.dart';

/// Избранное: вкладка показывает только свой список, без смешанных секций.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final FavoritesStore _store;
  List<Place>? _places;
  List<Event>? _events;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _store = AppScope.of(context).favorites;
    _store.addListener(_onStoreChanged);
    _load();
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  Future<void> _load() async {
    final services = AppScope.of(context);
    try {
      final placesFuture = services.places.byIds(_store.placeIds);
      final eventsFuture = services.events.byIds(_store.eventIds);
      final places = await placesFuture;
      final events = await eventsFuture;
      if (!mounted) {
        return;
      }
      setState(() {
        _places = places;
        _events = events;
        _failed = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _failed = true);
      }
    }
  }

  /// Удаление показываем сразу; новые id догружаем без мигания списка.
  void _onStoreChanged() {
    final knownPlaces = _places?.map((p) => p.id).toSet() ?? <String>{};
    final knownEvents = _events?.map((e) => e.id).toSet() ?? <String>{};
    final hasNew = _store.placeIds.any((id) => !knownPlaces.contains(id)) ||
        _store.eventIds.any((id) => !knownEvents.contains(id));
    if (hasNew) {
      _load();
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _remove(FavoriteKind kind, String id, String name) {
    final index = _store.remove(kind, id);
    HapticFeedback.lightImpact();
    final l10n = context.l10n;
    showAppSnack(
      context,
      l10n.favorites.removed(name),
      actionLabel: l10n.undo,
      onAction: () => _store.restore(kind, id, index),
    );
  }

  void _removeScenario(Scenario scenario) {
    final index = _store.remove(FavoriteKind.scenario, scenario.id);
    HapticFeedback.lightImpact();
    final l10n = context.l10n;
    showAppSnack(
      context,
      l10n.favorites.scenarioRemoved(scenario.title),
      actionLabel: l10n.undo,
      onAction: () => _store.restoreScenario(scenario, index),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context).state;
    final l10n = context.l10n;
    return TabPage(
      child: ValueListenableBuilder<FavoritesSection>(
        valueListenable: state.favoritesSection,
        builder: (context, section, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Semantics(
                header: true,
                child: Text(l10n.favorites.title, style: AppText.display),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: SegmentedTabs<FavoritesSection>(
                items: [
                  SegmentItem(
                    value: FavoritesSection.places,
                    label: l10n.label(FavoritesSection.places),
                    count: _store.count(FavoriteKind.place),
                  ),
                  SegmentItem(
                    value: FavoritesSection.events,
                    label: l10n.label(FavoritesSection.events),
                    count: _store.count(FavoriteKind.event),
                  ),
                  SegmentItem(
                    value: FavoritesSection.scenarios,
                    label: l10n.label(FavoritesSection.scenarios),
                    count: _store.count(FavoriteKind.scenario),
                  ),
                ],
                value: section,
                onChanged: (next) {
                  HapticFeedback.selectionClick();
                  state.favoritesSection.value = next;
                },
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.normal,
                child: KeyedSubtree(
                  key: ValueKey(section),
                  child: _failed
                      ? Center(child: ErrorState(onRetry: _load))
                      : switch (section) {
                          FavoritesSection.places => _placesList(),
                          FavoritesSection.events => _eventsList(),
                          FavoritesSection.scenarios => _scenariosList(),
                        },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(List<Widget> children) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          children[i],
        ],
      ],
    );
  }

  Widget _loading() => ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: const [SkeletonList(count: 4, imageSize: 84)],
      );

  Widget _empty(EmptyState state) => ListView(
        padding: const EdgeInsets.only(top: 24),
        children: [state],
      );

  Widget _placesList() {
    final loaded = _places;
    if (loaded == null) {
      return _loading();
    }
    final byId = {for (final p in loaded) p.id: p};
    final items = _store.placeIds.map((id) => byId[id]).whereType<Place>().toList();
    final l10n = context.l10n;
    if (items.isEmpty) {
      return _empty(
        EmptyState(
          icon: Icons.place_outlined,
          title: l10n.favorites.noPlaces,
          message: l10n.favorites.noPlacesMessage,
          actionLabel: l10n.favorites.findPlace,
          onAction: () => AppNavigator.goToTab(context, AppTab.home),
        ),
      );
    }
    return _list([
      for (final place in items)
        MediaRowCard(
          image: place.cover,
          title: place.name,
          placeholderIcon: Visuals.placeIcon(place.category),
          placeholderTone: Visuals.placeTone(place.category),
          lines: [
            Text(
              '${l10n.label(place.category)} · ${Fmt.distance(place.distanceKm)}',
              style: AppText.caption,
            ),
            MetaLine(
              rating: place.rating,
              parts: [l10n.averageCheck(place.averageCheck)],
            ),
          ],
          trailing: _RemoveHeart(
            onTap: () => _remove(FavoriteKind.place, place.id, place.name),
          ),
          onTap: () => AppNavigator.openPlace(context, place.id),
        ),
    ]);
  }

  Widget _eventsList() {
    final loaded = _events;
    if (loaded == null) {
      return _loading();
    }
    final byId = {for (final e in loaded) e.id: e};
    final items = _store.eventIds.map((id) => byId[id]).whereType<Event>().toList();
    final l10n = context.l10n;
    if (items.isEmpty) {
      return _empty(
        EmptyState(
          icon: Icons.confirmation_number_outlined,
          title: l10n.favorites.noEvents,
          message: l10n.favorites.noEventsMessage,
          actionLabel: l10n.favorites.openAfisha,
          onAction: () => AppNavigator.goToTab(context, AppTab.afisha),
        ),
      );
    }
    return _list([
      for (final event in items)
        MediaRowCard(
          image: event.image,
          title: event.title,
          overline: l10n.eventWhen(event.startsAt),
          placeholderIcon: Visuals.eventIcon(event.category),
          placeholderTone: Visuals.eventTone(event.category),
          lines: [
            Text(
              '${event.venueName} · ${l10n.fromTenge(event.priceFrom)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.caption,
            ),
          ],
          trailing: _RemoveHeart(
            onTap: () => _remove(FavoriteKind.event, event.id, event.title),
          ),
          onTap: () => AppNavigator.openEvent(context, event.id),
        ),
    ]);
  }

  Widget _scenariosList() {
    final items = _store.scenarios;
    final l10n = context.l10n;
    if (items.isEmpty) {
      return _empty(
        EmptyState(
          icon: Icons.auto_awesome,
          title: l10n.favorites.noScenarios,
          message: l10n.favorites.noScenariosMessage,
          actionLabel: l10n.favorites.planEvening,
          onAction: () => AppNavigator.openEveningForm(context),
        ),
      );
    }
    return _list([
      for (final scenario in items)
        MediaRowCard(
          image: scenario.cover,
          title: scenario.title,
          lines: [
            Text(
              scenario.route,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppText.caption,
            ),
            Text(
              '${Fmt.approxTenge(scenario.totalCost)} · '
              '${l10n.favorites.stopsCount(scenario.stops.length)}',
              style: AppText.captionStrong,
            ),
          ],
          trailing: _RemoveHeart(onTap: () => _removeScenario(scenario)),
          onTap: () => AppNavigator.openPlan(context, scenario: scenario),
        ),
    ]);
  }
}

class _RemoveHeart extends StatelessWidget {
  const _RemoveHeart({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.85,
      semanticLabel: context.l10n.removeFromFavorites,
      child: const SizedBox.square(
        dimension: 44,
        child: Icon(Icons.favorite_rounded, size: 22, color: AppColors.primary),
      ),
    );
  }
}
