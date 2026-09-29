import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bugin/core/formatters.dart';
import 'package:bugin/l10n/app_strings.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/services/app_services.dart';
import 'package:bugin/services/external_links.dart';
import 'package:bugin/services/favorites_store.dart';
import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_text.dart';
import 'package:bugin/theme/visuals.dart';
import 'package:bugin/widgets/app_image.dart';
import 'package:bugin/widgets/app_sheet.dart';
import 'package:bugin/widgets/buttons.dart';
import 'package:bugin/widgets/chips.dart';
import 'package:bugin/widgets/detail_scaffold.dart';
import 'package:bugin/widgets/expandable_text.dart';
import 'package:bugin/widgets/favorite_button.dart';
import 'package:bugin/widgets/gallery_viewer.dart';
import 'package:bugin/widgets/info_card.dart';
import 'package:bugin/widgets/meta_line.dart';
import 'package:bugin/widgets/mini_map.dart';
import 'package:bugin/widgets/pressable.dart';
import 'package:bugin/widgets/recommendation_reason.dart';
import 'package:bugin/widgets/review_card.dart';
import 'package:bugin/widgets/section_header.dart';
import 'package:bugin/widgets/snack.dart';
import 'package:bugin/widgets/sticky_action_bar.dart';

/// Карточка места: одна прокрутка, без вкладок и повторов.
class PlaceScreen extends StatefulWidget {
  const PlaceScreen({super.key, required this.placeId, this.reasons = const []});

  final String placeId;

  /// Причины из выдачи. Если пусто — блок «Почему тебе подойдёт» не показывается.
  final List<String> reasons;

