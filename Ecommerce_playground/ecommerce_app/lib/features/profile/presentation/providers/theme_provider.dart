import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'profile_dependencies.dart';

part 'theme_provider.g.dart';

@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  @override
  ThemeMode build() {
    return ref.watch(themeModeStorageProvider).read();
  }

  void setMode(ThemeMode mode) {
    state = mode;
    ref.read(themeModeStorageProvider).save(mode);
  }
}
