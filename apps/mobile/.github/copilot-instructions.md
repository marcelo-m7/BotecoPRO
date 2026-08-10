# Copilot Instructions for BotecoPro

BotecoPro is a Flutter app to manage a bar (tables, orders, products, recipes, internal production) with local-only persistence; use this as your “mental model” to move fast in this codebase.

## Architecture in one glance
- Data lives client-side via SharedPreferences only (no backend). Models serialize to/from JSON. All keys are defined in `lib/core/services/database_service.dart` (e.g. `_productsKey`, `_ordersKey`, `_salesKey`).
- Persistence service: `DatabaseService` is a singleton (factory + private ctor). It exposes async CRUD like `getProducts`, `saveTables`, `updateOrder`, `closeOrder` and handles JSON encoding/decoding internally.
- Optional SQLite: `lib/core/providers/database_provider.dart` mirrors the same CRUD but isn’t wired by default. Use it only if migrating to large data/complex queries. Init example is documented in the file comments.
- Domain models live in `lib/core/models/data_models.dart` and use UUIDs, `copyWith()`, and enums (lowercase names). Core entities: Supplier, Product, TableModel, Order/OrderItem, Recipe/RecipeIngredient, InternalProduction/ProductionIngredient, Sale.
- UI uses stateful pages that load data in `initState()` → `_loadData()` → `setState()` with mounted checks. Shared widgets, formatting helpers, and bottom navigation are in `lib/presentation/widgets/`.

## Key flows and invariants (what to keep consistent)
- Seeding: `HomePage._loadData()` calls `DatabaseService.initializeData()` on first run to seed demo data (tables, products, suppliers, recipes, productions).
- Orders ↔ Tables: creating an order sets the table to `TableStatus.occupied` and links `currentOrderId` (`DatabaseService.addOrder`). Closing an order (`closeOrder`) marks it closed, decrements product stock for each `OrderItem`, frees the table, and appends a `Sale` record.
- Formatting/locale: All BR formatting via `intl` with `'pt_BR'`. Use `formatCurrency`, `formatDateTime`, `formatDate` from `presentation/widgets/shared_widgets.dart`.
- Navigation: Main tabs come from the `NavigationTab` enum in `widgets/bottom_navigation.dart`. On wide screens (`main.dart`) the layout switches to `NavigationRail` automatically.

## How to extend safely (examples from this repo)
- Add a new entity:
  1) Define model + enum in `core/models/data_models.dart` with `toJson/fromJson/copyWith`.
  2) Add a storage key and CRUD in `core/services/database_service.dart`.
  3) Create a page in `presentation/pages/*_page.dart` and wire a tab/route if user-facing.
- Evolve order flow: Respect the coupling with tables and inventory. If you add statuses or payment logic, also update `closeOrder` side effects and the `Sale` model.
- Switch to SQLite: Replace call sites of `DatabaseService` with `DatabaseProvider()` and follow the init instructions in `core/providers/database_provider.dart`.

## Developer workflow (verified)
- Run: `flutter pub get` → `flutter run` (web, mobile, or desktop). Web is the fastest path for iteration.
- Build: `flutter build web|apk|appbundle|ios`.
- Lint/format: `dart analyze`; `dart format .`.
- Useful entry points: `lib/main.dart`, `presentation/pages/home_page.dart`, `core/services/database_service.dart`, `core/models/data_models.dart`.

## Dependencies that matter here
- SharedPreferences (2.3.x) for persistence; uuid (3.x) for IDs; intl (pt_BR) for formatting; provider (prepared but optional); flutter_animate for subtle UI; fl_chart and table_calendar are used in UI; sqlite3 + path_provider exist for the optional SQLite provider.

## Tips for agents
- Prefer `DatabaseService` for data mutations to keep table/order/stock invariants intact.
- Use the shared formatting helpers and theme colors instead of hardcoding styles.
- Follow the page pattern: StatefulWidget → `_loadData()` → `setState()` with mounted guard.
- When adding navigation, update the `NavigationTab`/bottom navigation or use `Navigator.push` like in `suppliers_page.dart`.

If any section above is unclear (e.g., when to use SQLite vs SharedPreferences, or how `closeOrder` should evolve), tell us what you’re missing and we’ll refine this guide.
