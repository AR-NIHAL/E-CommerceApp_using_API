import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/features/medicines/domain/entities/medicine.dart';
import 'package:flutter_application_2/features/medicines/domain/entities/medicine_schedule.dart';
import 'package:flutter_application_2/features/medicines/domain/repositories/medicine_repository.dart';
import 'package:flutter_application_2/features/medicines/domain/usecases/get_medicine_details_usecase.dart';
import 'package:flutter_application_2/features/medicines/presentation/providers/medicine_providers.dart';
import 'package:flutter_application_2/features/medicines/presentation/screens/medicine_details_screen.dart';
import 'package:flutter_application_2/features/medicines/presentation/screens/refill_reminder_screen.dart';

class _FakeMedRepo extends Fake implements MedicineRepository {}

class _FakeGetMedicineDetailsUseCase extends GetMedicineDetailsUseCase {
  final MedicineDetailsData _data;
  _FakeGetMedicineDetailsUseCase(super.repository, this._data);

  @override
  Future<MedicineDetailsData> execute(String medicineId) async => _data;
}

class _FakeMedicinesListNotifier extends MedicinesListNotifier {
  final List<Medicine> _meds;
  _FakeMedicinesListNotifier(this._meds);

  @override
  Future<List<Medicine>> build() async => _meds;
}

void main() {
  final now = DateTime(2024, 9, 1);
  final testMedicine = Medicine(
    id: 'med-metformin',
    name: 'Metformin',
    strength: '500mg',
    form: MedicineForm.tablet,
    category: 'Diabetes',
    totalQuantity: 30,
    remainingQuantity: 12,
    startDate: now,
    createdAt: now,
    updatedAt: now,
  );

  final testSchedules = [
    const MedicineSchedule(
      id: 's-1',
      medicineId: 'med-metformin',
      hour: 8,
      minute: 0,
      instruction: 'After breakfast',
    ),
    const MedicineSchedule(
      id: 's-2',
      medicineId: 'med-metformin',
      hour: 21,
      minute: 0,
      instruction: 'After dinner',
    ),
  ];

  testWidgets('MedicineDetailsScreen renders header, key-values, schedules and delete button', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final detailsData = MedicineDetailsData(
      medicine: testMedicine,
      schedules: testSchedules,
      refillHistory: [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getMedicineDetailsUseCaseProvider.overrideWithValue(
            _FakeGetMedicineDetailsUseCase(
              _FakeMedRepo(),
              detailsData,
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MedicineDetailsScreen(medicineId: 'med-metformin'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Header
    expect(find.text('Medicine Details'), findsOneWidget);
    expect(find.text('Metformin'), findsOneWidget);
    expect(find.text('500mg'), findsOneWidget);
    expect(find.text('Tablet'), findsOneWidget);
    expect(find.text('Diabetes'), findsOneWidget);

    // Verify Details rows
    expect(find.text('Total Quantity'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('Remaining'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Times per day'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1 Sep 2024'), findsOneWidget);

    // Verify Schedules
    expect(find.text('8:00 AM'), findsOneWidget);
    expect(find.text('After breakfast'), findsOneWidget);
    expect(find.text('9:00 PM'), findsOneWidget);
    expect(find.text('After dinner'), findsOneWidget);

    // Verify Delete Button
    expect(find.text('Delete Medicine'), findsOneWidget);
  });

  testWidgets('RefillReminderScreen renders running low alert and allows opening refill dialog', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final lowStockMed = testMedicine.copyWith(remainingQuantity: 5, refillThreshold: 5);
    final normalMed = Medicine(
      id: 'med-vitd',
      name: 'Vitamin D3',
      form: MedicineForm.tablet,
      totalQuantity: 30,
      remainingQuantity: 18,
      startDate: now,
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          medicinesListProvider.overrideWith(
            () => _FakeMedicinesListNotifier([lowStockMed, normalMed]),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const RefillReminderScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Screen Title
    expect(find.text('Refill Reminder'), findsOneWidget);

    // Verify Running low alert card
    expect(find.text('Running low'), findsOneWidget);
    expect(find.text('Only 5 tablets remaining'), findsOneWidget);

    // Verify All Medicines List
    expect(find.text('All Medicines'), findsOneWidget);
    expect(find.text('5 left'), findsOneWidget);
    expect(find.text('18 left'), findsOneWidget);

    // Tap quick refill button
    final refillIcons = find.byIcon(Icons.add_circle_outline_rounded);
    expect(refillIcons, findsWidgets);
    await tester.tap(refillIcons.first);
    await tester.pumpAndSettle();

    // Verify Refill Dialog opened
    expect(find.text('Refill Metformin'), findsOneWidget);
    expect(find.text('Refill Stock'), findsOneWidget);
  });
}
