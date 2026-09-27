import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bugin/models/models.dart';
import 'package:bugin/navigation/app_navigator.dart';
import 'package:bugin/navigation/app_routes.dart';
import 'package:bugin/services/app_services.dart';
import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_text.dart';
import 'package:bugin/theme/app_theme.dart';
import 'package:bugin/widgets/app_sheet.dart';
import 'package:bugin/widgets/bottom_navigation.dart';
import 'package:bugin/widgets/buttons.dart';
import 'package:bugin/widgets/chips.dart';
import 'package:bugin/widgets/layout.dart';
import 'package:bugin/widgets/param_chip.dart';
import 'package:bugin/widgets/pressable.dart';
import 'package:bugin/widgets/recommendation_card.dart';
import 'package:bugin/widgets/search_entry.dart';
import 'package:bugin/widgets/skeleton.dart';
import 'package:bugin/widgets/state_views.dart';

enum _KindFilter {
  all('Все'),
  restaurants('Рестораны'),
  cafes('Кафе'),
  fun('Развлечения'),
  events('События');

  const _KindFilter(this.label);

  final String label;
}

enum _Sort {
  best('Лучшее совпадение'),
  near('Сначала ближе'),
  cheap('Сначала дешевле'),
  rating('По рейтингу');

  const _Sort(this.label);

  final String label;
}

