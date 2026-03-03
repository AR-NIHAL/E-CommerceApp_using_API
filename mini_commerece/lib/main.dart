import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_commerece/features/home/product_details_screen.dart';
import 'package:mini_commerece/features/home/root_screen.dart';
import 'package:mini_commerece/features/model/product_model.dart';
import 'package:mini_commerece/features/onboarding/onboarding_screen.dart';

import 'core/network/dio_client.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';

void main() {
  DioClient.addInterceptors();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.onboarding,
      routes: {
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.root: (_) => const RootScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.productDetails) {
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          );
        }
        return null;
      },
    );
  }
}
