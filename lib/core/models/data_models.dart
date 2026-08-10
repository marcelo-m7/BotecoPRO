import 'package:uuid/uuid.dart';

// Classe para geração de IDs únicos
const uuid = Uuid();

// Enum para status de mesa
enum TableStatus { free, occupied }

// Enum para status de pedido
enum OrderStatus { pending, preparing, ready, delivered, canceled }

// Enum para método de pagamento
enum PaymentMethod { cash, credit, debit, pix }

// Enum para categoria de produto
enum ProductCategory { drink, food, other }

// Enum para tipo de receita
enum RecipeType { food, drink }

// Enum para status de produção
enum ProductionStatus { inProgress, finalized }

// Modelo de Fornecedor
class Supplier {
  final String id;
  String name;
  String contact;
  String address;
  String notes;

  Supplier({
    String? id,
    required this.name,
    required this.contact,
    this.address = '',
    this.notes = '',
  }) : id = id ?? uuid.v4();

  Supplier copyWith({
    String? name,
    String? contact,
    String? address,
    String? notes,
  }) {
    return Supplier(
      id: id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      address: address ?? this.address,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'address': address,
      'notes': notes,
    };
  }

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      name: json['name'],
      contact: json['contact'],
      address: json['address'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}

// Modelo de Produto
class Product {
  final String id;
  String name;
  ProductCategory category;
  double price;
  int stockQuantity;
  String? supplierId;
  String description;
  String unit; // ex: ml, kg, unidade

  Product({
    String? id,
    required this.name,
    required this.category,
    required this.price,
    this.stockQuantity = 0,
    this.supplierId,
    this.description = '',
    this.unit = 'unidade',
  }) : id = id ?? uuid.v4();

  Product copyWith({
    String? name,
    ProductCategory? category,
    double? price,
    int? stockQuantity,
    String? supplierId,
    String? description,
    String? unit,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      supplierId: supplierId ?? this.supplierId,
      description: description ?? this.description,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.index,
      'price': price,
      'stockQuantity': stockQuantity,
      'supplierId': supplierId,
      'description': description,
      'unit': unit,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: ProductCategory.values[json['category']],
      price: json['price'].toDouble(),
      stockQuantity: json['stockQuantity'],
      supplierId: json['supplierId'],
      description: json['description'] ?? '',
      unit: json['unit'] ?? 'unidade',
    );
  }
}

// Modelo de Mesa
class TableModel {
  final String id;
  int number;
  TableStatus status;
  int capacity;
  String? currentOrderId;

  TableModel({
    String? id,
    required this.number,
    this.status = TableStatus.free,
    this.capacity = 4,
    this.currentOrderId,
  }) : id = id ?? uuid.v4();

  TableModel copyWith({
    int? number,
    TableStatus? status,
    int? capacity,
    String? currentOrderId,
  }) {
    return TableModel(
      id: id,
      number: number ?? this.number,
      status: status ?? this.status,
      capacity: capacity ?? this.capacity,
      currentOrderId: currentOrderId ?? this.currentOrderId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'status': status.index,
      'capacity': capacity,
      'currentOrderId': currentOrderId,
    };
  }

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'],
      number: json['number'],
      status: TableStatus.values[json['status']],
      capacity: json['capacity'],
      currentOrderId: json['currentOrderId'],
    );
  }
}

// Modelo de Item de Pedido
class OrderItem {
  final String id;
  String productId;
  String productName;
  int quantity;
  double price;
  String notes;
  OrderStatus status;

  OrderItem({
    String? id,
    required this.productId,
    required this.productName,
    required this.price,
    this.quantity = 1,
    this.notes = '',
    this.status = OrderStatus.pending,
  }) : id = id ?? uuid.v4();

  double get total => price * quantity;

  OrderItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? price,
    String? notes,
    OrderStatus? status,
  }) {
    return OrderItem(
      id: id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'notes': notes,
      'status': status.index,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      notes: json['notes'] ?? '',
      status: OrderStatus.values[json['status']],
    );
  }
}

// Modelo de Pedido
class Order {
  final String id;
  String tableId;
  int tableNumber;
  DateTime createdAt;
  List<OrderItem> items;
  OrderStatus status;
  bool isClosed;

  Order({
    String? id,
    required this.tableId,
    required this.tableNumber,
    DateTime? createdAt,
    List<OrderItem>? items,
    this.status = OrderStatus.pending,
    this.isClosed = false,
  })
      : id = id ?? uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        items = items ?? [];

  double get total => items.fold(
      0, (previousValue, element) => previousValue + element.total);

  Order copyWith({
    String? tableId,
    int? tableNumber,
    DateTime? createdAt,
    List<OrderItem>? items,
    OrderStatus? status,
    bool? isClosed,
  }) {
    return Order(
      id: id,
      tableId: tableId ?? this.tableId,
      tableNumber: tableNumber ?? this.tableNumber,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      status: status ?? this.status,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableId': tableId,
      'tableNumber': tableNumber,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'status': status.index,
      'isClosed': isClosed,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      tableId: json['tableId'],
      tableNumber: json['tableNumber'],
      createdAt: DateTime.parse(json['createdAt']),
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      status: OrderStatus.values[json['status']],
      isClosed: json['isClosed'],
    );
  }
}

