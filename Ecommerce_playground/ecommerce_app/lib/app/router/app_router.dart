import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_dependencies.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/products/presentation/screens/home_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/shell/presentation/screens/main_shell.dart';
import '../../features/wishlist/presentation/screens/wishlist_screen.dart';
import 'routes.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final storage = ref.watch(onboardingStorageProvider);
  ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    redirect: (context, state) async {
      final location = state.matchedLocation;
      final hasSeenOnboarding = await storage.hasSeenOnboarding();

      final authState = ref.read(authControllerProvider);
      final isLoggedIn = authState.asData?.value != null;
      final isAuthResolved = !authState.isLoading;

      final isOnboarding = location == AppRoutes.onboarding;
      final isLogin = location == AppRoutes.login;
      final isShell = location.startsWith(AppRoutes.shell) ||
          location == AppRoutes.productDetail;

      if (isOnboarding) {
        if (hasSeenOnboarding && isLoggedIn) return AppRoutes.home;
        if (hasSeenOnboarding) return AppRoutes.login;
        return null;
      }

      if (isLogin) {
        if (!isAuthResolved) return null;
        if (isLoggedIn) return AppRoutes.home;
        return null;
      }

      if (isShell) {
        if (!isAuthResolved) return null;
        if (!isLoggedIn) return AppRoutes.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.productDetail,
        name: 'productDetail',
        builder: (context, state) => ProductDetailScreen(
          productId: int.parse(state.pathParameters['id']!),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.wishlist,
                name: 'wishlist',
                builder: (context, state) => const WishlistScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cart,
                name: 'cart',
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