/// Выдача AI-поиска: что понял Bugin + карточки с объяснениями.
class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, required this.args});

  final ResultsArgs args;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late SearchIntent _intent = widget.args.intent;
  late List<Recommendation> _items = widget.args.items;
  bool _loading = false;
  _KindFilter _filter = _KindFilter.all;
  _Sort _sort = _Sort.best;

  Future<void> _applyIntent(SearchIntent next) async {
    final search = AppScope.of(context).search;
    HapticFeedback.selectionClick();
    setState(() {
      _intent = next;
      _loading = true;
    });
    try {
      final items = await search.recommend(next);
      if (!mounted) {
        return;
      }
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<Recommendation> get _visible {
    final filtered = _items.where((item) {
      final place = item.place;
      return switch (_filter) {
        _KindFilter.all => true,
        _KindFilter.restaurants => place?.category == PlaceCategory.restaurant,
        _KindFilter.cafes => place?.category == PlaceCategory.cafe ||
            place?.category == PlaceCategory.coffeeShop,
        _KindFilter.fun => place != null &&
            const {
              PlaceCategory.bowling,
              PlaceCategory.cinema,
              PlaceCategory.studio,
              PlaceCategory.gallery,
            }.contains(place.category),
        _KindFilter.events => item.kind == RecommendationKind.event,
      };
    }).toList();

    switch (_sort) {
      case _Sort.best:
        break;
      case _Sort.near:
        filtered.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      case _Sort.cheap:
        filtered.sort((a, b) => a.price.compareTo(b.price));
      case _Sort.rating:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return filtered;
  }

  Future<void> _editParam(IntentParam param) async {
    final options = IntentParam.options[param.type] ?? const <ParamOption>[];
    final picked = await showAppSheet<ParamOption>(
      context,
      title: param.type.label,
      subtitle: param.inferred ? 'Это я додумал сам — поправь, если не так' : null,
      builder: (sheetContext) => Column(
        children: [
          for (final option in options)
            SheetOption(
              label: option.label,
              selected: option.code == param.code,
              onTap: () => Navigator.of(sheetContext).pop(option),
            ),
        ],
      ),
    );
    if (picked == null || !mounted) {
      return;
    }
    await _applyIntent(
      _intent.withParam(IntentParam(type: param.type, code: picked.code, label: picked.label)),
    );
  }

  Future<void> _addParam() async {
    final missing = _intent.missingTypes;
    if (missing.isEmpty) {
      await AppNavigator.openSearch(context, query: _intent.query);
      return;
    }
    final type = await showAppSheet<ParamType>(
      context,
      title: 'Что уточнить?',
      builder: (sheetContext) => Column(
        children: [
          for (final t in missing)
            SheetOption(
              label: t.label,
              selected: false,
              onTap: () => Navigator.of(sheetContext).pop(t),
            ),
          SheetOption(
            label: 'Переписать запрос',
            icon: Icons.edit_outlined,
            selected: false,
            onTap: () {
              Navigator.of(sheetContext).pop();
              AppNavigator.openSearch(context, query: _intent.query);
            },
          ),
        ],
      ),
    );
    if (!mounted) {
      return;
    }
    if (type == null) {
      return;
    }
    final options = IntentParam.options[type] ?? const <ParamOption>[];
    if (options.isEmpty) {
      return;
    }
    await _editParam(IntentParam(type: type, code: '', label: type.label));
  }

  Future<void> _pickSort() async {
    final picked = await showAppSheet<_Sort>(
      context,
      title: 'Сортировка',
      builder: (sheetContext) => Column(
        children: [
          for (final sort in _Sort.values)
            SheetOption(
              label: sort.label,
              selected: sort == _sort,
              onTap: () => Navigator.of(sheetContext).pop(sort),
            ),
        ],
      ),
    );
    if (picked != null && mounted) {
      setState(() => _sort = picked);
    }
  }

  Future<void> _surprise() async {
    final search = AppScope.of(context).search;
    HapticFeedback.mediumImpact();
    final pick = await search.surprise();
    if (!mounted) {
      return;
    }
    await AppNavigator.openRecommendation(context, pick);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return AnnotatedRegion(
      value: AppTheme.overlayOnLight,
      child: Scaffold(
        bottomNavigationBar: BuginBottomNav(
          current: AppScope.of(context).state.tab.value,
          onSelect: (tab) => AppNavigator.goToTab(context, tab),
        ),
        body: SafeArea(
          bottom: false,
          child: ContentWidth(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 16, 0),
                    child: Row(
                      children: [
                        const AppBackButton(),
                        const SizedBox(width: 8),
                        Expanded(
                          child: QueryPill(
                            query: _intent.query,
                            onTap: () =>
                                AppNavigator.openSearch(context, query: _intent.query),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _UnderstoodPanel(
                    intent: _intent,
                    onEdit: _editParam,
                    onRemove: (param) => _applyIntent(_intent.without(param.type)),
                    onAdd: _addParam,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 12, 8),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text('Вот что нашёл для тебя', style: AppText.h2),
                        ),
                        Pressable(
                          onTap: _pickSort,
                          semanticLabel: 'Сортировка: ${_sort.label}',
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 44),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.swap_vert_rounded,
                                  size: 18,
                                  color: AppColors.inkSecondary,
                                ),
                                const SizedBox(width: 4),
                                ExcludeSemantics(
                                  child: Text(
                                    _sort == _Sort.best ? 'Лучшее' : _sort.label,
                                    style: AppText.caption.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ChipRow(
                    children: [
                      for (final filter in _KindFilter.values)
                        SelectChip(
                          label: filter == _KindFilter.all
                              ? '${filter.label} · ${_items.length}'
                              : filter.label,
                          selected: filter == _filter,
                          onTap: () => setState(() => _filter = filter),
                        ),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 14)),
                if (_loading)
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(child: SkeletonList(count: 3, imageSize: 96)),
                  )
                else if (visible.isEmpty)
                  SliverToBoxAdapter(
                    child: EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Ничего не нашлось',
                      message: _filter == _KindFilter.all
                          ? 'Попробуй убрать один из параметров или увеличить бюджет'
                          : 'В этой категории пусто — посмотри все варианты',
                      actionLabel: _filter == _KindFilter.all ? 'Изменить запрос' : 'Показать все',
                      onAction: _filter == _KindFilter.all
                          ? () => AppNavigator.openSearch(context, query: _intent.query)
                          : () => setState(() => _filter = _KindFilter.all),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = visible[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: RecommendationCard(
                              item: item,
                              onTap: () => AppNavigator.openRecommendation(context, item),
                            ),
                          );
                        },
                        childCount: visible.length,
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    child: _SurpriseCard(onTap: _surprise),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UnderstoodPanel extends StatelessWidget {
  const _UnderstoodPanel({
    required this.intent,
    required this.onEdit,
    required this.onRemove,
    required this.onAdd,
  });

  final SearchIntent intent;
  final ValueChanged<IntentParam> onEdit;
  final ValueChanged<IntentParam> onRemove;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 18, color: AppColors.primaryInk),
              const SizedBox(width: 8),
              Text(
                'Я понял тебя',
                style: AppText.bodyStrong.copyWith(color: AppColors.primaryInk),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final param in intent.params)
                ParamChip(
                  key: ValueKey(param.type),
                  param: param,
                  onEdit: () => onEdit(param),
                  onRemove: () => onRemove(param),
                ),
              AddParamChip(onTap: onAdd),
            ],
          ),
          if (intent.hasInferred) ...[
            const SizedBox(height: 10),
            Text(
              'Пунктир — это я додумал сам. Нажми на параметр, чтобы изменить.',
              style: AppText.micro.copyWith(color: AppColors.inkBody, fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }
}

class _SurpriseCard extends StatelessWidget {
  const _SurpriseCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Не то, что искал?', style: AppText.bodyStrong),
                SizedBox(height: 2),
                Text('Уточни запрос или доверься случаю', style: AppText.caption),
              ],
            ),
          ),
          const SizedBox(width: 12),
          PrimaryButton(
            label: 'Удиви меня',
            icon: Icons.casino_outlined,
            variant: ButtonVariant.outline,
            height: 44,
            expand: false,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