// Modelo de Venda
class Sale {
  final String id;
  String orderId;
  DateTime timestamp;
  PaymentMethod paymentMethod;
  double total;

  Sale({
    String? id,
    required this.orderId,
    required this.total,
    DateTime? timestamp,
    this.paymentMethod = PaymentMethod.cash,
  })
      : id = id ?? uuid.v4(),
        timestamp = timestamp ?? DateTime.now();

  Sale copyWith({
    String? orderId,
    DateTime? timestamp,
    PaymentMethod? paymentMethod,
    double? total,
  }) {
    return Sale(
      id: id,
      orderId: orderId ?? this.orderId,
      timestamp: timestamp ?? this.timestamp,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      total: total ?? this.total,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'timestamp': timestamp.toIso8601String(),
      'paymentMethod': paymentMethod.index,
      'total': total,
    };
  }

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      orderId: json['orderId'],
      timestamp: DateTime.parse(json['timestamp']),
      paymentMethod: PaymentMethod.values[json['paymentMethod']],
      total: json['total'].toDouble(),
    );
  }
}

// Modelo de Ingrediente de Receita
class RecipeIngredient {
  final String id;
  String productId;
  String productName;
  int quantity;
  String unit;

  RecipeIngredient({
    String? id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
  }) : id = id ?? uuid.v4();

  RecipeIngredient copyWith({
    String? productId,
    String? productName,
    int? quantity,
    String? unit,
  }) {
    return RecipeIngredient(
      id: id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      quantity: json['quantity'],
      unit: json['unit'],
    );
  }
}

// Modelo de Receita
class Recipe {
  final String id;
  String name;
  RecipeType type;
  double price;
  String instructions;
  List<RecipeIngredient> ingredients;

  Recipe({
    String? id,
    required this.name,
    required this.type,
    required this.price,
    this.instructions = '',
    List<RecipeIngredient>? ingredients,
  })
      : id = id ?? uuid.v4(),
        ingredients = ingredients ?? [];

  Recipe copyWith({
    String? name,
    RecipeType? type,
    double? price,
    String? instructions,
    List<RecipeIngredient>? ingredients,
  }) {
    return Recipe(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      price: price ?? this.price,
      instructions: instructions ?? this.instructions,
      ingredients: ingredients ?? this.ingredients,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'price': price,
      'instructions': instructions,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      type: RecipeType.values[json['type']],
      price: json['price'].toDouble(),
      instructions: json['instructions'] ?? '',
      ingredients: (json['ingredients'] as List?)
          ?.map((i) => RecipeIngredient.fromJson(i))
          .toList() ?? [],
    );
  }
}

// Modelo de Ingrediente de Produção
class ProductionIngredient {
  final String id;
  String productId;
  String productName;
  int quantity;
  String unit;

  ProductionIngredient({
    String? id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
  }) : id = id ?? uuid.v4();

  ProductionIngredient copyWith({
    String? productId,
    String? productName,
    int? quantity,
    String? unit,
  }) {
    return ProductionIngredient(
      id: id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory ProductionIngredient.fromJson(Map<String, dynamic> json) {
    return ProductionIngredient(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      quantity: json['quantity'],
      unit: json['unit'],
    );
  }
}

// Modelo de Produção Caseira
class InternalProduction {
  final String id;
  String name;
  int quantity;
  String unit;
  String? recipeId;
  String notes;
  DateTime createdAt;
  DateTime? finalizedAt;
  ProductionStatus status;
  List<ProductionIngredient> ingredients;

  InternalProduction({
    String? id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.recipeId,
    this.notes = '',
    DateTime? createdAt,
    this.finalizedAt,
    this.status = ProductionStatus.inProgress,
    List<ProductionIngredient>? ingredients,
  })
      : id = id ?? uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        ingredients = ingredients ?? [];

  InternalProduction copyWith({
    String? name,
    int? quantity,
    String? unit,
    String? recipeId,
    String? notes,
    DateTime? createdAt,
    DateTime? finalizedAt,
    ProductionStatus? status,
    List<ProductionIngredient>? ingredients,
  }) {
    return InternalProduction(
      id: id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      recipeId: recipeId ?? this.recipeId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      finalizedAt: finalizedAt ?? this.finalizedAt,
      status: status ?? this.status,
      ingredients: ingredients ?? this.ingredients,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'recipeId': recipeId,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'finalizedAt': finalizedAt?.toIso8601String(),
      'status': status.index,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
    };
  }

  factory InternalProduction.fromJson(Map<String, dynamic> json) {
    return InternalProduction(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      unit: json['unit'],
      recipeId: json['recipeId'],
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      finalizedAt: json['finalizedAt'] != null 
          ? DateTime.parse(json['finalizedAt']) 
          : null,
      status: ProductionStatus.values[json['status']],
      ingredients: (json['ingredients'] as List?)
          ?.map((i) => ProductionIngredient.fromJson(i))
          .toList() ?? [],
    );
  }
}