# 🤖 AGENTS.md - AI Agent Guidelines for BotecoPro

## 🎯 Purpose

This document provides comprehensive guidelines for AI agents working on the BotecoPro Flutter web application. It covers architecture understanding, development workflows, coding standards, and collaboration protocols.

## 🏗️ System Architecture Overview

### Core Components

**Data Layer:**
- `DatabaseService`: Singleton service with SharedPreferences persistence
- Models: `Supplier`, `Product`, `TableModel`, `Order`, `Recipe`, `InternalProduction`, `Sale`
- Storage: Client-side localStorage with JSON serialization

**UI Layer:**
- `MaterialApp` with responsive navigation
- `IndexedStack` for tab-based navigation
- Reactive UI updates via `StreamSubscription`

**Business Logic:**
- CRUD operations through `DatabaseService`
- Order lifecycle: Create → Prepare → Close (with inventory updates)
- Table status management: `free` → `occupied` → `free`

### Key Patterns

**Singleton Pattern:**
```dart
class DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();
}
```

**Reactive Streams:**
```dart
final _changesController = StreamController<void>.broadcast();
Stream<void> get changes => _changesController.stream;
```

**Factory Constructor:**
```dart
class Product {
  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    // ...
  );
}
```

## ⚡ Development Commands

### Environment Setup
```bash
# WSL (Recommended for Windows)
wsl bash -lc "cd /mnt/c/Users/$(whoami)/Desktop/Monynha\ Sotwares/Codebase/BotecoPro && flutter pub get"

# Direct (Windows/PowerShell)
cd "C:\Users\marce\Desktop\Monynha Sotwares\Codebase\BotecoPro"
flutter pub get
```

### Running the Application
```bash
# Web development
flutter run -d web

# Build for production
flutter build web --release

# Analyze code
flutter analyze

# Format code
dart format .
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test
flutter test test/models_test.dart

# Test web build locally
cd build/web && python3 -m http.server 8080
```

## 📋 Coding Standards

### File Organization
```
lib/
├── core/
│   ├── models/data_models.dart    # All entity models
│   ├── services/database_service.dart  # Data persistence
│   └── utils/                    # Helper functions
├── presentation/
│   ├── pages/                    # Screen widgets
│   └── widgets/                  # Reusable components
├── main.dart                     # App entry point
└── theme.dart                    # UI theme
```

### Naming Conventions
- **Classes**: PascalCase (`Product`, `DatabaseService`)
- **Methods**: camelCase (`getProducts()`, `saveOrder()`)
- **Variables**: camelCase (`productName`, `orderItems`)
- **Files**: snake_case (`data_models.dart`, `database_service.dart`)
- **Enums**: PascalCase with lowercase values (`TableStatus.free`)

### Code Patterns

**Model Classes:**
```dart
class Product {
  final String id;
  final String name;
  final double price;
  final int stock;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
    stock: json['stock'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'stock': stock,
  };

  Product copyWith({
    String? id,
    String? name,
    double? price,
    int? stock,
  }) => Product(
    id: id ?? this.id,
    name: name ?? this.name,
    price: price ?? this.price,
    stock: stock ?? this.stock,
  );
}
```

**Service Methods:**
```dart
class DatabaseService {
  Future<List<Product>> getProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getString(_productsKey) ?? '[]';
      final productsData = jsonDecode(productsJson) as List;
      return productsData.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      _logger.warning('Failed to load products: $e');
      return [];
    }
  }
}
```

**UI Widgets:**
```dart
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> _products = [];
  StreamSubscription<void>? _subscription;

  @override
  void initState() {
    super.initState();
    _loadData();
    _subscription = DatabaseService.instance.changes.listen((_) {
      if (mounted) _loadData();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final products = await DatabaseService.instance.getProducts();
    if (mounted) {
      setState(() => _products = products);
    }
  }
}
```

## 🔄 Data Flow Patterns

### Order Creation Flow
1. User selects table → `TableStatus.occupied`
2. User adds items → Create `Order` with `OrderItem`s
3. User closes order → Update inventory, create `Sale`, free table

### Reactive Updates
- All pages subscribe to `DatabaseService.changes`
- UI updates automatically on data changes
- Debounced notifications prevent excessive rebuilds

### Error Handling
```dart
try {
  await DatabaseService.instance.saveProduct(product);
  // Success handling
} catch (e) {
  // Error handling - show user-friendly message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed to save product: $e')),
  );
}
```

## 🧪 Testing Guidelines

### Unit Tests
```dart
void main() {
  group('Product Model', () {
    test('should create from JSON', () {
      final json = {
        'id': '1',
        'name': 'Beer',
        'price': 5.0,
        'stock': 100,
      };

      final product = Product.fromJson(json);

      expect(product.id, '1');
      expect(product.name, 'Beer');
      expect(product.price, 5.0);
      expect(product.stock, 100);
    });
  });
}
```

### Widget Tests
```dart
testWidgets('ProductsPage displays products', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ProductsPage(),
    ),
  );

  await tester.pumpAndSettle();

  expect(find.text('Products'), findsOneWidget);
  expect(find.byType(ListView), findsOneWidget);
});
```

## 🚀 Deployment Workflow

### Web Deployment
1. `flutter build web --release`
2. Test `build/web/index.html` locally
3. Deploy to Firebase Hosting or static hosting
4. Verify functionality in production

### Version Control
- Use feature branches for development
- Squash commits for clean history
- Tag releases with semantic versioning

## 🎯 AI Agent Responsibilities

### When Adding Features
1. **Understand Requirements**: Review existing patterns
2. **Follow Architecture**: Use established data flow
3. **Maintain Consistency**: Match existing code style
4. **Test Thoroughly**: Unit + widget tests
5. **Update Documentation**: Keep docs current

### When Modifying Data Models
1. **Update Model**: Add fields with `copyWith()`
2. **Update JSON**: Add `fromJson`/`toJson` fields
3. **Update Service**: Add CRUD methods if needed
4. **Update UI**: Modify forms and displays
5. **Test Changes**: Verify serialization works

### When Adding UI Components
1. **Use Existing Widgets**: Leverage `shared_widgets.dart`
2. **Follow Theme**: Use app theme colors and typography
3. **Responsive Design**: Test on different screen sizes
4. **Accessibility**: Consider screen readers and keyboard navigation

## 🔧 Troubleshooting

### Common Issues

**Data not persisting:**
- Check SharedPreferences keys are correct
- Verify JSON serialization works
- Check browser localStorage quota

**UI not updating:**
- Ensure `StreamSubscription` is properly set up
- Check `mounted` guard in `setState()`
- Verify `DatabaseService.changes` is triggered

**Build failures:**
- Run `flutter clean` then `flutter pub get`
- Check for deprecated APIs
- Verify Flutter version compatibility

### Debug Commands
```bash
# Check Flutter version
flutter --version

# Clean and rebuild
flutter clean && flutter pub get && flutter build web

# Analyze code
flutter analyze

# Run with verbose logging
flutter run -d web --verbose
```

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design Guidelines](https://material.io/design)
- [SharedPreferences Package](https://pub.dev/packages/shared_preferences)

---

**Last Updated**: November 2, 2025
**Version**: 1.1.0
**For AI Agents**: Follow these guidelines for consistent, maintainable code</content>
<parameter name="filePath">c:\Users\marce\Desktop\Monynha Sotwares\Codebase\BotecoPro\AGENTS.md