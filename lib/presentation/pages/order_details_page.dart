import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../core/services/database_service.dart';
import '../widgets/shared_widgets.dart';
import '../../core/models/data_models.dart';

class OrderDetailsPage extends StatefulWidget {
  final Order order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final DatabaseService _databaseService = DatabaseService();
  late Order _order;
  List<Product> _products = [];
  bool _isLoading = true;
  final TextEditingController _noteController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    final products = await _databaseService.getProducts();
    final freshOrder = await _getUpdatedOrder();

    if (mounted) {
      setState(() {
        _products = products;
        if (freshOrder != null) {
          _order = freshOrder;
        }
        _isLoading = false;
      });
    }
  }

  Future<Order?> _getUpdatedOrder() async {
    final orders = await _databaseService.getOrders();
    try {
      return orders.firstWhere((o) => o.id == _order.id);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Mesa ${_order.tableNumber}',
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildOrderHeader(),
                _buildOrderItemsList(),
              ],
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Comanda #${_order.id.substring(0, 8)}',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              StatusBadge(status: _order.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aberto em:',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                  ),
                  Text(
                    formatDateTime(_order.createdAt),
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total:',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                  ),
                  Text(
                    formatCurrency(_order.total),
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsList() {
    return Expanded(
      child: _order.items.isEmpty
          ? Center(
              child: EmptyStateCard(
                message: 'Nenhum item adicionado',
                icon: Icons.shopping_cart,
                actionText: 'Adicionar Item',
                onAction: _showAddItemDialog,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _order.items.length,
              itemBuilder: (context, index) {
                final item = _order.items[index];
                return _buildOrderItemCard(item, index);
              },
            ),
    );
  }

  Widget _buildOrderItemCard(OrderItem item, int index) {
    return Slidable(
      key: Key(item.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(onDismissed: () => _removeItem(item)),
        children: [
          SlidableAction(
            onPressed: (_) => _removeItem(item),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Remover',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconForProductName(item.productName),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.productName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            StatusBadge(status: item.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${item.quantity}x',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formatCurrency(item.price),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        if (item.notes.isNotEmpty) ...[  
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.note,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item.notes,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${formatCurrency(item.total)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  _buildStatusButton(item),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: getAnimationDelay(index))
        .fadeIn(duration: const Duration(milliseconds: 300))
        .moveX(begin: 30, duration: const Duration(milliseconds: 300));
  }

  IconData _getIconForProductName(String name) {
    name = name.toLowerCase();
    if (name.contains('chopp') || name.contains('cerveja')) {
      return Icons.sports_bar;
    } else if (name.contains('caipirinha') || name.contains('drink')) {
      return Icons.local_bar;
    } else if (name.contains('refrigerante') || name.contains('suco') || name.contains('água')) {
      return Icons.local_drink;
    } else if (name.contains('batata') || name.contains('frango') || name.contains('carne')) {
      return Icons.fastfood;
    } else {
      return Icons.restaurant;
    }
  }

  Widget _buildStatusButton(OrderItem item) {
    if (item.status == OrderStatus.canceled || item.status == OrderStatus.delivered) {
      return const SizedBox.shrink();
    }

    String buttonText;
    Color buttonColor;
    OrderStatus newStatus;

    switch (item.status) {
      case OrderStatus.pending:
        buttonText = 'Preparando';
        buttonColor = Colors.blue;
        newStatus = OrderStatus.preparing;
        break;
      case OrderStatus.preparing:
        buttonText = 'Pronto';
        buttonColor = Colors.green;
        newStatus = OrderStatus.ready;
        break;
      case OrderStatus.ready:
        buttonText = 'Entregue';
        buttonColor = Colors.grey;
        newStatus = OrderStatus.delivered;
        break;
      default:
        return const SizedBox.shrink();
    }

    return OutlinedButton(
      onPressed: () => _updateItemStatus(item, newStatus),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: buttonColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      ),
      child: Text(
        buttonText,
        style: TextStyle(color: buttonColor),
      ),
    );
  }

  Future<void> _updateItemStatus(OrderItem item, OrderStatus newStatus) async {
    final List<OrderItem> updatedItems = _order.items.map((i) {
      if (i.id == item.id) {
        return i.copyWith(status: newStatus);
      }
      return i;
    }).toList();

    final updatedOrder = _order.copyWith(items: updatedItems);
    await _databaseService.updateOrder(updatedOrder);

    // Atualizar o status geral do pedido baseado nos itens
    OrderStatus orderStatus = _determineOrderStatus(updatedItems);
    final finalOrder = updatedOrder.copyWith(status: orderStatus);
    await _databaseService.updateOrder(finalOrder);

    setState(() {
      _order = finalOrder;
    });
  }

  OrderStatus _determineOrderStatus(List<OrderItem> items) {
    if (items.every((item) => item.status == OrderStatus.canceled)) {
      return OrderStatus.canceled;
    }
    if (items.every((item) => item.status == OrderStatus.delivered || item.status == OrderStatus.canceled)) {
      return OrderStatus.delivered;
    }
    if (items.any((item) => item.status == OrderStatus.ready)) {
      return OrderStatus.ready;
    }
    if (items.any((item) => item.status == OrderStatus.preparing)) {
      return OrderStatus.preparing;
    }
    return OrderStatus.pending;
  }

  Future<void> _removeItem(OrderItem item) async {
    // Remover o item da lista
    final List<OrderItem> updatedItems = _order.items.where((i) => i.id != item.id).toList();
    final updatedOrder = _order.copyWith(items: updatedItems);
    await _databaseService.updateOrder(updatedOrder);

    // Se não sobrou nenhum item, atualizar o status do pedido
    OrderStatus orderStatus = updatedItems.isEmpty ? OrderStatus.pending : _determineOrderStatus(updatedItems);
    final finalOrder = updatedOrder.copyWith(status: orderStatus);
    await _databaseService.updateOrder(finalOrder);

    setState(() {
      _order = finalOrder;
    });
  }

  void _showAddItemDialog() {
    ProductCategory? selectedCategory;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          List<Product> filteredProducts = _products;
          if (selectedCategory != null) {
            filteredProducts = _products.where((p) => p.category == selectedCategory).toList();
          }
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Adicionar Item ao Pedido',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                CategoryFilter(
                  selectedCategory: selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                ),
                Expanded(
                  child: filteredProducts.isEmpty
                      ? const Center(child: Text('Nenhum produto encontrado'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: InkWell(
                                onTap: () => _showQuantityDialog(product),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          _getIconForProductName(product.name),
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            Text(
                                              product.description,
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                                fontSize: 14,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            formatCurrency(product.price),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.primary,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            'Estoque: ${product.stockQuantity}',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showQuantityDialog(Product product) {
    int quantity = 1;
    _noteController.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Adicionar ${product.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                      max: product.stockQuantity,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Observação (opcional)',
                    hintText: 'Ex: Sem gelo, bem passado...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Preço unitário:'),
                    Text(
                      formatCurrency(product.price),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      formatCurrency(product.price * quantity),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                      ),
                    ),
                  ],
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
                onPressed: () {
                  _addItemToOrder(product, quantity, _noteController.text);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  'Adicionar ao Pedido',
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addItemToOrder(Product product, int quantity, String note) async {
    final orderItem = OrderItem(
      productId: product.id,
      productName: product.name,
      price: product.price,
      quantity: quantity,
      notes: note,
    );

    final List<OrderItem> updatedItems = [..._order.items, orderItem];
    final updatedOrder = _order.copyWith(
      items: updatedItems,
      status: OrderStatus.pending,
    );

    await _databaseService.updateOrder(updatedOrder);
    setState(() {
      _order = updatedOrder;
    });
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ActionButton(
              icon: Icons.add_shopping_cart,
              label: 'Adicionar Item',
              onPressed: _showAddItemDialog,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _order.items.isEmpty
                ? ActionButton(
                    icon: Icons.cancel,
                    label: 'Cancelar Mesa',
                    onPressed: _showCancelOrderDialog,
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  )
                : ActionButton(
                    icon: Icons.check_circle,
                    label: 'Fechar Mesa',
                    onPressed: () {
                      if (_order.items.isNotEmpty) {
                        _showCloseOrderDialog();
                      }
                    },
                    backgroundColor: const Color(0xFF4CAF50),
                  ),
          ),
        ],
      ),
    );
  }

  void _showCancelOrderDialog() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Cancelar Mesa',
        content: 'Tem certeza que deseja cancelar esta mesa? Esta ação não pode ser desfeita.',
        confirmText: 'Sim, Cancelar',
        cancelText: 'Não',
        onConfirm: () async {
          await _databaseService.closeOrder(_order.id);
          if (mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _showCloseOrderDialog() {
    // Verificar se todos os itens estão entregues
    bool allDelivered = _order.items.every((item) => 
        item.status == OrderStatus.delivered || 
        item.status == OrderStatus.canceled);

    if (!allDelivered) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Atenção'),
          content: const Text('Existem itens que ainda não foram entregues. Deseja marcar todos como entregues e fechar a mesa?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _markAllItemsAsDelivered();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'Marcar e Fechar',
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
          ],
        ),
      );
      return;
    }

    PaymentMethod selectedMethod = PaymentMethod.cash;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Fechar Mesa'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total a pagar: ${formatCurrency(_order.total)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Forma de Pagamento:'),
                const SizedBox(height: 8),
                DropdownButtonFormField<PaymentMethod>(
                  initialValue: selectedMethod,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: PaymentMethod.cash,
                      child: Row(
                        children: [
                          Icon(Icons.money),
                          SizedBox(width: 8),
                          Text('Dinheiro'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: PaymentMethod.credit,
                      child: Row(
                        children: [
                          Icon(Icons.credit_card),
                          SizedBox(width: 8),
                          Text('Cartão de Crédito'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: PaymentMethod.debit,
                      child: Row(
                        children: [
                          Icon(Icons.credit_card),
                          SizedBox(width: 8),
                          Text('Cartão de Débito'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: PaymentMethod.pix,
                      child: Row(
                        children: [
                          Icon(Icons.qr_code),
                          SizedBox(width: 8),
                          Text('PIX'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedMethod = value;
                      });
                    }
                  },
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
                onPressed: () {
                  Navigator.pop(context);
                  _closeOrder();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  'Confirmar Pagamento',
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _markAllItemsAsDelivered() async {
    final List<OrderItem> updatedItems = _order.items.map((item) {
      if (item.status != OrderStatus.canceled && item.status != OrderStatus.delivered) {
        return item.copyWith(status: OrderStatus.delivered);
      }
      return item;
    }).toList();

    final updatedOrder = _order.copyWith(
      items: updatedItems,
      status: OrderStatus.delivered,
    );

    await _databaseService.updateOrder(updatedOrder);
    setState(() {
      _order = updatedOrder;
    });

    _showCloseOrderDialog();
  }

  Future<void> _closeOrder() async {
    await _databaseService.closeOrder(_order.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mesa ${_order.tableNumber} fechada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
