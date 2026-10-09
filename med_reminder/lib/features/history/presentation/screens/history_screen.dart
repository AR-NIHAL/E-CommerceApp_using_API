import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/history_models.dart';
import '../providers/history_providers.dart';
import '../widgets/history_calendar_card.dart';
import '../widgets/history_dose_card.dart';
import '../widgets/history_summary_card.dart';
import '../widgets/history_view_selector.dart';
import '../widgets/history_weekly_view.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(historyViewModeProvider);
    final selectedDoses = ref.watch(selectedDateDosesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Medication History', style: AppTypography.titleLarge),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded, color: AppColors.primary),
            tooltip: 'Go to Today',
            onPressed: () {
              ref.read(historyControllerProvider).selectDate(DateTime.now());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.read(historyControllerProvider).refresh(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Segmented view mode selector
                const HistoryViewSelector(),
                const SizedBox(height: 16),

                // Calendar view vs Weekly view
                if (viewMode == HistoryViewMode.weekly) ...[
                  const HistoryWeeklyView(),
                  const SizedBox(height: 16),
                ] else ...[
                  const HistoryCalendarCard(),
                  const SizedBox(height: 16),
                ],

                // Summary card for selected day
                const HistorySummaryCard(),
                const SizedBox(height: 20),

                // Section Header: Day's Medications
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Scheduled Medications",
                      style: AppTypography.titleMedium,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${selectedDoses.length} ${selectedDoses.length == 1 ? 'dose' : 'doses'}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // List of doses for the selected day
                if (selectedDoses.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.event_available_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No medications scheduled',
                          style: AppTypography.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'No doses are recorded or scheduled for this date.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  ...selectedDoses.map((dose) => HistoryDoseCard(dose: dose)),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // History is tab 2
        onTap: (index) {
          if (index == 0) {
            context.go('/');
          } else if (index == 1) {
            context.push('/refills');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication_rounded),
            label: 'Medicines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
