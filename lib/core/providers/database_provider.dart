// lib/core/providers/database_provider.dart
//
/// DatabaseProvider - Implementação Futura com SQLite
///
/// IMPLEMENTAÇÃO ATUAL:
/// - Provider preparado para SQLite usando package `sqlite3`
/// - Armazena entidades como JSON em tabelas SQLite
/// - Espelha padrões CRUD do DatabaseService atual
/// - Singleton pattern para acesso global
///
/// QUANDO USAR:
/// - Para apps com grandes volumes de dados
/// - Quando precisar de queries complexas
/// - Para melhor performance que SharedPreferences
/// - Para relacionamentos entre tabelas
///
/// MIGRAÇÃO DO DatabaseService (SharedPreferences → SQLite):
///
/// 1. Adicionar dependências no pubspec.yaml:
/// ```yaml
/// dependencies:
///   sqlite3: ^2.1.0
///   path_provider: ^2.1.0
/// ```
///
/// 2. Inicializar DatabaseProvider no main.dart:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await DatabaseProvider().init();
///   runApp(const MyApp());
/// }
/// ```
///
/// 3. Substituir chamadas de DatabaseService por DatabaseProvider
///
/// 4. Opcional: Criar um Provider com ChangeNotifier para reatividade
///
/// VANTAGENS SOBRE SharedPreferences:
/// - ✅ Melhor performance para grandes volumes
/// - ✅ Queries SQL complexas
/// - ✅ Índices e otimizações
/// - ✅ Transações atômicas
/// - ✅ Relacionamentos entre tabelas
///
/// OBSERVAÇÃO:
/// - Atualmente o app usa DatabaseService com SharedPreferences
/// - Esta implementação está pronta mas não em uso
/// - Migre quando necessário maior escalabilidade
///
/// TODO: IMPLEMENTAÇÕES FUTURAS
/// - [ ] Adicionar migrations para alterações de schema
/// - [ ] Implementar backup/restore
/// - [ ] Adicionar índices para queries frequentes
/// - [ ] Criar views para relatórios complexos
/// - [ ] Implementar soft delete (não deletar, marcar como inativo)
///
library;

// Future SQLite provider implementation using `sqlite3`.
// This provider stores each entity as a JSON blob in a simple table per entity.
// It mirrors the async CRUD patterns used by the SharedPreferences DatabaseService.
// Models are expected to implement `toJson()` and `fromJson(Map<String, dynamic>)`
// and have an `id` string field (UUID).
//
// Note: This implementation uses the `sqlite3` package and `path_provider` to
// place the database file on disk. For large blocking operations consider moving
// DB access to an isolate.

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../models/data_models.dart';

class DatabaseProvider {
    // Singleton
    DatabaseProvider._internal();
    static final DatabaseProvider instance = DatabaseProvider._internal();
    factory DatabaseProvider() => instance;

    Database? _db;
    String _dbFileName = 'botecopro.sqlite';

    Future<void> init({String? dbFileName}) async {
        if (dbFileName != null) _dbFileName = dbFileName;
        if (_db != null) return;

        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/$_dbFileName';

        // Ensure directory exists
        await Directory(dir.path).create(recursive: true);

        // Open DB (synchronous under the hood, but wrapped in Future for API consistency)
        _db = sqlite3.open(path);

        _createTablesIfNotExists();
    }

    void _createTablesIfNotExists() {
        if (_db == null) return;
        // Simple schema: id TEXT PRIMARY KEY, data TEXT (JSON), updated_at TEXT
        _db!.execute('''
            CREATE TABLE IF NOT EXISTS suppliers (
                id TEXT PRIMARY KEY,
                data TEXT NOT NULL,
                updated_at TEXT
            );
        ''');

        _db!.execute('''
            CREATE TABLE IF NOT EXISTS products (
                id TEXT PRIMARY KEY,
                data TEXT NOT NULL,
                updated_at TEXT
            );
        ''');

        _db!.execute('''
            CREATE TABLE IF NOT EXISTS tables_model (
                id TEXT PRIMARY KEY,
                data TEXT NOT NULL,
                updated_at TEXT
            );
        ''');

        _db!.execute('''
            CREATE TABLE IF NOT EXISTS orders (
                id TEXT PRIMARY KEY,
                data TEXT NOT NULL,
                updated_at TEXT
            );
        ''');

        _db!.execute('''
            CREATE TABLE IF NOT EXISTS order_items (
                id TEXT PRIMARY KEY,
                data TEXT NOT NULL,
                updated_at TEXT
            );
        ''');

        _db!.execute('''
            CREATE TABLE IF NOT EXISTS recipes (
                id TEXT PRIMARY KEY,
                data TEXT NOT NULL,
                updated_at TEXT
            );
        ''');

        _db!.execute('''
            CREATE TABLE IF NOT EXISTS productions (
                id TEXT PRIMARY KEY,
                data TEXT NOT NULL,
                updated_at TEXT
            );
        ''');
    }

