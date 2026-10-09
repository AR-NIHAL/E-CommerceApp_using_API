import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/features/dose_tracking/domain/entities/dose_occurrence.dart';
import 'package:flutter_application_2/features/dose_tracking/presentation/providers/dose_providers.dart';
import 'package:flutter_application_2/features/dose_tracking/presentation/screens/taken_success_screen.dart';
import 'package:flutter_application_2/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_application_2/features/medicines/domain/entities/medicine.dart';
import 'package:flutter_application_2/features/medicines/presentation/providers/medicine_providers.dart';

void main() {
  final now = DateTime.now();
  final testDoses = [
    DoseOccurrence(
      id: 'dose-1',
      medicineId: 'med-1',
      scheduleId: 's-1',
      medicineName: 'Metformin',
      strength: '500mg',
      form: MedicineForm.tablet,
      instruction: 'After breakfast',
      scheduledAtUtc: DateTime.utc(now.year, now.month, now.day, 8, 0),
      status: DoseStatus.taken,
    ),
    DoseOccurrence(
      id: 'dose-2',
      medicineId: 'med-2',
      scheduleId: 's-2',
      medicineName: 'Vitamin D3',
      form: MedicineForm.tablet,
      instruction: 'After breakfast',
      scheduledAtUtc: DateTime.utc(now.year, now.month, now.day, 10, 0),
      status: DoseStatus.pending,
    ),
    DoseOccurrence(
      id: 'dose-3',
      medicineId: 'med-3',
      scheduleId: 's-3',
      medicineName: 'Amlodipine',
      strength: '5mg',
      form: MedicineForm.tablet,
      instruction: 'After lunch',
      scheduledAtUtc: DateTime.utc(now.year, now.month, now.day, 14, 0),
      status: DoseStatus.taken,
    ),
    DoseOccurrence(
      id: 'dose-4',
      medicineId: 'med-4',
      scheduleId: 's-4',
      medicineName: 'Atorvastatin',
      strength: '10mg',
      form: MedicineForm.tablet,
      instruction: 'After dinner',
      scheduledAtUtc: DateTime.utc(now.year, now.month, now.day, 21, 0),
      status: DoseStatus.pending,
    ),
  ];

  Widget createTestWidget({List<DoseOccurrence>? doses}) {
    return ProviderScope(
      overrides: [
        todayDosesProvider.overrideWith(
          () => _FakeTodayDosesNotifier(doses ?? testDoses),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }

  testWidgets('HomeScreen renders progress ring, day strip, and scheduled medicines', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify Header
    expect(find.text('Take care today!'), findsOneWidget);

    // Verify 2/4 taken count in progress ring
    expect(find.text('2/4'), findsOneWidget);
    expect(find.text('Doses taken'), findsOneWidget);

    // Verify Medicine Names in Today's Schedule
    expect(find.text('Metformin 500mg'), findsOneWidget);
    expect(find.text('Vitamin D3'), findsOneWidget);
    expect(find.text('Amlodipine 5mg'), findsOneWidget);
    expect(find.text('Atorvastatin 10mg'), findsOneWidget);
  });

  testWidgets('Tapping pending dose opens ReminderModal with Mark as Taken and Skip actions', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap the pending Vitamin D3 card
    await tester.tap(find.text('Vitamin D3'));
    await tester.pumpAndSettle();

    // Verify Reminder Modal is shown
    expect(find.text('Time to take your medicine!'), findsOneWidget);
    expect(find.text('✓ Mark as Taken'), findsOneWidget);
    expect(find.text('Skip for now'), findsOneWidget);
  });

  testWidgets('TakenSuccessScreen renders congratulations and remaining stock', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          medicinesListProvider.overrideWith(() => _FakeMedicinesListNotifier()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: TakenSuccessScreen(dose: testDoses.first),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Well done!'), findsOneWidget);
    expect(find.text("You've taken your medicine"), findsOneWidget);
    expect(find.text('Metformin 500mg'), findsOneWidget);
    expect(find.text('Remaining tablets'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });
}

class _FakeTodayDosesNotifier extends TodayDosesNotifier {
  final List<DoseOccurrence> _initial;
  _FakeTodayDosesNotifier(this._initial);

  @override
  Future<List<DoseOccurrence>> build() async => _initial;
}

class _FakeMedicinesListNotifier extends MedicinesListNotifier {
  @override
  Future<List<Medicine>> build() async {
    return [
      Medicine(
        id: 'med-1',
        name: 'Metformin',
        strength: '500mg',
        form: MedicineForm.tablet,
        totalQuantity: 30,
        remainingQuantity: 28,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