  @override
  State<PlaceScreen> createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen> {
  late Future<Place> _future;
  int? _slot;

  @override
  void initState() {
    super.initState();
    _future = AppScope.of(context).places.byId(widget.placeId);
  }

  void _retry() {
    setState(() {
      _future = AppScope.of(context).places.byId(widget.placeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Place>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return DetailError(onRetry: _retry);
        }
        final place = snapshot.data;
        if (place == null) {
          return const DetailLoading();
        }
        return _buildPlace(place);
      },
    );
  }

  // ---------- Слоты и бронь ----------

  List<int> _slots(Place place) {
    final now = DateTime.now();
    final start = ((now.hour * 60 + now.minute + 30) ~/ 30) * 30;
    final result = <int>[];
    for (var m = start; m < 24 * 60 && result.length < 8; m += 30) {
      if (place.openingHours.isOpenAtMinute(m) &&
          place.openingHours.isOpenAtMinute(m + 60)) {
        result.add(m);
      }
    }
    return result;
  }

  int? _currentSlot(Place place) {
    final slots = _slots(place);
    if (slots.isEmpty) {
      return null;
    }
    final chosen = _slot;
    if (chosen != null && slots.contains(chosen)) {
      return chosen;
    }
    return slots.contains(19 * 60) ? 19 * 60 : slots.first;
  }

  String _slotText(Place place) {
    final strings = context.l10n.place;
    final slot = _currentSlot(place);
    if (slot == null) {
      return strings.tomorrowAt(Fmt.hm(place.openingHours.opensAt + 60));
    }
    return strings.todayAt(Fmt.hm(slot));
  }

  Future<void> _pickSlot(Place place) async {
    final l10n = context.l10n;
    final slots = _slots(place);
    if (slots.isEmpty) {
      showAppSnack(context, l10n.place.noSlotsToday);
      return;
    }
    final current = _currentSlot(place);
    final picked = await showAppSheet<int>(
      context,
      title: l10n.place.pickTime,
      subtitle: l10n.today,
      builder: (sheetContext) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final slot in slots)
            SelectChip(
              label: Fmt.hm(slot),
              selected: slot == current,
              onTap: () => Navigator.of(sheetContext).pop(slot),
            ),
        ],
      ),
    );
    if (picked != null && mounted) {
      HapticFeedback.selectionClick();
      setState(() => _slot = picked);
    }
  }

  Future<void> _book(Place place) async {
    final strings = context.l10n.place;
    final slotText = _slotText(place);
    final confirmed = await showAppSheet<bool>(
      context,
      title: strings.bookingTitle(place.name),
      builder: (sheetContext) => _BookingSheet(
        slotText: slotText,
        pricePerPerson: place.averageCheck,
        onConfirm: () => Navigator.of(sheetContext).pop(true),
      ),
    );
    if (confirmed == true && mounted) {
      HapticFeedback.mediumImpact();
      showAppSnack(context, strings.bookedDemo(slotText));
    }
  }

  /// Билеты продаёт оператор (Kino.kz, Ticketon): открываем его страницу.
  Future<void> _openTickets(String url) async {
    final opened = await AppScope.of(context).links.open(Uri.parse(url));
    if (!opened && mounted) {
      showAppSnack(context, context.l10n.linkOpenFailed);
    }
  }

  void _share(Place place) {
    final strings = context.l10n.place;
    Clipboard.setData(
      ClipboardData(text: strings.shareText(place.name, place.address)),
    );
    showAppSnack(context, strings.copied);
  }

  void _call(Place place) =>
      showDemoSnack(context, context.l10n.place.callDemo(place.phone));

  void _route(Place place) =>
      showDemoSnack(context, context.l10n.place.routeDemo(place.name));

  void _openReviews(Place place) {
    final strings = context.l10n.place;
    showAppSheet<void>(
      context,
      title: strings.reviews,
      subtitle: strings.reviewsSummary(place.rating, place.reviewsCount),
      builder: (sheetContext) => Column(
        children: [
          for (final review in place.reviews)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ReviewCard(review: review),
            ),
        ],
      ),
    );
  }

  // ---------- Вёрстка ----------

  Widget _buildPlace(Place place) {
    final l10n = context.l10n;
    final strings = l10n.place;
    final photos = place.photos;
    final priceText =
        place.isFree ? strings.free : strings.perPerson(place.averageCheck);

    return DetailScaffold(
      image: place.cover,
      badge: l10n.label(place.category),
      title: place.name,
      subtitle: place.subtitle,
      placeholderIcon: Visuals.placeIcon(place.category),
      placeholderTone: Visuals.placeTone(place.category),
      onImageTap: photos.isEmpty ? null : () => GalleryViewer.open(context, photos),
      meta: MetaLine(
        rating: place.rating,
        reviewsCount: place.reviewsCount,
        parts: [priceText, Fmt.distance(place.distanceKm)],
        onImage: true,
        maxLines: 2,
        style: AppText.label.copyWith(color: AppColors.onImageText),
      ),
      actionsBuilder: (onImage) => [
        CircleIconButton(
          icon: Icons.ios_share_rounded,
          style: onImage ? CircleButtonStyle.overlay : CircleButtonStyle.surface,
          semanticLabel: strings.share,
          onPressed: () => _share(place),
        ),
        FavoriteButton(
          kind: FavoriteKind.place,
          id: place.id,
          size: 44,
          style: onImage ? FavoriteButtonStyle.overlay : FavoriteButtonStyle.surface,
        ),
      ],
      bottomBar: _actionBar(place),
      body: [
        if (widget.reasons.isNotEmpty) ...[
          ReasonsCard(title: strings.reasonsTitle, reasons: widget.reasons),
          const SizedBox(height: 12),
        ],
        InfoCard(
          children: [
            InfoRow(
              icon: Icons.schedule_rounded,
              title: _OpenStatus(hours: place.openingHours),
              subtitle: place.openingHours.isAlwaysOpen
                  ? strings.noDaysOff
                  : strings.daily(l10n.hoursRange(place.openingHours)),
            ),
            _AddressBlock(place: place, onRoute: () => _route(place)),
            if (place.phone.isNotEmpty)
              InfoRow.text(
                icon: Icons.phone_outlined,
                title: place.phone,
                subtitle: strings.call,
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.inkSecondary,
                ),
                onTap: () => _call(place),
              ),
          ],
        ),
        if (place.tags.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final tag in place.tags.take(4)) TagChip(tag)],
          ),
        ],
        if (place.amenities.isNotEmpty) ...[
          SectionHeader.inset(title: strings.amenities),
          _AmenityGrid(amenities: place.amenities),
        ],
        SectionHeader.inset(title: strings.about),
        ExpandableText(place.description),
        if (place.reviews.isNotEmpty) ...[
          SectionHeader.inset(
            title: strings.reviews,
            actionLabel: strings.allCount(Fmt.thousands(place.reviewsCount)),
            onAction: () => _openReviews(place),
          ),
          ReviewCard(review: place.reviews.first),
        ],
        if (photos.length > 1) ...[
          SectionHeader.inset(
            title: strings.gallery,
            actionLabel: strings.allCount('${photos.length}'),
            onAction: () => GalleryViewer.open(context, photos),
          ),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: photos.length - 1,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) => Pressable(
                onTap: () => GalleryViewer.open(context, photos, initialIndex: i + 1),
                semanticLabel: strings.photoLabel(i + 2, photos.length),
                child: AppImage(
                  photos[i + 1],
                  width: 124,
                  height: 100,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _actionBar(Place place) {
    final l10n = context.l10n;
    if (place.bookingType == BookingType.none) {
      return StickyActionBar(
        child: Row(
          children: [
            if (place.phone.isNotEmpty) ...[
              Expanded(
                child: PrimaryButton(
                  label: l10n.place.call,
                  icon: Icons.phone_outlined,
                  variant: ButtonVariant.outline,
                  onPressed: () => _call(place),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: PrimaryButton(
                label: l10n.route,
                icon: Icons.near_me_outlined,
                onPressed: () => _route(place),
              ),
            ),
          ],
        ),
      );
    }

    if (place.bookingType == BookingType.ticket) {
      final url = place.bookingUrl;
      return StickyActionBar(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.averageCheck(place.averageCheck),
                  style: AppText.h2.copyWith(letterSpacing: 0),
                ),
                Text(
                  url == null
                      ? l10n.event.ticketsSoon
                      : l10n.ticketsOn(linkProviderName(Uri.parse(url))),
                  style: AppText.micro,
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PrimaryButton(
                label: l10n.place.buyTicket,
                icon: Icons.open_in_new_rounded,
                onPressed: url == null ? null : () => _openTickets(url),
              ),
            ),
          ],
        ),
      );
    }

    final slot = _currentSlot(place);
    return StickyActionBar(
      child: Row(
        children: [
          _SlotButton(
            title: slot == null ? l10n.tomorrow : l10n.today,
            value: Fmt.hm(slot ?? place.openingHours.opensAt + 60),
            onTap: () => _pickSlot(place),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              label: l10n.place.book,
              onPressed: () => _book(place),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenStatus extends StatelessWidget {
  const _OpenStatus({required this.hours});

  final OpeningHours hours;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final strings = l10n.place;
    if (hours.isAlwaysOpen) {
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: strings.open,
              style: AppText.bodyStrong.copyWith(color: AppColors.success),
            ),
            TextSpan(text: ' · ${strings.aroundTheClock}'),
          ],
        ),
      );
    }
    final open = hours.isOpenAt(DateTime.now());
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: open ? strings.open : strings.closed,
            style: AppText.bodyStrong.copyWith(
              color: open ? AppColors.success : AppColors.danger,
            ),
          ),
          TextSpan(
            text: open
                ? ' · ${l10n.untilTime(hours.closesAt)}'
                : ' · ${strings.opensAt(hours.opensAt)}',
          ),
        ],
      ),
    );
  }
}

