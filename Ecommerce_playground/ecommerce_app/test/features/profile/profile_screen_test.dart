import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ecommerce_app/app/theme/app_theme.dart';
import 'package:ecommerce_app/features/auth/domain/entities/auth_user.dart';
import 'package:ecommerce_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce_app/features/auth/presentation/providers/auth_dependencies.dart';
import 'package:ecommerce_app/features/profile/data/storage/theme_mode_storage.dart';
import 'package:ecommerce_app/features/profile/presentation/providers/profile_dependencies.dart';
import 'package:ecommerce_app/features/profile/presentation/screens/profile_screen.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this.currentUser);

  AuthUser? currentUser;

  @override
  Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
    return currentUser!;
  }

  @override
  Future<AuthUser?> restoreSession() async => currentUser;

  @override
  Future<void> logout() async {
    currentUser = null;
  }
}

class _InMemoryThemeModeStorage extends ThemeModeStorage {
  ThemeMode mode = ThemeMode.light;

  @override
  ThemeMode read() => mode;

  @override
  void save(ThemeMode value) => mode = value;
}

AuthUser _user() {
  return const AuthUser(
    id: 1,
    username: 'emilys',
    email: 'emilys@test.com',
    firstName: 'Emily',
    lastName: 'Johnson',
    gender: 'female',
    image: '',
    accessToken: 'token-abc',
  );
}

void main() {
  late _FakeAuthRepository repository;
  late _InMemoryThemeModeStorage storage;

  setUp(() {
    repository = _FakeAuthRepository(_user());
    storage = _InMemoryThemeModeStorage();
  });

  Future<void> pumpProfile(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('login'))),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          themeModeStorageProvider.overrideWithValue(storage),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the signed-in user info', (tester) async {
    await pumpProfile(tester);

    expect(find.text('Emily Johnson'), findsOneWidget);
    expect(find.text('@emilys'), findsOneWidget);
    expect(find.text('emilys@test.com'), findsOneWidget);
  });

  testWidgets('toggling dark mode persists the choice', (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(storage.mode, ThemeMode.dark);
  });

  testWidgets('logging out confirms, clears the session and navigates',
      (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Log out'));
    await tester.pumpAndSettle();

    expect(repository.currentUser, isNull);
    expect(find.text('login'), findsOneWidget);
  });

  testWidgets('cancelling the logout keeps the session', (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(repository.currentUser, isNotNull);
    expect(find.text('Emily Johnson'), findsOneWidget);
  });
}
