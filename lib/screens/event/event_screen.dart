import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bugin/core/formatters.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/navigation/app_navigator.dart';
import 'package:bugin/navigation/app_tab.dart';
import 'package:bugin/services/app_services.dart';
import 'package:bugin/services/favorites_store.dart';
import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_text.dart';
import 'package:bugin/theme/visuals.dart';
import 'package:bugin/widgets/app_sheet.dart';
import 'package:bugin/widgets/buttons.dart';
import 'package:bugin/widgets/chips.dart';
import 'package:bugin/widgets/detail_scaffold.dart';
import 'package:bugin/widgets/event_card.dart';
import 'package:bugin/widgets/expandable_text.dart';
import 'package:bugin/widgets/favorite_button.dart';
import 'package:bugin/widgets/info_card.dart';
import 'package:bugin/widgets/layout.dart';
import 'package:bugin/widgets/mini_map.dart';
import 'package:bugin/widgets/recommendation_reason.dart';
import 'package:bugin/widgets/section_header.dart';
import 'package:bugin/widgets/skeleton.dart';
import 'package:bugin/widgets/snack.dart';
import 'package:bugin/widgets/sticky_action_bar.dart';

/// Карточка события: дата и место без дублей, причины, похожие события.
class EventScreen extends StatefulWidget {
  const EventScreen({super.key, required this.eventId});

