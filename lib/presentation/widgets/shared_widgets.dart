import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/models/data_models.dart';
import 'package:intl/intl.dart';

// Formata valor como moeda brasileira
String formatCurrency(double value) {
  final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  return formatter.format(value);
}

// Formata data e hora no padrão brasileiro
String formatDateTime(DateTime dateTime) {
  return DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(dateTime);
}

// Formata apenas a data no padrão brasileiro
String formatDate(DateTime dateTime) {
  return DateFormat('dd/MM/yyyy', 'pt_BR').format(dateTime);
}

// Parse de preço com tratamento de vírgula
double? parsePrice(String priceText) {
  return double.tryParse(priceText.replaceAll(',', '.'));
}

// Validação de campo obrigatório com mensagem de erro
bool validateRequiredField(BuildContext context, String value, String fieldName) {
  if (value.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$fieldName é obrigatório')),
    );
    return false;
  }
  return true;
}

// Validação de preço com retorno do valor parseado
double? validateAndParsePrice(BuildContext context, String priceText) {
  if (priceText.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preço é obrigatório')),
    );
    return null;
  }
  
  final price = parsePrice(priceText);
  if (price == null || price <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preço inválido')),
    );
    return null;
  }
  return price;
}

// Retorna a cor para uma categoria de produto
Color getProductCategoryColor(ProductCategory category) {
  switch (category) {
    case ProductCategory.drink:
      return Colors.blue;
    case ProductCategory.food:
      return Colors.orange;
    case ProductCategory.other:
      return Colors.purple;
  }
}

// Retorna o ícone para uma categoria de produto
IconData getProductCategoryIcon(ProductCategory category) {
  switch (category) {
    case ProductCategory.drink:
      return Icons.local_bar;
    case ProductCategory.food:
      return Icons.restaurant;
    case ProductCategory.other:
      return Icons.category;
  }
}

// Retorna o label para uma categoria de produto
String getProductCategoryLabel(ProductCategory category) {
  switch (category) {
    case ProductCategory.drink:
      return 'Bebida';
    case ProductCategory.food:
      return 'Comida';
    case ProductCategory.other:
      return 'Outro';
  }
}

// Retorna o ícone para um tipo de receita
IconData getRecipeTypeIcon(RecipeType type) {
  return type == RecipeType.food ? Icons.restaurant : Icons.local_bar;
}

// Retorna o label para um tipo de receita
String getRecipeTypeLabel(RecipeType type) {
  return type == RecipeType.food ? 'Comida' : 'Bebida';
}

// Constrói itens de dropdown para ProductCategory
List<DropdownMenuItem<ProductCategory>> buildProductCategoryDropdownItems() {
  return ProductCategory.values.map((category) {
    return DropdownMenuItem(
      value: category,
      child: Row(
        children: [
          Icon(getProductCategoryIcon(category), size: 20),
          const SizedBox(width: 8),
          Text(getProductCategoryLabel(category)),
        ],
      ),
    );
  }).toList();
}

// Constrói itens de dropdown para RecipeType
List<DropdownMenuItem<RecipeType>> buildRecipeTypeDropdownItems() {
  return [
    DropdownMenuItem(
      value: RecipeType.food,
      child: Row(
        children: [
          Icon(getRecipeTypeIcon(RecipeType.food), size: 20),
          const SizedBox(width: 8),
          Text(getRecipeTypeLabel(RecipeType.food)),
        ],
      ),
    ),
    DropdownMenuItem(
      value: RecipeType.drink,
      child: Row(
        children: [
          Icon(getRecipeTypeIcon(RecipeType.drink), size: 20),
          const SizedBox(width: 8),
          Text(getRecipeTypeLabel(RecipeType.drink)),
        ],
      ),
    ),
  ];
}

// Calcula o delay de animação para itens em lista
Duration getAnimationDelay(int index, {int milliseconds = 50}) {
  return Duration(milliseconds: milliseconds * index);
}

// Extension para adicionar animação de card padrão
extension CardAnimationExtension on Widget {
  Widget animateCard(int index) {
    return animate(delay: getAnimationDelay(index))
        .fadeIn(duration: const Duration(milliseconds: 300))
        .moveY(begin: 20, duration: const Duration(milliseconds: 300));
  }
}

