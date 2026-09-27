import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bugin/core/formatters.dart';
import 'package:bugin/models/models.dart';
import 'package:bugin/navigation/app_navigator.dart';
import 'package:bugin/theme/app_colors.dart';
import 'package:bugin/theme/app_text.dart';
import 'package:bugin/theme/app_theme.dart';
import 'package:bugin/widgets/buttons.dart';
import 'package:bugin/widgets/chips.dart';
import 'package:bugin/widgets/layout.dart';
import 'package:bugin/widgets/sticky_action_bar.dart';

/// «Собрать мне вечер», шаг 1 — параметры. Результат открывается отдельным экраном.
class EveningFormScreen extends StatefulWidget {
  const EveningFormScreen({super.key, this.initial});

  final EveningRequest? initial;

  @override
  State<EveningFormScreen> createState() => _EveningFormScreenState();
}

class _EveningFormScreenState extends State<EveningFormScreen> {
  late EveningRequest _request = widget.initial ?? const EveningRequest();
  late final TextEditingController _wishes =
      TextEditingController(text: _request.wishes);

  @override
  void dispose() {
    _wishes.dispose();
    super.dispose();
  }

  void _update(EveningRequest next) {
    HapticFeedback.selectionClick();
    setState(() => _request = next);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _request.date ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 60)),
      helpText: 'Когда собираемся?',
    );
    if (picked != null && mounted) {
      _update(_request.copyWith(day: PlanDay.date, date: picked));
    }
  }

  void _create() {
    FocusScope.of(context).unfocus();
    final request = _request.copyWith(wishes: _wishes.text.trim());
    AppNavigator.openPlan(context, request: request);
  }

  @override
  Widget build(BuildContext context) {
    final date = _request.date;

    return AnnotatedRegion(
      value: AppTheme.overlayOnLight,
      child: Scaffold(
        bottomNavigationBar: StickyActionBar(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _request.summary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                label: 'Создать план',
                icon: Icons.auto_awesome,
                onPressed: _create,
              ),
            ],
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: ContentWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                const Row(
                  children: [
                    AppBackButton(),
                    SizedBox(width: 8),
                    Text('Собрать мне вечер', style: AppText.title),
                  ],
                ),
                const SizedBox(height: 20),
                Semantics(
                  header: true,
                  child: const Text('Какой вечер хочешь?', style: AppText.display),
                ),
                const SizedBox(height: 4),
                Text(
                  'Соберу план: места, время и бюджет',
                  style: AppText.body.copyWith(color: AppColors.inkSecondary),
                ),
                const SizedBox(height: 24),
                _Question(
                  icon: Icons.people_outline_rounded,
                  title: 'С кем?',
                  children: [
                    for (final company in Company.values)
                      SelectChip(
                        label: company.label,
                        selected: _request.company == company,
                        onTap: () => _update(_request.copyWith(company: company)),
                      ),
                  ],
                ),
                _Question(
                  icon: Icons.calendar_today_outlined,
                  title: 'Когда?',
                  children: [
                    for (final day in PlanDay.values)
                      SelectChip(
                        label: day == PlanDay.date && date != null
                            ? Fmt.relativeDay(date)
                            : day.label,
                        icon: day == PlanDay.date ? Icons.calendar_month_outlined : null,
                        selected: _request.day == day,
                        onTap: () {
                          if (day == PlanDay.date) {
                            _pickDate();
                          } else {
                            _update(_request.copyWith(day: day));
                          }
                        },
                      ),
                  ],
                ),
                _Question(
                  icon: Icons.schedule_rounded,
                  title: 'Во сколько начнём?',
                  children: [
                    for (final start in EveningRequest.startOptions)
                      SelectChip(
                        label: Fmt.hm(start),
                        selected: _request.startMinutes == start,
                        onTap: () => _update(_request.copyWith(startMinutes: start)),
                      ),
                  ],
                ),
                _Question(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Бюджет на человека',
                  children: [
                    for (final budget in EveningRequest.budgetOptions)
                      SelectChip(
                        label: EveningRequest.budgetLabel(budget),
                        selected: _request.budget == budget,
                        onTap: () => _update(
                          budget == null
                              ? _request.copyWith(anyBudget: true)
                              : _request.copyWith(budget: budget),
                        ),
                      ),
                  ],
                ),
                _Question(
                  icon: Icons.dark_mode_outlined,
                  title: 'Настроение',
                  children: [
                    for (final mood in Mood.values)
                      SelectChip(
                        label: mood.label,
                        selected: _request.mood == mood,
                        onTap: () => _update(_request.copyWith(mood: mood)),
                      ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Пожелания', style: AppText.bodyStrong),
                    const SizedBox(width: 6),
                    Text('— необязательно', style: AppText.caption.copyWith(fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _wishes,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  style: AppText.bodyStrong.copyWith(fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Например: без кино, хочу погулять у воды',
                    hintStyle: AppText.body.copyWith(color: AppColors.inkMuted),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
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

class _Question extends StatelessWidget {
  const _Question({required this.icon, required this.title, required this.children});

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Semantics(header: true, child: Text(title, style: AppText.bodyStrong)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: children),
        ],
      ),
    );
  }
}
