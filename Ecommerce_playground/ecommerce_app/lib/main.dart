import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'core/storage/hive_boxes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox(HiveBoxes.auth);
  await Hive.openBox(HiveBoxes.cart);
  await Hive.openBox(HiveBoxes.wishlist);

  runApp(const ProviderScope(child: SwiftShopApp()));
}
