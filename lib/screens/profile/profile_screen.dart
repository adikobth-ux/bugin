import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bugin/l10n/app_language.dart';
import 'package:bugin/l10n/app_strings.dart';
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
import 'package:bugin/widgets/info_card.dart';
import 'package:bugin/widgets/layout.dart';
import 'package:bugin/widgets/pressable.dart';
import 'package:bugin/widgets/snack.dart';

const _chevron = Icon(Icons.chevron_right_rounded, color: AppColors.inkSecondary);

/// Профиль без повторов: у каждого действия одно место.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final l10n = context.l10n;
    return TabPage(
      child: ListenableBuilder(
        listenable: Listenable.merge([
          services.profile,
          services.favorites,
          services.state.city,
          services.state.language,
        ]),
        builder: (context, _) {
          final profile = services.profile.profile;
          final favorites = services.favorites;
          final language = services.state.language.value;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            physics: const BouncingScrollPhysics(),
            children: [
              _Header(profile: profile, city: services.state.city.value),
              const SizedBox(height: 20),
              _TapCard(
                onTap: () => _editInterests(context),
                semanticLabel: l10n.profile.editInterests,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(l10n.profile.interestsTitle, style: AppText.titleSmall),
                        ),
                        _chevron,
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final interest in profile.interests)
                          _InterestChip(interest: interest),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _TapCard(
                onTap: () => _editBudget(context),
                semanticLabel: l10n.profile.editBudget,
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
                          Text(l10n.profile.usuallySpend, style: AppText.caption),
                          const SizedBox(height: 2),
                          Text(
                            l10n.profile.perPerson(l10n.upToTenge(profile.typicalBudget)),
                            style: AppText.titleSmall,
                          ),
                        ],
                      ),
                    ),
                    _chevron,
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _StatsGrid(
                stats: [
                  _Stat(
                    l10n.label(FavoritesSection.places),
                    favorites.count(FavoriteKind.place),
                    Icons.place_outlined,
                    () => AppNavigator.goToTab(
                      context,
                      AppTab.favorites,
                      section: FavoritesSection.places,
                    ),
                  ),
                  _Stat(
                    l10n.label(FavoritesSection.events),
                    favorites.count(FavoriteKind.event),
                    Icons.confirmation_number_outlined,
                    () => AppNavigator.goToTab(
                      context,
                      AppTab.favorites,
                      section: FavoritesSection.events,
                    ),
                  ),
                  _Stat(
                    l10n.label(FavoritesSection.scenarios),
                    favorites.count(FavoriteKind.scenario),
                    Icons.auto_awesome,
                    () => AppNavigator.goToTab(
                      context,
                      AppTab.favorites,
                      section: FavoritesSection.scenarios,
                    ),
                  ),
                  _Stat(
                    l10n.profile.queries,
                    profile.searchCount,
                    Icons.history_rounded,
                    () => AppNavigator.openSearch(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              InfoCard(
                children: [
                  InfoRow.text(
                    icon: Icons.language_rounded,
                    title: l10n.profile.languageRow,
                    subtitle: language.nativeName,
                    trailing: _chevron,
                    onTap: () => _pickLanguage(context),
                  ),
                  InfoRow.text(
                    icon: Icons.notifications_none_rounded,
                    title: l10n.profile.notifications,
                    subtitle: l10n.profile.notificationsHint,
                    trailing: _chevron,
                    onTap: () => _editNotifications(context),
                  ),
                  InfoRow.text(
                    icon: Icons.privacy_tip_outlined,
                    title: l10n.profile.privacy,
                    subtitle: l10n.profile.privacyHint,
                    trailing: _chevron,
                    onTap: () => showDemoSnack(context, l10n.profile.privacyDemo),
                  ),
                  InfoRow.text(
                    icon: Icons.help_outline_rounded,
                    title: l10n.profile.help,
                    subtitle: l10n.profile.helpHint,
                    trailing: _chevron,
                    onTap: () => showDemoSnack(context, l10n.profile.helpDemo),
                  ),
                  if (services.canResetData)
                    InfoRow.text(
                      icon: Icons.restart_alt_rounded,
                      title: l10n.profile.resetData,
                      subtitle: l10n.profile.resetDataHint,
                      trailing: _chevron,
                      onTap: () => _resetData(context),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Pressable(
                  onTap: () => _logout(context),
                  child: SizedBox(
                    height: 48,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.logout_rounded, size: 18, color: AppColors.danger),
                        const SizedBox(width: 10),
                        Text(
                          l10n.profile.logout,
                          style: const TextStyle(
                            fontFamily: AppText.family,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(child: Text(l10n.profile.footer, style: AppText.micro)),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editInterests(BuildContext context) async {
    final store = AppScope.of(context).profile;
    final l10n = context.l10n;
    final selected = Set<Interest>.of(store.profile.interests);
    final result = await showAppSheet<List<Interest>>(
      context,
      title: l10n.profile.interestsTitle,
      subtitle: l10n.profile.interestsHint,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final interest in Interest.values)
                  SelectChip(
                    label: l10n.label(interest),
                    icon: Visuals.interestIcon(interest),
                    selected: selected.contains(interest),
                    onTap: () => setSheetState(() {
                      if (!selected.remove(interest)) {
                        selected.add(interest);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: l10n.save,
              onPressed: selected.isEmpty
                  ? null
                  : () => Navigator.of(sheetContext).pop(
                        Interest.values.where(selected.contains).toList(),
                      ),
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      HapticFeedback.selectionClick();
      store.updateInterests(result);
    }
  }

  Future<void> _editBudget(BuildContext context) async {
    final store = AppScope.of(context).profile;
    final l10n = context.l10n;
    var value = store.profile.typicalBudget.toDouble();
    final result = await showAppSheet<int>(
      context,
      title: l10n.profile.budgetTitle,
      subtitle: l10n.profile.budgetHint,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.upToTenge(value.round()),
              textAlign: TextAlign.center,
              style: AppText.h1,
            ),
            const SizedBox(height: 8),
            Slider(
              value: value,
              min: 3000,
              max: 50000,
              divisions: 47,
              semanticFormatterCallback: (v) => l10n.upToTenge(v.round()),
              onChanged: (v) => setSheetState(() => value = (v / 1000).round() * 1000.0),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('3 000 ₸', style: AppText.micro),
                Text('50 000 ₸', style: AppText.micro),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: l10n.save,
              onPressed: () => Navigator.of(sheetContext).pop(value.round()),
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      HapticFeedback.selectionClick();
      store.updateBudget(result);
    }
  }

  Future<void> _editNotifications(BuildContext context) {
    final store = AppScope.of(context).profile;
    final l10n = context.l10n;
    final options = l10n.profile.notificationOptions;
    return showAppSheet<void>(
      context,
      title: l10n.profile.notifications,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final values = store.profile.notifications;
          return Column(
            children: [
              for (final entry in options.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.value.$1, style: AppText.bodyStrong),
                            Text(entry.value.$2, style: AppText.caption),
                          ],
                        ),
                      ),
                      Switch(
                        value: values[entry.key] ?? false,
                        onChanged: (enabled) {
                          HapticFeedback.selectionClick();
                          store.setNotification(entry.key, enabled);
                          setSheetState(() {});
                        },
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Язык меняется сразу: приложение пересоберётся на нём, вкладка останется.
  Future<void> _pickLanguage(BuildContext context) async {
    final state = AppScope.of(context).state;
    final current = state.language.value;
    final picked = await showAppSheet<AppLanguage>(
      context,
      title: context.l10n.profile.languageTitle,
      builder: (sheetContext) => Column(
        children: [
          for (final language in AppLanguage.values)
            SheetOption(
              label: language.nativeName,
              selected: language == current,
              onTap: () => Navigator.of(sheetContext).pop(language),
            ),
        ],
      ),
    );
    if (picked != null && picked != state.language.value) {
      HapticFeedback.selectionClick();
      state.language.value = picked;
    }
  }

  /// Возвращает избранное, профиль и историю поиска к начальным (только mock).
  Future<void> _resetData(BuildContext context) async {
    final services = AppScope.of(context);
    final l10n = context.l10n.profile;
    final confirmed = await _confirm(
      context,
      title: l10n.resetConfirmTitle,
      message: l10n.resetConfirmMessage,
      action: l10n.resetConfirm,
    );
    if (!confirmed) {
      return;
    }
    services.resetData();
    HapticFeedback.lightImpact();
    if (context.mounted) {
      showAppSnack(context, l10n.resetDone);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final l10n = context.l10n.profile;
    final confirmed = await _confirm(
      context,
      title: l10n.logoutTitle,
      message: l10n.logoutMessage,
      action: l10n.logoutConfirm,
    );
    if (confirmed && context.mounted) {
      showDemoSnack(context, l10n.logoutDemo);
    }
  }

  /// Диалог подтверждения: true — если нажали [action].
  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String action,
  }) async {
    final cancel = context.l10n.cancel;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(action, style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    return confirmed == true;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile, required this.city});

  final UserProfile profile;
  final String city;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox.square(
          dimension: 76,
          child: Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  profile.initials,
                  style: AppText.display.copyWith(color: AppColors.primaryInk),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Pressable(
                  onTap: () => showDemoSnack(context, context.l10n.profile.changePhotoDemo),
                  semanticLabel: context.l10n.profile.changePhoto,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                    child: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(profile.name, style: AppText.h1.copyWith(fontSize: 22)),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 15, color: AppColors.inkSecondary),
                  const SizedBox(width: 4),
                  Text(city, style: AppText.caption.copyWith(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 3),
              Text(profile.bio, style: AppText.caption.copyWith(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TapCard extends StatelessWidget {
  const _TapCard({required this.child, required this.onTap, this.semanticLabel});

  final Widget child;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.98,
      semanticLabel: semanticLabel,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        child: child,
      ),
    );
  }
}

class _InterestChip extends StatelessWidget {
  const _InterestChip({required this.interest});

  final Interest interest;

  @override
  Widget build(BuildContext context) {
    final tone = Visuals.interestTone(interest);
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Visuals.interestIcon(interest), size: 16, color: tone.foreground),
          const SizedBox(width: 6),
          Text(
            context.l10n.label(interest),
            style: AppText.captionStrong.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _Stat {
  const _Stat(this.label, this.value, this.icon, this.onTap);

  final String label;
  final int value;
  final IconData icon;
  final VoidCallback onTap;
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final List<_Stat> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 340 ? 4 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 8) / columns;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final stat in stats)
              SizedBox(
                width: width,
                child: Pressable(
                  onTap: stat.onTap,
                  semanticLabel: '${stat.label}: ${stat.value}',
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: ExcludeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(stat.icon, size: 18, color: AppColors.primary),
                          const SizedBox(height: 6),
                          Text('${stat.value}', style: AppText.h2),
                          Text(
                            stat.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.micro,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
