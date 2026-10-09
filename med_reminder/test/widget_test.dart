import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/app/app.dart';

void main() {
  testWidgets('MediCare app launch smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MediCareApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify HomeScreen renders header and schedule sections
    expect(find.text('Take care today!'), findsOneWidget);
    expect(find.text("Today's Schedule"), findsOneWidget);

    // Verify bottom navigation tabs
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Medicines'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
