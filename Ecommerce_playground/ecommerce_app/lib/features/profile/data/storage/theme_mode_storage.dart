import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../../core/storage/hive_boxes.dart';

class ThemeModeStorage {
  static const String _key = 'themeMode';

  ThemeMode read() {
    final value = Hive.box(HiveBoxes.settings).get(_key);
    if (value == 'dark') return ThemeMode.dark;
    return ThemeMode.light;
  }

  void save(ThemeMode mode) {
    Hive.box(HiveBoxes.settings)
        .put(_key, mode == ThemeMode.dark ? 'dark' : 'light');
  }
}
