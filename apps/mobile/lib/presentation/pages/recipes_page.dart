import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../core/services/database_service.dart';
import '../widgets/shared_widgets.dart';
import '../../core/models/data_models.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = true;
  List<Recipe> _recipes = [];
  List<Product> _products = [];
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

    if (mounted) {
      setState(() {
        _products = products;
        _recipes = recipes;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Receitas'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _recipes.isEmpty
                  ? Center(
                      child: EmptyStateCard(
                        message: 'Nenhuma receita cadastrada',
                        icon: Icons.menu_book,
                        actionText: 'Criar Receita',
                        onAction: _showAddRecipeDialog,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _recipes[index];
                        return _buildRecipeCard(recipe, index);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRecipeDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Nova Receita'),
      ).animate().scale(delay: const Duration(milliseconds: 300)),
    );
  }

  Widget _buildRecipeCard(Recipe recipe, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showRecipeDetails(recipe),
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
                      color: Theme.of(context).colorScheme.secondary.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      getRecipeTypeIcon(recipe.type),
                      color: Theme.of(context).colorScheme.secondary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.category,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              getRecipeTypeLabel(recipe.type),
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withAlpha(204),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatCurrency(recipe.price),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${recipe.ingredients.length} ingredientes',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (recipe.instructions.isNotEmpty) ...[  
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withAlpha(128),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.description,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          recipe.instructions,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withAlpha(204),
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showAddIngredientDialog(recipe),
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('Ingredientes'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showEditRecipeDialog(recipe),
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
      ),
    ).animateCard(index);
  }

  void _showAddRecipeDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController instructionsController = TextEditingController();
    
    RecipeType selectedType = RecipeType.food;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Adicionar Nova Receita'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Receita*',
                      hintText: 'Ex: Caipirinha, Batata Frita...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<RecipeType>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo*',
                    ),
                    items: buildRecipeTypeDropdownItems(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Preço (R\$)*',
                      hintText: 'Ex: 18.50',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: instructionsController,
                    decoration: const InputDecoration(
                      labelText: 'Modo de Preparo',
                      hintText: 'Ex: Misture todos os ingredientes...',
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
                  final priceText = priceController.text.trim();
                  final instructions = instructionsController.text.trim();
                  
                  if (!validateRequiredField(context, name, 'Nome da receita')) {
                    return;
                  }
                  
                  final price = validateAndParsePrice(context, priceText);
                  if (price == null) {
                    return;
                  }
                  
                  final recipe = Recipe(
                    name: name,
                    type: selectedType,
                    price: price,
                    instructions: instructions,
                  );
                  
                  await _databaseService.addRecipe(recipe);
                  if (mounted) {
                    Navigator.pop(context);
                    _loadData();
                    
                    // Mostrar dialog para adicionar ingredientes
                    _showAddIngredientDialog(recipe);
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

  void _showEditRecipeDialog(Recipe recipe) {
    final TextEditingController nameController = TextEditingController(text: recipe.name);
    final TextEditingController priceController = TextEditingController(text: recipe.price.toString());
    final TextEditingController instructionsController = TextEditingController(text: recipe.instructions);
    
    var selectedType = recipe.type;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Editar Receita'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Receita*',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<RecipeType>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo*',
                    ),
                    items: buildRecipeTypeDropdownItems(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedType = value;
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
                    controller: instructionsController,
                    decoration: const InputDecoration(
                      labelText: 'Modo de Preparo',
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
                  final priceText = priceController.text.trim();
                  final instructions = instructionsController.text.trim();
                  
                  if (!validateRequiredField(context, name, 'Nome da receita')) {
                    return;
                  }
                  
                  final price = validateAndParsePrice(context, priceText);
                  if (price == null) {
                    return;
                  }
                  
                  final updatedRecipe = recipe.copyWith(
                    name: name,
                    type: selectedType,
                    price: price,
                    instructions: instructions,
                  );
                  
                  await _databaseService.updateRecipe(updatedRecipe);
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

  void _showAddIngredientDialog(Recipe recipe) {
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
            title: Text('Adicionar Ingrediente: ${recipe.name}'),
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
                        color: Theme.of(context).colorScheme.outline.withAlpha(128),
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
                                color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
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
                                color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
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
                                color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
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
                  
                  final recipeIngredient = RecipeIngredient(
                    productId: selectedProductId!,
                    productName: selectedProduct.name,
                    quantity: quantity,
                    unit: selectedProduct.unit,
                  );
                  
                  await _databaseService.addRecipeIngredient(recipe.id, recipeIngredient);
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

  void _showRecipeDetails(Recipe recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(recipe.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  getRecipeTypeIcon(recipe.type),
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  getRecipeTypeLabel(recipe.type),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  formatCurrency(recipe.price),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recipe.instructions.isNotEmpty) ...[  
              const Text(
                'Modo de Preparo:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(recipe.instructions),
              const SizedBox(height: 16),
            ],
            const Text(
              'Ingredientes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (recipe.ingredients.isEmpty)
              const Text('Nenhum ingrediente adicionado')
            else
              Column(
                children: recipe.ingredients.map((ingredient) => Padding(
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