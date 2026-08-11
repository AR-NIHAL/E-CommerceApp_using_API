# SwiftShop — Portfolio E-Commerce App (Clean Architecture)

A modern, minimal e-commerce mobile app built with Flutter for a junior Flutter developer portfolio.

> **Workflow:** Each phase is developed one at a time. Before starting a phase, the phase task list is presented and confirmed. `flutter analyze` + `flutter test` must pass after every phase before moving on.

---

## Tech Stack (2026)

| Layer | Choice |
|---|---|
| Framework | Flutter (stable, Dart SDK ^3.10.1) |
| Architecture | Feature-first **Clean Architecture** — `data` / `domain` / `presentation` per feature + shared `core` |
| State management | **Riverpod 3.x** — `riverpod_generator` + `build_runner` for async providers, manual `Notifier` for cart/wishlist |
| Networking | **Dio 5.x** with logging + auth interceptors |
| Routing | **GoRouter** (declarative, redirects for auth-guarded routes) |
| Local storage | **Hive** (fast key-value DB) for cart + wishlist; Hive box for auth token |
| Backend | **DummyJSON** — products, categories, search, pagination, `/auth/login` token |
| Design | **Neutral minimal** — off-white background, near-black text, single accent, soft shadows, rounded corners, generous whitespace |
| Tests | Unit (models, repositories, cart/wishlist logic) + widget (product card, cart tile, key screens) |

## Key Dependencies

```yaml
dependencies:
  flutter_riverpod: ^3.x
  riverpod_annotation: ^3.x
  dio: ^5.x
  go_router: ^17.x
  hive: ^2.x
  hive_flutter: ^1.x
  shimmer: ^3.x
  google_fonts: ^6.x
  flutter_secure_storage: ^9.x   # optional: token storage

dev_dependencies:
  riverpod_generator: ^3.x
  build_runner: ^2.x
  hive_generator: ^1.x
```

---

## Folder Structure (Clean Architecture)

```
lib/
├── main.dart                     # ProviderScope + Hive init + runApp
├── app/
│   ├── app.dart                  # MaterialApp.router (GoRouter + theme)
│   ├── router/
│   │   ├── app_router.dart       # GoRouter config
│   │   └── routes.dart           # route paths
│   └── theme/
│       ├── app_colors.dart
│       ├── app_theme.dart
│       └── app_text_styles.dart
├── core/
│   ├── network/
│   │   ├── dio_client.dart
│   │   ├── api_constants.dart
│   │   └── dio_interceptors.dart
│   ├── storage/
│   │   ├── hive_boxes.dart
│   │   ├── cart_storage.dart
│   │   ├── wishlist_storage.dart
│   │   └── auth_token_storage.dart
│   ├── errors/
│   │   ├── failures.dart
│   │   ├── app_exception.dart
│   │   └── exception_mapper.dart
│   └── utils/
├── shared/
│   └── widgets/
│       ├── product_card.dart
│       ├── shimmer_loader.dart
│       ├── error_view.dart
│       ├── empty_view.dart
│       └── rating_badge.dart
└── features/
    ├── onboarding/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │       ├── onboarding_screen.dart
    │       ├── onboarding_page.dart
    │       └── onboarding_data.dart
    ├── auth/
    │   ├── data/
    │   │   ├── models/auth_response.dart
    │   │   └── datasources/auth_remote_source.dart
    │   ├── domain/
    │   │   ├── entities/auth_user.dart
    │   │   ├── repositories/auth_repository.dart
    │   │   └── usecases/login_usecase.dart
    │   └── presentation/
    │       ├── providers/auth_provider.dart
    │       └── screens/login_screen.dart
    ├── products/
    │   ├── data/
    │   │   ├── models/product.dart
    │   │   ├── models/products_response.dart
    │   │   ├── models/category.dart
    │   │   └── datasources/products_remote_source.dart
    │   ├── domain/
    │   │   ├── entities/product.dart
    │   │   ├── repositories/products_repository.dart
    │   │   └── usecases/get_products_usecase.dart
    │   └── presentation/
    │       ├── providers/products_provider.dart
    │       ├── providers/category_provider.dart
    │       ├── providers/search_provider.dart
    │       ├── screens/home_screen.dart
    │       ├── screens/search_screen.dart
    │       └── widgets/product_grid.dart
    ├── product_detail/
    │   ├── presentation/
    │   │   ├── providers/product_detail_provider.dart
    │   │   └── screens/product_detail_screen.dart
    ├── cart/
    │   ├── data/
    │   │   └── storage/cart_hive_dao.dart
    │   ├── domain/
    │   │   └── entities/cart_item.dart
    │   └── presentation/
    │       ├── providers/cart_provider.dart
    │       └── screens/cart_screen.dart
    ├── wishlist/
    │   ├── data/
    │   │   └── storage/wishlist_hive_dao.dart
    │   ├── domain/
    │   │   └── entities/wishlist_item.dart
    │   └── presentation/
    │       ├── providers/wishlist_provider.dart
    │       └── screens/wishlist_screen.dart
    ├── profile/
    │   └── presentation/
    │       ├── screens/profile_screen.dart
    │       └── providers/profile_provider.dart
    └── shell/
        └── presentation/
            └── screens/main_shell.dart   # bottom nav (Home, Wishlist, Cart, Profile)
```