class _AddressBlock extends StatelessWidget {
  const _AddressBlock({required this.place, required this.onRoute});

  final Place place;
  final VoidCallback onRoute;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                    Text(place.address, style: AppText.bodyStrong),
                    const SizedBox(height: 2),
                    Text(
                      '${Fmt.distance(place.distanceKm)} · '
                      '${context.l10n.place.byTaxi(place.taxiMinutes)}',
                      style: AppText.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MiniMap(onRoute: onRoute, variant: place.id.length),
        ],
      ),
    );
  }
}

class _AmenityGrid extends StatelessWidget {
  const _AmenityGrid({required this.amenities});

  final List<PlaceAmenity> amenities;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 300 ? 2 : 1;
        final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final amenity in amenities)
              SizedBox(
                width: width,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Visuals.amenityIcon(amenity.type),
                        size: 22,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.label(amenity.type),
                              style: AppText.label.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(amenity.value, style: AppText.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SlotButton extends StatelessWidget {
  const _SlotButton({required this.title, required this.value, required this.onTap});

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: context.l10n.place.slotSemantics(title, value),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: ExcludeSemantics(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.micro),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(value, style: AppText.bodyStrong),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.inkSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Подтверждение брони столика или дорожки (демо): время, гости, итог.
class _BookingSheet extends StatefulWidget {
  const _BookingSheet({
    required this.slotText,
    required this.pricePerPerson,
    required this.onConfirm,
  });

  final String slotText;
  final int pricePerPerson;
  final VoidCallback onConfirm;

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  int _guests = 2;

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n.place;
    final total = widget.pricePerPerson * _guests;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InfoCard(
          children: [
            InfoRow.text(
              icon: Icons.schedule_rounded,
              title: widget.slotText,
              subtitle: strings.timeLabel,
            ),
            InfoRow.text(
              icon: Icons.people_outline_rounded,
              title: strings.guests(_guests),
              subtitle: strings.partySize,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleIconButton(
                    icon: Icons.remove_rounded,
                    style: CircleButtonStyle.soft,
                    size: 36,
                    semanticLabel: strings.less,
                    onPressed: _guests > 1 ? () => setState(() => _guests--) : null,
                  ),
                  CircleIconButton(
                    icon: Icons.add_rounded,
                    style: CircleButtonStyle.soft,
                    size: 36,
                    semanticLabel: strings.more,
                    onPressed: _guests < 8 ? () => setState(() => _guests++) : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.pricePerPerson > 0)
          Text(
            strings.averageTotal(total),
            style: AppText.bodyStrong,
          ),
        const SizedBox(height: 4),
        Text(strings.prototypeNote, style: AppText.caption),
        const SizedBox(height: 16),
        PrimaryButton(
          label: strings.confirmBooking,
          onPressed: widget.onConfirm,
        ),
      ],
    );
  }
}