    Future<void> close() async {
        _db?.dispose();
        _db = null;
    }

    // Generic helpers

    Future<void> _upsert(String table, String id, Map<String, dynamic> json) async {
        if (_db == null) throw StateError('Database not initialized');
        final encoded = jsonEncode(json);
        final now = DateTime.now().toIso8601String();
        // Use INSERT OR REPLACE for upsert
        _db!.execute(
            'INSERT OR REPLACE INTO $table (id, data, updated_at) VALUES (?, ?, ?);',
            [id, encoded, now],
        );
    }

    Future<void> _delete(String table, String id) async {
        if (_db == null) throw StateError('Database not initialized');
        _db!.execute('DELETE FROM $table WHERE id = ?;', [id]);
    }

    Future<List<Map<String, dynamic>>> _getAll(String table) async {
        if (_db == null) throw StateError('Database not initialized');
        final result = _db!.select('SELECT data FROM $table;');
        return result.map((row) {
            final raw = row['data'] as String;
            return jsonDecode(raw) as Map<String, dynamic>;
        }).toList();
    }

    // Suppliers
    Future<List<Supplier>> getSuppliers() async {
        final rows = await _getAll('suppliers');
        return rows.map((m) => Supplier.fromJson(m)).toList();
    }

    Future<void> saveSupplier(Supplier supplier) async {
        await _upsert('suppliers', supplier.id, supplier.toJson());
    }

    Future<void> deleteSupplier(String id) async {
        await _delete('suppliers', id);
    }

    // Products
    Future<List<Product>> getProducts() async {
        final rows = await _getAll('products');
        return rows.map((m) => Product.fromJson(m)).toList();
    }

    Future<void> saveProduct(Product product) async {
        await _upsert('products', product.id, product.toJson());
    }

    Future<void> deleteProduct(String id) async {
        await _delete('products', id);
    }

    // Tables (TableModel)
    Future<List<TableModel>> getTables() async {
        final rows = await _getAll('tables_model');
        return rows.map((m) => TableModel.fromJson(m)).toList();
    }

    Future<void> saveTable(TableModel tableModel) async {
        await _upsert('tables_model', tableModel.id, tableModel.toJson());
    }

    Future<void> deleteTable(String id) async {
        await _delete('tables_model', id);
    }

    // Orders
    Future<List<Order>> getOrders() async {
        final rows = await _getAll('orders');
        return rows.map((m) => Order.fromJson(m)).toList();
    }

    Future<void> saveOrder(Order order) async {
        await _upsert('orders', order.id, order.toJson());
    }

    Future<void> deleteOrder(String id) async {
        await _delete('orders', id);
    }

    // OrderItems
    Future<List<OrderItem>> getOrderItems() async {
        final rows = await _getAll('order_items');
        return rows.map((m) => OrderItem.fromJson(m)).toList();
    }

    Future<void> saveOrderItem(OrderItem item) async {
        await _upsert('order_items', item.id, item.toJson());
    }

    Future<void> deleteOrderItem(String id) async {
        await _delete('order_items', id);
    }

    // Recipes
    Future<List<Recipe>> getRecipes() async {
        final rows = await _getAll('recipes');
        return rows.map((m) => Recipe.fromJson(m)).toList();
    }

    Future<void> saveRecipe(Recipe recipe) async {
        await _upsert('recipes', recipe.id, recipe.toJson());
    }

    Future<void> deleteRecipe(String id) async {
        await _delete('recipes', id);
    }

    // InternalProduction
    Future<List<InternalProduction>> getProductions() async {
        final rows = await _getAll('productions');
        return rows.map((m) => InternalProduction.fromJson(m)).toList();
    }

    Future<void> saveProduction(InternalProduction production) async {
        await _upsert('productions', production.id, production.toJson());
    }

    Future<void> deleteProduction(String id) async {
        await _delete('productions', id);
    }

    // Utility: clear all tables (useful for testing/migrations)
    Future<void> clearAll() async {
        if (_db == null) throw StateError('Database not initialized');
        _db!.execute('DELETE FROM suppliers;');
        _db!.execute('DELETE FROM products;');
        _db!.execute('DELETE FROM tables_model;');
        _db!.execute('DELETE FROM orders;');
        _db!.execute('DELETE FROM order_items;');
        _db!.execute('DELETE FROM recipes;');
        _db!.execute('DELETE FROM productions;');
    }
}