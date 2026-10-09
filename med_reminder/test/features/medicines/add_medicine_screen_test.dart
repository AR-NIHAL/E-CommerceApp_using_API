import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/features/medicines/domain/entities/medicine.dart';
import 'package:flutter_application_2/features/medicines/presentation/controllers/add_medicine_controller.dart';
import 'package:flutter_application_2/features/medicines/presentation/screens/add_medicine_screen.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const AddMedicineScreen(),
      ),
    );
  }

  setUp(() {
    // any setup if needed
  });

  testWidgets('AddMedicineScreen renders all required fields and form chips', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify Title and Field Labels
    expect(find.text('Add Medicine'), findsOneWidget);
    expect(find.text('Medicine Name'), findsOneWidget);
    expect(find.text('Strength (optional)'), findsOneWidget);
    expect(find.text('Dosage'), findsOneWidget);
    expect(find.text('Form'), findsOneWidget);
    expect(find.text('Total Quantity'), findsOneWidget);
    expect(find.text('Schedule'), findsOneWidget);

    // Verify Form Chips
    expect(find.text('Tablet'), findsOneWidget);
    expect(find.text('Capsule'), findsOneWidget);
    expect(find.text('Syrup'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);

    // Verify Default Schedules
    expect(find.text('8:00 AM'), findsOneWidget);
    expect(find.text('After breakfast'), findsOneWidget);
    expect(find.text('9:00 PM'), findsOneWidget);
    expect(find.text('After dinner'), findsOneWidget);

    // Verify Buttons
    expect(find.text('Add another time'), findsOneWidget);
    expect(find.text('Save Medicine'), findsOneWidget);
  });

  testWidgets('AddMedicineScreen displays validation error when name is empty', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap Save Medicine with empty name
    final saveButton = find.text('Save Medicine');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Expect validation message
    expect(find.text('Please enter a medicine name'), findsOneWidget);
  });

  testWidgets('AddMedicineScreen allows selecting different medicine form', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap Capsule chip
    await tester.tap(find.text('Capsule'));
    await tester.pumpAndSettle();

    // Check notifier state reflects Capsule
    final element = tester.element(find.byType(AddMedicineScreen));
    final container = ProviderScope.containerOf(element);
    expect(container.read(addMedicineControllerProvider).form, MedicineForm.capsule);
  });

  testWidgets('AddMedicineScreen allows removing a schedule item', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Find delete buttons (red circle minus icons)
    final deleteButtons = find.byIcon(Icons.remove_circle_outline_rounded);
    expect(deleteButtons, findsNWidgets(2));

    // Tap first delete button
    await tester.tap(deleteButtons.first);
    await tester.pumpAndSettle();

    // Now only 1 delete button should remain
    expect(find.byIcon(Icons.remove_circle_outline_rounded), findsNWidgets(1));
  });
}
