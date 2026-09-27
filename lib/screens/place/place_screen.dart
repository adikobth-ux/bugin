import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bugin/core/formatters.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/services/app_services.dart';
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
    setState(() => _future = AppScope.of(context).places.byId(widget.placeId));
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
    final slot = _currentSlot(place);
    if (slot == null) {
      return 'Завтра, ${Fmt.hm(place.openingHours.opensAt + 60)}';
    }
    return 'Сегодня, ${Fmt.hm(slot)}';
  }

  Future<void> _pickSlot(Place place) async {
    final slots = _slots(place);
    if (slots.isEmpty) {
      showAppSnack(context, 'На сегодня свободного времени нет — попробуй завтра');
      return;
    }
    final current = _currentSlot(place);
    final picked = await showAppSheet<int>(
      context,
      title: place.bookingType == BookingType.ticket ? 'Выбери сеанс' : 'Выбери время',
      subtitle: 'Сегодня',
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
    final slotText = _slotText(place);
    final isTicket = place.bookingType == BookingType.ticket;
    final confirmed = await showAppSheet<bool>(
      context,
      title: isTicket ? 'Билеты · ${place.name}' : 'Бронь · ${place.name}',
      builder: (sheetContext) => _BookingSheet(
        slotText: slotText,
        isTicket: isTicket,
        pricePerPerson: place.averageCheck,
        onConfirm: () => Navigator.of(sheetContext).pop(true),
      ),
    );
    if (confirmed == true && mounted) {
      HapticFeedback.mediumImpact();
      showAppSnack(
        context,
        isTicket
            ? 'Готово! $slotText — это демо, реальной оплаты нет'
            : 'Готово! $slotText — это демо, реальной брони нет',
      );
    }
  }

  void _share(Place place) {
    Clipboard.setData(
      ClipboardData(text: '${place.name}, ${place.address} — нашёл в Bugin'),
    );
    showAppSnack(context, 'Скопировано — можно отправить другу');
  }

  void _call(Place place) =>
      showDemoSnack(context, 'звонок на ${place.phone} подключим вместе с телефонией');

  void _route(Place place) =>
      showDemoSnack(context, 'маршрут до «${place.name}» откроется в картах');

  void _openReviews(Place place) {
    showAppSheet<void>(
      context,
      title: 'Отзывы',
      subtitle:
          '${Fmt.rating(place.rating)} из 5 · ${Fmt.thousands(place.reviewsCount)} оценок',
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
    final photos = place.photos;
    final priceText = place.isFree
        ? 'бесплатно'
        : '${Fmt.approxTenge(place.averageCheck)} / чел.';

    return DetailScaffold(
      image: place.cover,
      badge: place.category.label,
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
          semanticLabel: 'Поделиться',
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
          ReasonsCard(title: 'Почему тебе подойдёт', reasons: widget.reasons),
          const SizedBox(height: 12),
        ],
        InfoCard(
          children: [
            InfoRow(
              icon: Icons.schedule_rounded,
              title: _OpenStatus(hours: place.openingHours),
              subtitle: place.openingHours.isAlwaysOpen
                  ? 'Без выходных'
                  : 'Ежедневно ${place.openingHours.range}',
            ),
            _AddressBlock(place: place, onRoute: () => _route(place)),
            if (place.phone.isNotEmpty)
              InfoRow.text(
                icon: Icons.phone_outlined,
                title: place.phone,
                subtitle: 'Позвонить',
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
          const SectionHeader.inset(title: 'Удобства'),
          _AmenityGrid(amenities: place.amenities),
        ],
        const SectionHeader.inset(title: 'О месте'),
        ExpandableText(place.description),
        if (place.reviews.isNotEmpty) ...[
          SectionHeader.inset(
            title: 'Отзывы',
            actionLabel: 'Все ${Fmt.thousands(place.reviewsCount)}',
            onAction: () => _openReviews(place),
          ),
          ReviewCard(review: place.reviews.first),
        ],
        if (photos.length > 1) ...[
          SectionHeader.inset(
            title: 'Галерея',
            actionLabel: 'Все ${photos.length}',
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
                semanticLabel: 'Фото ${i + 2} из ${photos.length}',
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
    if (place.bookingType == BookingType.none) {
      return StickyActionBar(
        child: Row(
          children: [
            if (place.phone.isNotEmpty) ...[
              Expanded(
                child: PrimaryButton(
                  label: 'Позвонить',
                  icon: Icons.phone_outlined,
                  variant: ButtonVariant.outline,
                  onPressed: () => _call(place),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: PrimaryButton(
                label: 'Маршрут',
                icon: Icons.near_me_outlined,
                onPressed: () => _route(place),
              ),
            ),
          ],
        ),
      );
    }

    final isTicket = place.bookingType == BookingType.ticket;
    final slot = _currentSlot(place);
    return StickyActionBar(
      child: Row(
        children: [
          _SlotButton(
            title: slot == null ? 'Завтра' : (isTicket ? 'Сеанс сегодня' : 'Сегодня'),
            value: Fmt.hm(slot ?? place.openingHours.opensAt + 60),
            onTap: () => _pickSlot(place),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              label: isTicket ? 'Купить билет' : 'Забронировать',
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
    if (hours.isAlwaysOpen) {
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Открыто',
              style: AppText.bodyStrong.copyWith(color: AppColors.success),
            ),
            const TextSpan(text: ' · круглосуточно'),
          ],
        ),
      );
    }
    final open = hours.isOpenAt(DateTime.now());
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: open ? 'Открыто' : 'Закрыто',
            style: AppText.bodyStrong.copyWith(
              color: open ? AppColors.success : AppColors.danger,
            ),
          ),
          TextSpan(
            text: open
                ? ' · до ${Fmt.hm(hours.closesAt)}'
                : ' · откроется в ${Fmt.hm(hours.opensAt)}',
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
                      '${Fmt.distance(place.distanceKm)} · ${place.taxiMinutes} мин на такси',
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
                              amenity.type.label,
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
      semanticLabel: '$title: $value. Изменить',
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

/// Подтверждение брони/покупки (демо): время, гости, итог.
class _BookingSheet extends StatefulWidget {
  const _BookingSheet({
    required this.slotText,
    required this.isTicket,
    required this.pricePerPerson,
    required this.onConfirm,
  });

  final String slotText;
  final bool isTicket;
  final int pricePerPerson;
  final VoidCallback onConfirm;

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  int _guests = 2;

  @override
  Widget build(BuildContext context) {
    final total = widget.pricePerPerson * _guests;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InfoCard(
          children: [
            InfoRow.text(
              icon: Icons.schedule_rounded,
              title: widget.slotText,
              subtitle: widget.isTicket ? 'Сеанс' : 'Время',
            ),
            InfoRow.text(
              icon: Icons.people_outline_rounded,
              title: '$_guests ${Fmt.plural(_guests, 'гость', 'гостя', 'гостей')}',
              subtitle: widget.isTicket ? 'Количество билетов' : 'Сколько вас будет',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleIconButton(
                    icon: Icons.remove_rounded,
                    style: CircleButtonStyle.soft,
                    size: 36,
                    semanticLabel: 'Меньше',
                    onPressed: _guests > 1 ? () => setState(() => _guests--) : null,
                  ),
                  CircleIconButton(
                    icon: Icons.add_rounded,
                    style: CircleButtonStyle.soft,
                    size: 36,
                    semanticLabel: 'Больше',
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
            widget.isTicket
                ? 'Итого: ${Fmt.tenge(total)}'
                : 'Средний счёт на всех: ${Fmt.approxTenge(total)}',
            style: AppText.bodyStrong,
          ),
        const SizedBox(height: 4),
        const Text(
          'Это прототип: подтверждение ничего не бронирует и не списывает.',
          style: AppText.caption,
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: widget.isTicket ? 'Перейти к оплате' : 'Подтвердить бронь',
          onPressed: widget.onConfirm,
        ),
      ],
    );
  }
}
