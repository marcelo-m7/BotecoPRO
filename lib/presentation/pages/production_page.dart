import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../core/services/database_service.dart';
import '../widgets/shared_widgets.dart';
import '../../core/models/data_models.dart';

class ProductionPage extends StatefulWidget {
  const ProductionPage({super.key});

  @override
  State<ProductionPage> createState() => _ProductionPageState();
}

class _ProductionPageState extends State<ProductionPage> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = true;
  List<InternalProduction> _productions = [];
  List<Product> _products = [];
  List<Recipe> _recipes = [];
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
    final recipes = await _databaseService.getRecipes();
    final productions = await _databaseService.getInternalProductions();

    if (mounted) {
      setState(() {
        _products = products;
        _recipes = recipes;
        _productions = productions;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Produção Caseira'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _productions.isEmpty
                  ? Center(
                      child: EmptyStateCard(
                        message: 'Nenhuma produção cadastrada',
                        icon: Icons.inventory,
                        actionText: 'Nova Produção',
                        onAction: _showAddProductionDialog,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _productions.length,
                      itemBuilder: (context, index) {
                        final production = _productions[index];
                        return _buildProductionCard(production, index);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProductionDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Nova Produção'),
      ).animate().scale(delay: const Duration(milliseconds: 300)),
    );
  }

  Widget _buildProductionCard(InternalProduction production, int index) {
    final isFinalized = production.status == ProductionStatus.finalized;
    final statusColor = isFinalized ? Colors.green : Colors.blue;
    final statusText = isFinalized ? 'Finalizada' : 'Em Andamento';
    
    // Encontrar a receita relacionada (se existir)
    final recipe = production.recipeId != null
        ? _recipes.firstWhere(
            (r) => r.id == production.recipeId,
            orElse: () => Recipe(name: 'Desconhecida', type: RecipeType.food, price: 0),
          )
        : null;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showProductionDetails(production),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.inventory,
                      color: Theme.of(context).colorScheme.tertiary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          production.name,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Criada em: ${formatDate(production.createdAt)}',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                  ),
                            ),
                          ],
                        ),
                        if (recipe != null) ...[  
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.menu_book,
                                size: 16,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Receita: ${recipe.name}',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFinalized ? Icons.check_circle : Icons.pending_actions,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
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
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Quantidade Produzida:'),
                        Text(
                          '${production.quantity} ${production.unit}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (isFinalized && production.finalizedAt != null) ...[  
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Finalizada em:'),
                          Text(
                            formatDateTime(production.finalizedAt!),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isFinalized) ...[  
                    TextButton.icon(
                      onPressed: () => _showAddIngredientDialog(production),
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Ingredientes'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showFinalizeProductionDialog(production),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Finalizar'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                    ),
                  ],
                  if (!isFinalized) const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: isFinalized ? null : () => _showEditProductionDialog(production),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Editar'),
                    style: TextButton.styleFrom(
                      foregroundColor: isFinalized ? Colors.grey : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animateCard(index);
  }

  void _showAddProductionDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController unitController = TextEditingController(text: 'unidade');
    final TextEditingController notesController = TextEditingController();
    
    String? selectedRecipeId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Nova Produção Caseira'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Produto*',
                      hintText: 'Ex: Cachaça de Abacaxi, Bolinho Caseiro...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantidade*',
                            hintText: 'Ex: 1000',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: unitController,
                          decoration: const InputDecoration(
                            labelText: 'Unidade*',
                            hintText: 'Ex: ml, un',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String?>(
                    initialValue: selectedRecipeId,
                    decoration: const InputDecoration(
                      labelText: 'Receita (opcional)',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Selecione uma receita'),
                      ),
                      ..._recipes.map((recipe) => DropdownMenuItem(
                            value: recipe.id,
                            child: Text(recipe.name),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRecipeId = value;
                        
                        // Se uma receita for selecionada, preenche o nome do produto
                        if (value != null) {
                          final recipe = _recipes.firstWhere((r) => r.id == value);
                          nameController.text = recipe.name;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Observações',
                    ),
                    maxLines: 3,
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
                  final quantityText = quantityController.text.trim();
                  final unit = unitController.text.trim();
                  final notes = notesController.text.trim();
                  
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nome do produto é obrigatório')),
                    );
                    return;
                  }
                  
                  if (quantityText.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Quantidade é obrigatória')),
                    );
                    return;
                  }
                  
                  final quantity = int.tryParse(quantityText);
                  if (quantity == null || quantity <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Quantidade inválida')),
                    );
                    return;
                  }
                  
                  if (unit.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Unidade é obrigatória')),
                    );
                    return;
                  }
                  
                  final production = InternalProduction(
                    name: name,
                    quantity: quantity,
                    unit: unit,
                    recipeId: selectedRecipeId,
                    notes: notes,
                  );
                  
                  await _databaseService.addInternalProduction(production);
                  if (mounted) {
                    Navigator.pop(context);
                    _loadData();
                    
                    // Mostrar dialog para adicionar ingredientes
                    final freshProductions = await _databaseService.getInternalProductions();
                    final addedProduction = freshProductions.firstWhere((p) => p.name == name);
                    _showAddIngredientDialog(addedProduction);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  'Criar',
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditProductionDialog(InternalProduction production) {
    final TextEditingController nameController = TextEditingController(text: production.name);
    final TextEditingController quantityController = TextEditingController(text: production.quantity.toString());
    final TextEditingController unitController = TextEditingController(text: production.unit);
    final TextEditingController notesController = TextEditingController(text: production.notes);
    
    var selectedRecipeId = production.recipeId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Editar Produção'),
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
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantidade*',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: unitController,
                          decoration: const InputDecoration(
                            labelText: 'Unidade*',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String?>(
                    initialValue: selectedRecipeId,
                    decoration: const InputDecoration(
                      labelText: 'Receita (opcional)',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Selecione uma receita'),
                      ),
                      ..._recipes.map((recipe) => DropdownMenuItem(
                            value: recipe.id,
                            child: Text(recipe.name),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRecipeId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Observações',
                    ),
                    maxLines: 3,
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
                  final quantityText = quantityController.text.trim();
                  final unit = unitController.text.trim();
                  final notes = notesController.text.trim();
                  
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nome do produto é obrigatório')),
                    );
                    return;
                  }
                  
                  if (quantityText.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Quantidade é obrigatória')),
                    );
                    return;
                  }
                  
                  final quantity = int.tryParse(quantityText);
                  if (quantity == null || quantity <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Quantidade inválida')),
                    );
                    return;
                  }
                  
                  if (unit.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Unidade é obrigatória')),
                    );
                    return;
                  }
                  
                  final updatedProduction = production.copyWith(
                    name: name,
                    quantity: quantity,
                    unit: unit,
                    recipeId: selectedRecipeId,
                    notes: notes,
                  );
                  
                  await _databaseService.updateInternalProduction(updatedProduction);
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

  void _showAddIngredientDialog(InternalProduction production) {
    String? selectedProductId;
    int quantity = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final selectedProduct = selectedProductId != null 
              ? _products.firstWhere((p) => p.id == selectedProductId)
              : null;
          
          return AlertDialog(
            title: Text('Adicionar Ingrediente: ${production.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String?>(
                  initialValue: selectedProductId,
                  decoration: const InputDecoration(
                    labelText: 'Produto*',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Selecione um produto'),
                    ),
                    ..._products.map((product) => DropdownMenuItem(
                          value: product.id,
                          child: Text(product.name),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedProductId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Quantidade:'),
                    QuantitySelector(
                      quantity: quantity,
                      onChanged: (value) {
                        setState(() {
                          quantity = value;
                        });
                      },
                      max: selectedProduct?.stockQuantity ?? 99,
                    ),
                  ],
                ),
                if (selectedProduct != null) ...[  
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Produto:',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              selectedProduct.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Unidade:',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            Text(selectedProduct.unit),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Estoque:',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              '${selectedProduct.stockQuantity} ${selectedProduct.unit}',
                              style: TextStyle(
                                color: selectedProduct.stockQuantity < quantity 
                                    ? Colors.red 
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
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
                  if (selectedProductId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Selecione um produto')),
                    );
                    return;
                  }
                  
                  final selectedProduct = _products.firstWhere((p) => p.id == selectedProductId);
                  
                  if (quantity <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Quantidade deve ser maior que zero')),
                    );
                    return;
                  }
                  
                  if (selectedProduct.stockQuantity < quantity) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Quantidade maior que o estoque disponível')),
                    );
                    return;
                  }
                  
                  final productionIngredient = ProductionIngredient(
                    productId: selectedProductId!,
                    productName: selectedProduct.name,
                    quantity: quantity,
                    unit: selectedProduct.unit,
                  );
                  
                  await _databaseService.addProductionIngredient(production.id, productionIngredient);
                  // Atualizar o estoque do produto
                  await _databaseService.updateProductStock(
                    selectedProductId!,
                    selectedProduct.stockQuantity - quantity,
                  );
                  
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

  void _showFinalizeProductionDialog(InternalProduction production) {
    // Verificar se possui ingredientes
    if (production.ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um ingrediente antes de finalizar')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Finalizar Produção',
        content: 'Ao finalizar, o produto será adicionado ao estoque. Deseja continuar?',
        confirmText: 'Finalizar',
        cancelText: 'Cancelar',
        onConfirm: () async {
          // Atualizar o status da produção
          final updatedProduction = production.copyWith(
            status: ProductionStatus.finalized,
            finalizedAt: DateTime.now(),
          );
          
          await _databaseService.updateInternalProduction(updatedProduction);
          
          // Adicionar ao estoque ou atualizar produto existente
          final existingProductIndex = _products.indexWhere((p) => p.name == production.name);
          
          if (existingProductIndex != -1) {
            // Produto já existe, atualizar estoque
            final existingProduct = _products[existingProductIndex];
            await _databaseService.updateProductStock(
              existingProduct.id,
              existingProduct.stockQuantity + production.quantity,
            );
          } else {
            // Criar novo produto
            final newProduct = Product(
              name: production.name,
              category: ProductCategory.other, // Definir categoria apropriada
              price: 0, // Preço inicial zero (definir depois)
              stockQuantity: production.quantity,
              unit: production.unit,
              description: 'Produto de produção caseira',
            );
            
            await _databaseService.addProduct(newProduct);
          }
          
          if (mounted) {
            _loadData();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Produção finalizada com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  void _showProductionDetails(InternalProduction production) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(production.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status:'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: production.status == ProductionStatus.finalized
                        ? Colors.green.withOpacity(0.2)
                        : Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: production.status == ProductionStatus.finalized
                          ? Colors.green
                          : Colors.blue,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    production.status == ProductionStatus.finalized
                        ? 'Finalizada'
                        : 'Em Andamento',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: production.status == ProductionStatus.finalized
                          ? Colors.green
                          : Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quantidade:'),
                Text(
                  '${production.quantity} ${production.unit}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Criada em:'),
                Text(
                  formatDateTime(production.createdAt),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (production.finalizedAt != null) ...[  
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Finalizada em:'),
                  Text(
                    formatDateTime(production.finalizedAt!),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
            if (production.notes.isNotEmpty) ...[  
              const SizedBox(height: 16),
              const Text(
                'Observações:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(production.notes),
            ],
            const SizedBox(height: 16),
            const Text(
              'Ingredientes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (production.ingredients.isEmpty)
              const Text('Nenhum ingrediente adicionado')
            else
              Column(
                children: production.ingredients.map((ingredient) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${ingredient.productName}:'),
                      Text(
                        '${ingredient.quantity} ${ingredient.unit}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )).toList(),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}