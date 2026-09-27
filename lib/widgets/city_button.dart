import 'package:flutter/material.dart';

import 'package:bugin/core/constants.dart';
import 'package:bugin/l10n/app_strings.dart';
import 'package:bugin/services/app_services.dart';
import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_text.dart';
import 'package:bugin/widgets/app_sheet.dart';
import 'package:bugin/widgets/pressable.dart';

/// Выбор города. Показывается только на главной и в афише.
class CityButton extends StatelessWidget {
  const CityButton({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context).state;
    return ValueListenableBuilder<String>(
      valueListenable: state.city,
      builder: (context, city, _) => Pressable(
        onTap: () => showCityPicker(context),
        semanticLabel: context.l10n.cityButton(city),
        child: Container(
          height: 40,
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.place_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              ExcludeSemantics(child: Text(city, style: AppText.label)),
              const SizedBox(width: 2),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.inkSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showCityPicker(BuildContext context) async {
  final state = AppScope.of(context).state;
  final picked = await showAppSheet<String>(
    context,
    title: context.l10n.city,
    subtitle: context.l10n.cityPickerHint,
    builder: (sheetContext) => Column(
      children: [
        for (final city in kCities)
          SheetOption(
            label: city,
            icon: Icons.location_city_outlined,
            selected: city == state.city.value,
            onTap: () => Navigator.of(sheetContext).pop(city),
          ),
      ],
    ),
  );
  if (picked != null) {
    state.city.value = picked;
  }
}