  final String eventId;

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  late Future<Event> _future;
  late Future<List<Event>> _similar;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final events = AppScope.of(context).events;
    _future = events.byId(widget.eventId);
    _similar = events.similar(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Event>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return DetailError(onRetry: () => setState(_load));
        }
        final event = snapshot.data;
        if (event == null) {
          return const DetailLoading();
        }
        return _buildEvent(event);
      },
    );
  }

  String _dateTitle(Event event) {
    if (event.isLongRunning) {
      return '${Fmt.relativeDay(event.startsAt)}, '
          '${Fmt.time(event.startsAt)}–${Fmt.time(event.endsAt)}';
    }
    return '${Fmt.longDate(event.startsAt)} · ${Fmt.time(event.startsAt)}';
  }

  String _dateSubtitle(Event event) {
    if (event.isLongRunning) {
      return 'Можно прийти в любое время';
    }
    return '${Fmt.inDays(event.startsAt)} · около ${Fmt.duration(event.durationMinutes)}';
  }

  Future<void> _openTickets(Event event) async {
    final selected = await showAppSheet<TicketCategory>(
      context,
      title: 'Билеты',
      subtitle: '${event.title} · ${Fmt.eventWhen(event.startsAt)}',
      builder: (sheetContext) => _TicketSheet(
        tickets: event.tickets,
        onBuy: (ticket) => Navigator.of(sheetContext).pop(ticket),
      ),
    );
    if (selected != null && mounted) {
      HapticFeedback.mediumImpact();
      showAppSnack(
        context,
        '${selected.name} — оплата подключится вместе с backend. Это демо',
      );
    }
  }

  void _share(Event event) {
    Clipboard.setData(
      ClipboardData(
        text: '${event.title}, ${Fmt.eventWhen(event.startsAt)}, ${event.venueName} — нашёл в Bugin',
      ),
    );
    showAppSnack(context, 'Скопировано — можно отправить друзьям');
  }

  Widget _buildEvent(Event event) {
    return DetailScaffold(
      image: event.image,
      badge: event.category.label,
      title: event.title,
      subtitle: event.subtitle,
      heroHeight: 340,
      placeholderIcon: Visuals.eventIcon(event.category),
      placeholderTone: Visuals.eventTone(event.category),
      actionsBuilder: (onImage) => [
        CircleIconButton(
          icon: Icons.ios_share_rounded,
          style: onImage ? CircleButtonStyle.overlay : CircleButtonStyle.surface,
          semanticLabel: 'Поделиться',
          onPressed: () => _share(event),
        ),
        FavoriteButton(
          kind: FavoriteKind.event,
          id: event.id,
          size: 44,
          style: onImage ? FavoriteButtonStyle.overlay : FavoriteButtonStyle.surface,
        ),
      ],
      bottomBar: StickyActionBar(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Fmt.fromTenge(event.priceFrom),
                  style: AppText.h2.copyWith(letterSpacing: 0),
                ),
                const Text('за билет', style: AppText.micro),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PrimaryButton(
                label: 'Купить билет',
                icon: Icons.confirmation_number_outlined,
                onPressed: () => _openTickets(event),
              ),
            ),
          ],
        ),
      ),
      body: [
        InfoCard(
          children: [
            InfoRow.text(
              icon: Icons.calendar_today_outlined,
              title: _dateTitle(event),
              subtitle: _dateSubtitle(event),
              trailing: CircleIconButton(
                icon: Icons.event_available_outlined,
                style: CircleButtonStyle.soft,
                size: 40,
                iconSize: 18,
                semanticLabel: 'Добавить в календарь',
                onPressed: () =>
                    showDemoSnack(context, 'событие добавится в календарь телефона'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const IconWell(Icons.place_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.venueName, style: AppText.bodyStrong),
                            const SizedBox(height: 2),
                            Text(
                              '${event.address} · ${Fmt.distance(event.distanceKm)}',
                              style: AppText.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  MiniMap(
                    variant: event.id.length + 1,
                    onRoute: () => showDemoSnack(
                      context,
                      'маршрут до «${event.venueName}» откроется в картах',
                    ),
                  ),
                ],
              ),
            ),
            InfoRow.text(
              icon: Icons.confirmation_number_outlined,
              title: event.tickets.length == 1
                  ? event.tickets.first.name
                  : '${event.tickets.length} '
                      '${Fmt.plural(event.tickets.length, 'категория', 'категории', 'категорий')} билетов',
              subtitle: [
                if (event.tickets.length > 1) event.tickets.map((t) => t.name).join(', '),
                event.ageLimit > 0 ? '${event.ageLimit}+' : 'Без ограничений по возрасту',
              ].join(' · '),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.inkSecondary,
              ),
              onTap: () => _openTickets(event),
            ),
          ],
        ),
        if (event.tags.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final tag in event.tags) TagChip(tag)],
          ),
        ],
        if (event.reasons.isNotEmpty) ...[
          const SizedBox(height: 16),
          ReasonsCard(title: 'Почему тебе понравится', reasons: event.reasons),
        ],
        const SectionHeader.inset(title: 'О событии'),
        ExpandableText(event.description),
        FutureBuilder<List<Event>>(
          future: _similar,
          builder: (context, snapshot) {
            final similar = snapshot.data;
            if (snapshot.hasError || (similar != null && similar.isEmpty)) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader.inset(
                  title: 'Похожие события',
                  onAction: () => AppNavigator.goToTab(context, AppTab.afisha),
                ),
                if (similar == null)
                  const SkeletonPulse(child: SkeletonBox(height: 190, radius: 18))
                else
                  HorizontalCarousel(
                    padding: EdgeInsets.zero,
                    children: [
                      for (final item in similar)
                        EventCard.compact(
                          event: item,
                          onTap: () => AppNavigator.openEvent(context, item.id),
                        ),
                    ],
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TicketSheet extends StatefulWidget {
  const _TicketSheet({required this.tickets, required this.onBuy});

  final List<TicketCategory> tickets;
  final ValueChanged<TicketCategory> onBuy;

  @override
  State<_TicketSheet> createState() => _TicketSheetState();
}

class _TicketSheetState extends State<_TicketSheet> {
  int _selected = 0;
  int _count = 1;

  @override
  Widget build(BuildContext context) {
    if (widget.tickets.isEmpty) {
      return const Text('Билеты скоро появятся', style: AppText.caption);
    }
    final ticket = widget.tickets[_selected];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < widget.tickets.length; i++)
          SheetOption(
            label: widget.tickets[i].name,
            trailingText: Fmt.tenge(widget.tickets[i].price),
            selected: i == _selected,
            onTap: () => setState(() => _selected = i),
          ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                '$_count ${Fmt.plural(_count, 'билет', 'билета', 'билетов')}',
                style: AppText.bodyStrong,
              ),
            ),
            CircleIconButton(
              icon: Icons.remove_rounded,
              style: CircleButtonStyle.soft,
              size: 36,
              semanticLabel: 'Меньше',
              onPressed: _count > 1 ? () => setState(() => _count--) : null,
            ),
            CircleIconButton(
              icon: Icons.add_rounded,
              style: CircleButtonStyle.soft,
              size: 36,
              semanticLabel: 'Больше',
              onPressed: _count < 6 ? () => setState(() => _count++) : null,
            ),
          ],
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Оплатить ${Fmt.tenge(ticket.price * _count)}',
          onPressed: () => widget.onBuy(ticket),
        ),
        const SizedBox(height: 8),
        const Text(
          'Это прототип: оплата не проводится.',
          textAlign: TextAlign.center,
          style: AppText.caption,
        ),
      ],
    );
  }
}
