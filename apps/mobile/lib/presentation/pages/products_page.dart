import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../core/services/database_service.dart';
import '../widgets/shared_widgets.dart';
import '../../core/models/data_models.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final DatabaseService _databaseService = DatabaseService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<Supplier> _suppliers = [];
  bool _isLoading = true;
  ProductCategory? _selectedCategory;
  StreamSubscription<String>? _dbSub;
  
  @override
  void initState() {
    super.initState();
    _loadData();
    _dbSub = _databaseService.changes.listen((_) {
      if (mounted) _loadData();
    });
  }

  @override
  void dispose() {
    _dbSub?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final products = await _databaseService.getProducts();
    final suppliers = await _databaseService.getSuppliers();

    if (mounted) {
      setState(() {
        _products = products;
        _filteredProducts = _applyFilter(products, _selectedCategory);
        _suppliers = suppliers;
        _isLoading = false;
      });
    }
  }

  List<Product> _applyFilter(List<Product> products, ProductCategory? category) {
    if (category == null) {
      return products;
    }
    return products.where((p) => p.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Produtos'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: Column(
                children: [
                  _buildCategoryFilter(),
                  _buildProductsList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProductDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Novo Produto'),
      ).animate().scale(delay: const Duration(milliseconds: 300)),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Filtrar por categoria:',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          CategoryFilter(
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
                _filteredProducts = _applyFilter(_products, category);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    return Expanded(
      child: _filteredProducts.isEmpty
          ? Center(
              child: EmptyStateCard(
                message: _selectedCategory == null
                    ? 'Nenhum produto cadastrado'
                    : 'Nenhum produto encontrado nesta categoria',
                icon: Icons.inventory_2,
                actionText: 'Adicionar Produto',
                onAction: _showAddProductDialog,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return _buildProductCard(product, index);
              },
            ),
    );
  }

  Widget _buildProductCard(Product product, int index) {
    // Encontrar o fornecedor (se existir)
    final supplier = product.supplierId != null
        ? _suppliers.firstWhere(
            (s) => s.id == product.supplierId,
            orElse: () => Supplier(name: 'Desconhecido', contact: ''),
          )
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: getProductCategoryColor(product.category).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    getProductCategoryIcon(product.category),
                    color: getProductCategoryColor(product.category),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.description,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preço',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        formatCurrency(product.price),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Unidade',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        product.unit,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Estoque',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        '${product.stockQuantity}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: product.stockQuantity <= 10 ? Colors.red : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (supplier != null) ...[  
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.local_shipping,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Fornecedor: ${supplier.name}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showStockAdjustmentDialog(product),
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: const Text('Ajustar Estoque'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showEditProductDialog(product),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Editar'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animateCard(index);
  }



  void _showAddProductDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController stockController = TextEditingController(text: '0');
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController unitController = TextEditingController(text: 'unidade');
    
    ProductCategory selectedCategory = ProductCategory.drink;
    String? selectedSupplierId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Adicionar Novo Produto'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Produto*',
                      hintText: 'Ex: Chopp, Caipirinha...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ProductCategory>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Categoria*',
                    ),
                    items: buildProductCategoryDropdownItems(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedCategory = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Preço (R\$)*',
                      hintText: 'Ex: 10.50',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: stockController,
                          decoration: const InputDecoration(
                            labelText: 'Estoque Inicial',
                            hintText: 'Ex: 100',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: unitController,
                          decoration: const InputDecoration(
                            labelText: 'Unidade',
                            hintText: 'Ex: ml, kg, unidade',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      hintText: 'Ex: Chopp artesanal 300ml',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String?>(
                    initialValue: selectedSupplierId,
                    decoration: const InputDecoration(
                      labelText: 'Fornecedor (opcional)',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Selecione um fornecedor'),
                      ),
                      ..._suppliers.map((supplier) => DropdownMenuItem(
                            value: supplier.id,
                            child: Text(supplier.name),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedSupplierId = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final priceText = priceController.text.trim();
                  final stockText = stockController.text.trim();
                  final description = descriptionController.text.trim();
                  final unit = unitController.text.trim();
                  
                  if (!validateRequiredField(context, name, 'Nome do produto')) {
                    return;
                  }
                  
                  final price = validateAndParsePrice(context, priceText);
                  if (price == null) {
                    return;
                  }
                  
                  final stock = int.tryParse(stockText) ?? 0;
                  
                  final product = Product(
                    name: name,
                    category: selectedCategory,
                    price: price,
                    stockQuantity: stock,
                    supplierId: selectedSupplierId,
                    description: description,
                    unit: unit.isEmpty ? 'unidade' : unit,
                  );
                  
                  await _databaseService.addProduct(product);
                  if (mounted) {
                    Navigator.pop(context);
                    _loadData();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  'Adicionar',
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditProductDialog(Product product) {
    final TextEditingController nameController = TextEditingController(text: product.name);
    final TextEditingController priceController = TextEditingController(text: product.price.toString());
    final TextEditingController descriptionController = TextEditingController(text: product.description);
    final TextEditingController unitController = TextEditingController(text: product.unit);
    
    var selectedCategory = product.category;
    var selectedSupplierId = product.supplierId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Editar Produto'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Produto*',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ProductCategory>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Categoria*',
                    ),
                    items: buildProductCategoryDropdownItems(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedCategory = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Preço (R\$)*',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unidade',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String?>(
                    initialValue: selectedSupplierId,
                    decoration: const InputDecoration(
                      labelText: 'Fornecedor (opcional)',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Selecione um fornecedor'),
                      ),
                      ..._suppliers.map((supplier) => DropdownMenuItem(
                            value: supplier.id,
                            child: Text(supplier.name),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedSupplierId = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final priceText = priceController.text.trim();
                  final description = descriptionController.text.trim();
                  final unit = unitController.text.trim();
                  
                  if (!validateRequiredField(context, name, 'Nome do produto')) {
                    return;
                  }
                  
                  final price = validateAndParsePrice(context, priceText);
                  if (price == null) {
                    return;
                  }
                  
                  final updatedProduct = product.copyWith(
                    name: name,
                    category: selectedCategory,
                    price: price,
                    supplierId: selectedSupplierId,
                    description: description,
                    unit: unit.isEmpty ? 'unidade' : unit,
                  );
                  
                  await _databaseService.updateProduct(updatedProduct);
                  if (mounted) {
                    Navigator.pop(context);
                    _loadData();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  'Salvar',
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showStockAdjustmentDialog(Product product) {
    final int currentStock = product.stockQuantity;
    int adjustment = 0;
    bool isAddition = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Ajustar Estoque: ${product.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Estoque atual:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '$currentStock ${product.unit}',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Adicionar'),
                        value: true,
                        groupValue: isAddition,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              isAddition = value;
                            });
                          }
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Remover'),
                        value: false,
                        groupValue: isAddition,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              isAddition = value;
                            });
                          }
                        },
                        activeColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Quantidade a ${isAddition ? 'adicionar' : 'remover'}',
                    suffixText: product.unit,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    adjustment = int.tryParse(value) ?? 0;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Novo estoque:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${isAddition ? currentStock + adjustment : currentStock - adjustment} ${product.unit}',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (adjustment <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Informe uma quantidade válida')),
                    );
                    return;
                  }
                  
                  final newQuantity = isAddition 
                      ? currentStock + adjustment 
                      : currentStock - adjustment;
                  
                  if (newQuantity < 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('O estoque não pode ficar negativo')),
                    );
                    return;
                  }
                  
                  await _databaseService.updateProductStock(product.id, newQuantity);
                  if (mounted) {
                    Navigator.pop(context);
                    _loadData();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  'Confirmar',
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}