// AppBar customizada para o app
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Card de Menu para a Homepage
class MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;

  const MenuCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: backgroundColor != null
                  ? [backgroundColor!, backgroundColor!.withOpacity(0.7)]
                  : [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .scale(delay: const Duration(milliseconds: 100));
  }
}

// Card de status (utilizado na homepage)
class StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const StatusCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color ?? Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color ?? Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .moveX(begin: 30, duration: const Duration(milliseconds: 300));
  }
}

// Badge de status para pedidos
class StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case OrderStatus.pending:
        badgeColor = const Color(0xFFFFA000); // Amber
        statusText = 'Pendente';
        statusIcon = Icons.schedule;
        break;
      case OrderStatus.preparing:
        badgeColor = const Color(0xFF2196F3); // Blue
        statusText = 'Preparando';
        statusIcon = Icons.restaurant;
        break;
      case OrderStatus.ready:
        badgeColor = const Color(0xFF4CAF50); // Green
        statusText = 'Pronto';
        statusIcon = Icons.check_circle;
        break;
      case OrderStatus.delivered:
        badgeColor = const Color(0xFF9E9E9E); // Grey
        statusText = 'Entregue';
        statusIcon = Icons.delivery_dining;
        break;
      case OrderStatus.canceled:
        badgeColor = const Color(0xFFF44336); // Red
        statusText = 'Cancelado';
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 16,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: badgeColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

// Seletor de quantidade
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.remove_circle_outline,
            color: quantity <= min
                ? Theme.of(context).colorScheme.outline
                : Theme.of(context).colorScheme.primary,
          ),
          onPressed: quantity <= min
              ? null
              : () => onChanged(quantity - 1),
        ),
        Container(
          width: 40,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$quantity',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.add_circle_outline,
            color: quantity >= max
                ? Theme.of(context).colorScheme.outline
                : Theme.of(context).colorScheme.primary,
          ),
          onPressed: quantity >= max
              ? null
              : () => onChanged(quantity + 1),
        ),
      ],
    );
  }
}

// Filtro de categorias
class CategoryFilter extends StatelessWidget {
  final ProductCategory? selectedCategory;
  final ValueChanged<ProductCategory?> onCategorySelected;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChip(
            label: const Row(
              children: [
                Icon(Icons.filter_alt_off, size: 16),
                SizedBox(width: 4),
                Text('Todos'),
              ],
            ),
            selected: selectedCategory == null,
            onSelected: (_) => onCategorySelected(null),
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            checkmarkColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              color: selectedCategory == null
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight:
                  selectedCategory == null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Row(
              children: [
                Icon(Icons.local_bar, size: 16),
                SizedBox(width: 4),
                Text('Bebidas'),
              ],
            ),
            selected: selectedCategory == ProductCategory.drink,
            onSelected: (_) => onCategorySelected(ProductCategory.drink),
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            checkmarkColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              color: selectedCategory == ProductCategory.drink
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: selectedCategory == ProductCategory.drink
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Row(
              children: [
                Icon(Icons.restaurant, size: 16),
                SizedBox(width: 4),
                Text('Comidas'),
              ],
            ),
            selected: selectedCategory == ProductCategory.food,
            onSelected: (_) => onCategorySelected(ProductCategory.food),
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            checkmarkColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              color: selectedCategory == ProductCategory.food
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: selectedCategory == ProductCategory.food
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Row(
              children: [
                Icon(Icons.category, size: 16),
                SizedBox(width: 4),
                Text('Outros'),
              ],
            ),
            selected: selectedCategory == ProductCategory.other,
            onSelected: (_) => onCategorySelected(ProductCategory.other),
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            checkmarkColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              color: selectedCategory == ProductCategory.other
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: selectedCategory == ProductCategory.other
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// Dialog de confirmação
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            cancelText,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: Text(
            confirmText,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
      ],
    );
  }
}

// Card vazio para quando não há dados
class EmptyStateCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateCard({
    super.key,
    required this.message,
    required this.icon,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[  
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Botão de ação flutuante
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: foregroundColor ?? Theme.of(context).colorScheme.onPrimary),
      label: Text(
        label,
        style: TextStyle(color: foregroundColor ?? Theme.of(context).colorScheme.onPrimary),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    )
    .animate()
    .scale(delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 200));
  }
}