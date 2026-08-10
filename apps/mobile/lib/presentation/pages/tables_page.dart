import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../core/services/database_service.dart';
import '../widgets/shared_widgets.dart';
import '../../core/models/data_models.dart';
import 'order_details_page.dart';

class TablesPage extends StatefulWidget {
  const TablesPage({super.key});

  @override
  State<TablesPage> createState() => _TablesPageState();
}

class _TablesPageState extends State<TablesPage> {
  final DatabaseService _databaseService = DatabaseService();
  List<TableModel> _tables = [];
  bool _isLoading = true;
  StreamSubscription<String>? _dbSub;

  @override
  void initState() {
    super.initState();
    _loadTables();
    _dbSub = _databaseService.changes.listen((_) {
      if (mounted) _loadTables();
    });
  }

  @override
  void dispose() {
    _dbSub?.cancel();
    super.dispose();
  }

  Future<void> _loadTables() async {
    setState(() {
      _isLoading = true;
    });

    final tables = await _databaseService.getTables();
    tables.sort((a, b) => a.number.compareTo(b.number));

    if (mounted) {
      setState(() {
        _tables = tables;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Gerenciar Mesas'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTables,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusHeader(),
                  const SizedBox(height: 8),
                  _buildTableGrid(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTableDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Nova Mesa'),
      ).animate().scale(delay: const Duration(milliseconds: 300)),
    );
  }

  Widget _buildStatusHeader() {
    final occupiedTables = _tables.where((table) => table.status == TableStatus.occupied).length;
    final freeTables = _tables.length - occupiedTables;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status das Mesas',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatusBox(
                  Icons.check_circle_outline,
                  'Disponíveis',
                  '$freeTables',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatusBox(
                  Icons.people,
                  'Ocupadas',
                  '$occupiedTables',
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatusBox(
                  Icons.table_restaurant,
                  'Total',
                  '${_tables.length}',
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .moveY(begin: 20, duration: const Duration(milliseconds: 300));
  }

  Widget _buildStatusBox(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: color,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTableGrid() {
    return Expanded(
      child: _tables.isEmpty
          ? Center(
              child: EmptyStateCard(
                message: 'Nenhuma mesa cadastrada',
                icon: Icons.table_bar,
                actionText: 'Adicionar Mesa',
                onAction: _showAddTableDialog,
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _tables.length,
              itemBuilder: (context, index) {
                final delay = Duration(milliseconds: 30 * index);
                final table = _tables[index];
                return _buildTableCard(table).animate().fadeIn(delay: delay).moveY(begin: 20, delay: delay, duration: const Duration(milliseconds: 300));
              },
            ),
    );
  }

  Widget _buildTableCard(TableModel table) {
    final bool isOccupied = table.status == TableStatus.occupied;
    final Color statusColor = isOccupied ? Colors.orange : Colors.green;
    final String statusText = isOccupied ? 'Ocupada' : 'Disponível';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _handleTableTap(table),
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        radius: 20,
                        child: Text(
                          '${table.number}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
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
                              isOccupied ? Icons.people : Icons.check_circle_outline,
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
                  Text(
                    'Mesa ${table.number}',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Capacidade: ${table.capacity} pessoas',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Text(
                    isOccupied ? 'Ver detalhes' : 'Iniciar atendimento',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (isOccupied)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                  .scaleXY(begin: 0.8, end: 1.2, duration: const Duration(seconds: 1)),
              ),
          ],
        ),
      ),
    );
  }

  void _handleTableTap(TableModel table) async {
    if (table.status == TableStatus.occupied) {
      // A mesa está ocupada, vamos para os detalhes do pedido
      final order = await _databaseService.getActiveOrderForTable(table.id);
      if (order != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsPage(order: order),
          ),
        ).then((_) => _loadTables());
      }
    } else {
      // A mesa está livre, vamos criar um novo pedido
      _showNewOrderDialog(table);
    }
  }

  void _showNewOrderDialog(TableModel table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abrir Mesa'),
        content: Text('Deseja iniciar um novo atendimento na mesa ${table.number}?'),
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
              Navigator.pop(context);
              
              // Criar um novo pedido
              final order = Order(
                tableId: table.id,
                tableNumber: table.number,
              );
              
              await _databaseService.addOrder(order);
              
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsPage(order: order),
                  ),
                ).then((_) => _loadTables());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              'Abrir Mesa',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTableDialog() {
    final TextEditingController numberController = TextEditingController();
    final TextEditingController capacityController = TextEditingController(text: '4');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Nova Mesa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: numberController,
              decoration: const InputDecoration(
                labelText: 'Número da Mesa',
                hintText: 'Ex: 1, 2, 3...',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: capacityController,
              decoration: const InputDecoration(
                labelText: 'Capacidade (pessoas)',
                hintText: 'Ex: 4',
              ),
              keyboardType: TextInputType.number,
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
              final numberText = numberController.text.trim();
              final capacityText = capacityController.text.trim();

              if (numberText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Informe o número da mesa')),
                );
                return;
              }

              final number = int.tryParse(numberText);
              final capacity = int.tryParse(capacityText) ?? 4;

              if (number == null || number <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Número de mesa inválido')),
                );
                return;
              }

              // Verificar se já existe uma mesa com este número
              final existingTable = _tables.any((t) => t.number == number);
              if (existingTable) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Já existe uma mesa com este número')),
                  );
                }
                return;
              }

              final newTable = TableModel(
                number: number,
                capacity: capacity,
              );

              _tables.add(newTable);
              await _databaseService.saveTables(_tables);
              Navigator.pop(context);
              _loadTables();
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
      ),
    );
  }
}