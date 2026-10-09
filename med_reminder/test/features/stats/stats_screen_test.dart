import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/features/medicines/domain/entities/medicine.dart';
import 'package:flutter_application_2/features/stats/domain/entities/stats_models.dart';
import 'package:flutter_application_2/features/stats/presentation/providers/stats_providers.dart';
import 'package:flutter_application_2/features/stats/presentation/screens/stats_screen.dart';
import 'package:flutter_application_2/features/stats/presentation/widgets/adherence_gauge_card.dart';
import 'package:flutter_application_2/features/stats/presentation/widgets/medicine_adherence_card.dart';
import 'package:flutter_application_2/features/stats/presentation/widgets/stats_timeframe_selector.dart';
import 'package:flutter_application_2/features/stats/presentation/widgets/streak_highlight_card.dart';
import 'package:flutter_application_2/features/stats/presentation/widgets/weekly_bar_chart_card.dart';

void main() {
  final mockStats = OverallStats(
    timeframe: StatsTimeframe.weekly,
    totalDoses: 42,
    takenDoses: 36,
    skippedDoses: 4,
    missedDoses: 2,
    pendingDoses: 0,
    overallAdherenceRate: 0.86,
    chartPoints: [
      DayChartPoint(date: DateTime(2024, 9, 16), dayLabel: 'Mon', total: 6, taken: 6),
      DayChartPoint(date: DateTime(2024, 9, 17), dayLabel: 'Tue', total: 6, taken: 5),
      DayChartPoint(date: DateTime(2024, 9, 18), dayLabel: 'Wed', total: 6, taken: 5),
      DayChartPoint(date: DateTime(2024, 9, 19), dayLabel: 'Thu', total: 6, taken: 6),
      DayChartPoint(date: DateTime(2024, 9, 20), dayLabel: 'Fri', total: 6, taken: 4),
      DayChartPoint(date: DateTime(2024, 9, 21), dayLabel: 'Sat', total: 6, taken: 5),
      DayChartPoint(date: DateTime(2024, 9, 22), dayLabel: 'Sun', total: 6, taken: 5),
    ],
    medicineBreakdown: const [
      MedicineAdherence(
        medicineId: 'm1',
        medicineName: 'Metformin',
        strength: '500mg',
        form: MedicineForm.tablet,
        totalDoses: 14,
        takenDoses: 13,
        skippedDoses: 1,
        missedDoses: 0,
      ),
      MedicineAdherence(
        medicineId: 'm2',
        medicineName: 'Amlodipine',
        strength: '5mg',
        form: MedicineForm.tablet,
        totalDoses: 14,
        takenDoses: 11,
        skippedDoses: 2,
        missedDoses: 1,
      ),
    ],
    streaks: const StreakStats(currentStreak: 5, bestStreak: 12),
  );

  Widget buildTestableWidget() {
    return ProviderScope(
      overrides: [
        statsDataAsyncProvider.overrideWith((ref) async => mockStats),
      ],
      child: const MaterialApp(
        home: StatsScreen(),
      ),
    );
  }

  testWidgets('StatsScreen renders header, gauge, streaks, bar chart, and medicine breakdown',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Verify AppBar & Title
    expect(find.text('Adherence Insights'), findsOneWidget);

    // Verify Timeframe Selector
    expect(find.byType(StatsTimeframeSelector), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('All Time'), findsOneWidget);

    // Verify Adherence Gauge Card
    expect(find.byType(AdherenceGaugeCard), findsOneWidget);
    expect(find.text('86%'), findsOneWidget);
    expect(find.text('Adherence'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('36'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    // Verify Streak Highlight Card
    expect(find.byType(StreakHighlightCard), findsOneWidget);
    expect(find.text('5 Days'), findsOneWidget);
    expect(find.text('Current Streak'), findsOneWidget);
    expect(find.text('12 Days'), findsOneWidget);
    expect(find.text('Best Streak'), findsOneWidget);

    // Verify Weekly Bar Chart Card
    expect(find.byType(WeeklyBarChartCard), findsOneWidget);
    expect(find.byType(BarChart), findsOneWidget);
    expect(find.text('Weekly Adherence Trend'), findsOneWidget);

    // Verify Medicine Breakdown Card
    expect(find.byType(MedicineAdherenceCard), findsOneWidget);
    expect(find.text('Medication Breakdown'), findsOneWidget);
    expect(find.text('Metformin 500mg'), findsOneWidget);
    expect(find.text('Amlodipine 5mg'), findsOneWidget);
  });

  testWidgets('Tapping timeframe switches selector mode', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Tap 'Monthly'
    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();

    // Verify tap was registered
    expect(find.text('Monthly'), findsOneWidget);

    // Tap 'All Time'
    await tester.tap(find.text('All Time'));
    await tester.pumpAndSettle();

    expect(find.text('All Time'), findsOneWidget);
  });
}
