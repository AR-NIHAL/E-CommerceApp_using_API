import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:ecommerce_app/core/storage/hive_boxes.dart';
import 'package:ecommerce_app/features/auth/presentation/screens/login_screen.dart';

Widget _buildTestable() {
  return const ProviderScope(
    child: MaterialApp(home: LoginScreen()),
  );
}

void main() {
  setUp(() async {
    final dir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(dir.path);
    await Hive.openBox(HiveBoxes.auth);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
  });

  testWidgets('shows validation errors for empty fields', (tester) async {
    await tester.pumpWidget(_buildTestable());
    await tester.pumpAndSettle();

    final username = find.byType(TextFormField).at(0);
    final password = find.byType(TextFormField).at(1);

    await tester.enterText(username, '');
    await tester.enterText(password, '');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your username'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('renders password visibility toggle', (tester) async {
    await tester.pumpWidget(_buildTestable());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });
}
