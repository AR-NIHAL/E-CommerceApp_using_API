import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_2/features/dose_tracking/domain/entities/dose_occurrence.dart';
import 'package:flutter_application_2/features/history/presentation/providers/history_providers.dart';
import 'package:flutter_application_2/features/history/presentation/screens/history_screen.dart';
import 'package:flutter_application_2/features/history/presentation/widgets/history_calendar_card.dart';
import 'package:flutter_application_2/features/history/presentation/widgets/history_dose_card.dart';
import 'package:flutter_application_2/features/history/presentation/widgets/history_summary_card.dart';
import 'package:flutter_application_2/features/history/presentation/widgets/history_view_selector.dart';
import 'package:flutter_application_2/features/history/presentation/widgets/history_weekly_view.dart';
import 'package:flutter_application_2/features/medicines/domain/entities/medicine.dart';

void main() {
  final testMonth = DateTime(2024, 9, 1);
  final testDate = DateTime(2024, 9, 16);

  final mockDoses = [
    DoseOccurrence(
      id: 'occ_1',
      medicineId: 'med_1',
      scheduleId: 'sch_1',
      medicineName: 'Amoxicillin',
      strength: '500mg',
      form: MedicineForm.capsule,
      instruction: 'After breakfast',
      scheduledAtUtc: DateTime(2024, 9, 16, 8, 0).toUtc(),
      status: DoseStatus.taken,
    ),
    DoseOccurrence(
      id: 'occ_2',
      medicineId: 'med_2',
      scheduleId: 'sch_2',
      medicineName: 'Metformin',
      strength: '500mg',
      form: MedicineForm.tablet,
      instruction: 'With lunch',
      scheduledAtUtc: DateTime(2024, 9, 16, 12, 0).toUtc(),
      status: DoseStatus.skipped,
    ),
    DoseOccurrence(
      id: 'occ_3',
      medicineId: 'med_3',
      scheduleId: 'sch_3',
      medicineName: 'Lisinopril',
      strength: '10mg',
      form: MedicineForm.tablet,
      instruction: 'Before bedtime',
      scheduledAtUtc: DateTime(2024, 9, 16, 21, 0).toUtc(),
      status: DoseStatus.missed,
    ),
  ];

  Widget buildTestableWidget({DateTime? selectedDate}) {
    return ProviderScope(
      overrides: [
        historyCurrentMonthProvider.overrideWith((ref) => testMonth),
        historySelectedDateProvider.overrideWith((ref) => selectedDate ?? testDate),
        monthlyDosesProvider.overrideWith((ref, arg) async => mockDoses),
      ],
      child: const MaterialApp(
        home: HistoryScreen(),
      ),
    );
  }

  testWidgets('HistoryScreen renders title, view selector, calendar, and summary card',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Verify Title and AppBar
    expect(find.text('Medication History'), findsOneWidget);
    expect(find.byType(HistoryViewSelector), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);

    // Verify Calendar Card
    expect(find.byType(HistoryCalendarCard), findsOneWidget);
    expect(find.text('September 2024'), findsOneWidget);

    // Verify Summary Card
    expect(find.byType(HistorySummaryCard), findsOneWidget);
    expect(find.text('Taken'), findsWidgets);
    expect(find.text('Skipped'), findsWidgets);
    expect(find.text('Missed'), findsWidgets);

    // Verify Doses Header & List
    expect(find.text('Scheduled Medications'), findsOneWidget);
    expect(find.text('3 doses'), findsOneWidget);
    expect(find.byType(HistoryDoseCard), findsNWidgets(3));
    expect(find.text('Amoxicillin 500mg'), findsOneWidget);
    expect(find.text('Metformin 500mg'), findsOneWidget);
    expect(find.text('Lisinopril 10mg'), findsOneWidget);
  });

  testWidgets('HistoryScreen toggles between Monthly and Weekly views', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Default view shows calendar
    expect(find.byType(HistoryCalendarCard), findsOneWidget);
    expect(find.byType(HistoryWeeklyView), findsNothing);

    // Switch to Weekly view
    await tester.tap(find.text('Weekly'));
    await tester.pumpAndSettle();

    expect(find.byType(HistoryWeeklyView), findsOneWidget);
    expect(find.byType(HistoryCalendarCard), findsNothing);

    // Switch back to Monthly view
    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();

    expect(find.byType(HistoryCalendarCard), findsOneWidget);
    expect(find.byType(HistoryWeeklyView), findsNothing);
  });

  testWidgets('HistoryScreen displays empty state when no doses for selected date',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestableWidget(selectedDate: DateTime(2024, 9, 20)));
    await tester.pumpAndSettle();

    expect(find.text('No medications scheduled'), findsOneWidget);
    expect(find.text('0 doses'), findsOneWidget);
  });
}
