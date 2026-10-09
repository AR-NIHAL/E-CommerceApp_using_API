import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/stats_providers.dart';
import '../widgets/adherence_gauge_card.dart';
import '../widgets/medicine_adherence_card.dart';
import '../widgets/stats_timeframe_selector.dart';
import '../widgets/streak_highlight_card.dart';
import '../widgets/weekly_bar_chart_card.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsDataAsyncProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Adherence Insights', style: AppTypography.titleLarge),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.navy),
            tooltip: 'Refresh Stats',
            onPressed: () => ref.invalidate(statsDataAsyncProvider),
          ),
        ],
      ),
      body: SafeArea(
        child: statsAsync.when(
          data: (stats) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                ref.invalidate(statsDataAsyncProvider);
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Timeframe Selector: Weekly | Monthly | All Time
                    const StatsTimeframeSelector(),
                    const SizedBox(height: 16),

                    // Overall Circular Adherence Gauge
                    AdherenceGaugeCard(stats: stats),
                    const SizedBox(height: 16),

                    // Streak Highlights (Current & Best)
                    StreakHighlightCard(streaks: stats.streaks),
                    const SizedBox(height: 16),

                    // Bar Chart using fl_chart
                    WeeklyBarChartCard(
                      points: stats.chartPoints,
                      timeframe: stats.timeframe,
                    ),
                    const SizedBox(height: 16),

                    // Per-Medicine Adherence Breakdown
                    MedicineAdherenceCard(medicines: stats.medicineBreakdown),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load statistics: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(statsDataAsyncProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            context.go('/');
          } else if (index == 1) {
            context.push('/refills');
          } else if (index == 2) {
            context.push('/history');
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
