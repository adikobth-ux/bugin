import 'package:flutter/material.dart';

import 'package:bugin/core/formatters.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/navigation/app_navigator.dart';
import 'package:bugin/services/app_services.dart';
import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_text.dart';
import 'package:bugin/theme/visuals.dart';
import 'package:bugin/widgets/chips.dart';
import 'package:bugin/widgets/city_button.dart';
import 'package:bugin/widgets/event_card.dart';
import 'package:bugin/widgets/layout.dart';
import 'package:bugin/widgets/section_header.dart';
import 'package:bugin/widgets/skeleton.dart';
import 'package:bugin/widgets/state_views.dart';

/// Афиша: фильтр по дням и категориям, «Главное на неделе», список событий.
class AfishaScreen extends StatefulWidget {
  const AfishaScreen({super.key});

  @override
  State<AfishaScreen> createState() => _AfishaScreenState();
}

class _AfishaScreenState extends State<AfishaScreen> {
  EventDayFilter _day = EventDayFilter.today;
  DateTime? _date;
  EventCategory? _category;

  late Future<List<Event>> _list;
  late Future<List<Event>> _featured;

  @override
  void initState() {
    super.initState();
    final events = AppScope.of(context).events;
    _featured = events.featured();
    _list = _query();
  }

  Future<List<Event>> _query() => AppScope.of(context).events.list(
        day: _day,
        date: _date,
        category: _category,
      );

  void _setDay(EventDayFilter day) {
    if (day == EventDayFilter.date) {
      _pickDate();
      return;
    }
    setState(() {
      _day = day;
      _date = null;
      _list = _query();
    });
  }

  void _setCategory(EventCategory? category) {
    setState(() {
      _category = category;
      _list = _query();
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 60)),
      helpText: 'Выбери дату',
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _day = EventDayFilter.date;
      _date = picked;
      _list = _query();
    });
  }

  Future<void> _refresh() async {
    final events = AppScope.of(context).events;
    final list = _query();
    setState(() {
      _featured = events.featured();
      _list = list;
    });
    try {
      await list;
    } catch (_) {
      // Ошибку покажет FutureBuilder.
    }
  }

  String get _dayTitle {
    final date = _date;
    if (_day == EventDayFilter.date && date != null) {
      return Fmt.relativeDay(date);
    }
    return _day.label;
  }

  @override
  Widget build(BuildContext context) {
    final date = _date;
    final showFeatured = _category == null && _day != EventDayFilter.date;

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
                      child: Semantics(
                        header: true,
                        child: const Text('Афиша', style: AppText.display),
                      ),
                    ),
                    const CityButton(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ChipRow(
                  children: [
                    for (final day in EventDayFilter.values)
                      SelectChip(
                        label: day == EventDayFilter.date && date != null
                            ? Fmt.relativeDay(date)
                            : day.label,
                        icon: day == EventDayFilter.date
                            ? Icons.calendar_month_outlined
                            : null,
                        selected: day == _day,
                        onTap: () => _setDay(day),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ChipRow(
                  spacing: 6,
                  children: [
                    SelectChip(
                      label: 'Все',
                      style: SelectChipStyle.soft,
                      selected: _category == null,
                      onTap: () => _setCategory(null),
                    ),
                    for (final category in EventCategory.values)
                      SelectChip(
                        label: category.pluralLabel,
                        icon: Visuals.eventIcon(category),
                        style: SelectChipStyle.soft,
                        selected: _category == category,
                        onTap: () => _setCategory(category),
                      ),
                  ],
                ),
              ),
            ),
            if (showFeatured)
              SliverToBoxAdapter(
                child: FutureBuilder<List<Event>>(
                  future: _featured,
                  builder: (context, snapshot) {
                    final items = snapshot.data;
                    if (snapshot.hasError || (items != null && items.isEmpty)) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SectionHeader(title: 'Главное на неделе'),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: items == null
                              ? const SkeletonPulse(
                                  child: SkeletonBox(height: 210, radius: 22),
                                )
                              : EventCard.featured(
                                  event: items.first,
                                  onTap: () =>
                                      AppNavigator.openEvent(context, items.first.id),
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            SliverToBoxAdapter(
              child: FutureBuilder<List<Event>>(
                future: _list,
                builder: (context, snapshot) {
                  final done = snapshot.connectionState == ConnectionState.done;
                  final items = done ? snapshot.data : null;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionHeader(
                        title: _dayTitle,
                        trailing: items == null || items.isEmpty
                            ? null
                            : Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Text(
                                  '${items.length} '
                                  '${Fmt.plural(items.length, 'событие', 'события', 'событий')}',
                                  style: AppText.caption.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _EventList(
                          snapshot: snapshot,
                          showDay: _day == EventDayFilter.weekend,
                          onRetry: _refresh,
                          onShowWeekend: () => _setDay(EventDayFilter.weekend),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  const _EventList({
    required this.snapshot,
    required this.showDay,
    required this.onRetry,
    required this.onShowWeekend,
  });

  final AsyncSnapshot<List<Event>> snapshot;
  final bool showDay;
  final VoidCallback onRetry;
  final VoidCallback onShowWeekend;

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasError) {
      return ErrorState(onRetry: onRetry);
    }
    final items = snapshot.data;
    if (items == null || snapshot.connectionState != ConnectionState.done) {
      return const SkeletonList(count: 3, imageSize: 76);
    }
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.event_busy_outlined,
        title: 'Здесь пока пусто',
        message: 'На этот день ничего не нашлось — загляни на выходные',
        actionLabel: showDay ? null : 'Показать выходные',
        onAction: showDay ? null : onShowWeekend,
      );
    }
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          EventCard.row(
            event: items[i],
            showDay: showDay,
            onTap: () => AppNavigator.openEvent(context, items[i].id),
          ),
        ],
      ],
    );
  }
}
