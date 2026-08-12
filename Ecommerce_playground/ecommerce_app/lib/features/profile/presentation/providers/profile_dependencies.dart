import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/storage/theme_mode_storage.dart';

final themeModeStorageProvider = Provider<ThemeModeStorage>((ref) {
  return ThemeModeStorage();
});