---

## Phases

### Phase 0 — Foundation & Onboarding
- Add dependencies (Riverpod 3, riverpod_generator, Dio, GoRouter, Hive, shimmer, google_fonts)
- Clean out placeholder `main.dart` / `views/` (current SwiftShop shell + garbage onboarding)
- Set up clean-arch folder structure
- `DioClient` factory + interceptors, `ApiConstants`
- Hive init + boxes registration in `main.dart`
- Design tokens: colors, text styles, light/dark theme (neutral minimal)
- GoRouter shell: onboarding → login → main shell, with guard redirects stubbed
- Rebuild Onboarding (3 pages: Discover / Fast Delivery / Secure Payment)

**Deliverable:** App runs with themed UI, routes to onboarding, Hive initialized.

### Phase 1 — Auth
- `AuthUser` entity, `AuthResponse` model, `AuthRemoteDataSource`, `AuthRepository`, `LoginUsecase`
- Login screen (username/password) calling DummyJSON `/auth/login`
- Token saved in Hive (auth box)
- `authProvider` (`AsyncNotifier`) + router redirect: unauthenticated → `/login`
- Form validation, loading/error/success states

**Deliverable:** Login works, token persisted, guarded routes active.

### Phase 2 — Catalog (products)
- `Product`, `ProductsResponse`, `Category` models + `ProductsRepository` + `GetProductsUsecase`
- Product grid (2-col) with shimmer skeleton, error + retry, empty state
- Category chips from `/products/categories`
- Search (debounced) via `/products/search`
- Sort/filter (price asc/desc, rating)
- Infinite scroll pagination (`limit`/`skip`)
- Rebuild `ProductCard` (image, title, price, rating, wishlist/cart quick actions)

**Deliverable:** Browsable, searchable, filterable catalog.

### Phase 3 — Product Detail
- Detail screen: swipeable image gallery, title, price, rating, description, stock
- Sticky bottom "Add to Cart" bar
- Wishlist toggle
- Hero animation from grid → detail

**Deliverable:** Full product detail flow.

### Phase 4 — Cart (Hive-persisted)
- `CartItem` entity + Hive `TypeAdapter` + `CartHiveDao`
- `CartNotifier` (`Notifier`) — add/remove/quantity/totals, persisted to Hive
- Cart screen: item tiles, quantity steppers, swipe-to-delete, clear all
- Sticky summary bar, cart badge on shell nav

**Deliverable:** Fully working persisted cart.

### Phase 5 — Wishlist (Hive-persisted)
- `WishlistItem` entity + Hive adapter + `WishlistHiveDao`
- `WishlistNotifier` — toggle, persisted
- Wishlist screen + empty state + badge

**Deliverable:** Favorites flow.

### Phase 6 — Profile
- Profile screen: user info from login, dark-mode toggle, logout (clears token)
- Elegant "order history coming soon" stub

**Deliverable:** Complete user shell.

### Phase 7 — Polish, Tests & Build
- Unit tests: models (`fromJson`), repositories (mocked Dio), cart/wishlist Notifier logic
- Widget tests: ProductCard, cart tile, login form validation
- Final polish: empty/error/loading states everywhere, animations, light/dark
- README rewrite (badges, architecture diagram, how-to-run)
- `flutter build apk --release`

**Deliverable:** Portfolio-ready app + release APK.

---

## Execution Rules
1. Before each phase: present that phase's task list and get confirmation.
2. After each phase: `flutter analyze` and `flutter test` must pass.
3. English-only comments and docs.
4. No emojis in code.
