import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app/features/profile/data/storage/theme_mode_storage.dart';
import 'package:ecommerce_app/features/profile/presentation/providers/profile_dependencies.dart';
import 'package:ecommerce_app/features/profile/presentation/providers/theme_provider.dart';

class _InMemoryThemeModeStorage extends ThemeModeStorage {
  ThemeMode mode = ThemeMode.light;

  @override
  ThemeMode read() => mode;

  @override
  void save(ThemeMode value) => mode = value;
}

void main() {
  late ProviderContainer container;
  late _InMemoryThemeModeStorage storage;

  setUp(() {
    storage = _InMemoryThemeModeStorage();
    container = ProviderContainer(
      overrides: [
        themeModeStorageProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(container.dispose);
  });

  test('starts with light mode', () {
    expect(container.read(themeControllerProvider), ThemeMode.light);
  });

  test('setMode updates state and persists', () {
    final controller = container.read(themeControllerProvider.notifier);
    controller.setMode(ThemeMode.dark);

    expect(container.read(themeControllerProvider), ThemeMode.dark);
    expect(storage.mode, ThemeMode.dark);
  });

  test('a new container builds from the persisted mode', () {
    storage.mode = ThemeMode.dark;

    final freshContainer = ProviderContainer(
      overrides: [
        themeModeStorageProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(freshContainer.dispose);

    expect(freshContainer.read(themeControllerProvider), ThemeMode.dark);
  });
}
