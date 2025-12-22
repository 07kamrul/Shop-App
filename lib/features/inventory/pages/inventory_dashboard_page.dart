// features/inventory/pages/inventory_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_management/blocs/inventory/inventory_bloc.dart';
import 'package:shop_management/data/models/inventory_model.dart';
import 'package:shop_management/features/inventory/pages/category_inventory_page.dart';
import 'package:shop_management/features/inventory/pages/restock_needed_page.dart';
import 'package:shop_management/features/inventory/pages/stock_alerts_page.dart';
import 'package:shop_management/features/inventory/widgets/inventory_summary_card.dart';
import 'package:shop_management/features/inventory/widgets/stock_alert_card.dart';

class InventoryDashboardPage extends StatefulWidget {
  const InventoryDashboardPage({super.key});

  @override
  State<InventoryDashboardPage> createState() => _InventoryDashboardPageState();
}

class _InventoryDashboardPageState extends State<InventoryDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load products when page first opens
    context.read<ProductBloc>().add(LoadProducts());
  }

  void _onRefresh() {
    context.read<ProductBloc>().add(LoadProducts());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InventoryBloc()..add(LoadInventoryDashboard()),
      child: const _InventoryDashboardView(), // Wrapped in a separate widget
    );
  }
}

// New wrapper widget to ensure correct context
class _InventoryDashboardView extends StatelessWidget {
  const _InventoryDashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<InventoryBloc>().add(LoadInventoryDashboard()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<InventoryBloc>().add(LoadInventoryDashboard());
        },
        child: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            if (state is InventoryLoading || state is InventoryInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is InventoryError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message, textAlign: TextAlign.center),
                    ElevatedButton(
                      onPressed: () => context.read<InventoryBloc>().add(
                        LoadInventoryDashboard(),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

            if (state is InventoryDashboardLoaded) {
              return _DashboardContent(
                summary: state.summary,
                alerts: state.alerts,
              );
            }

            return const Center(child: Text('No data'));
          },
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final InventorySummary summary;
  final List<StockAlert> alerts;

  const _DashboardContent({required this.summary, required this.alerts});

  @override
  Widget build(BuildContext context) {
    final criticalAlerts = alerts.take(4).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.4, // Adjusted for better fit
            ),
            children: [
              InventorySummaryCard(
                title: 'Total Products',
                value: summary.totalProducts.toString(),
                icon: Icons.inventory_2,
                color: Colors.blue,
                subtitle: 'Total number of products in inventory',
              ),
              InventorySummaryCard(
                title: 'Stock Value',
                value: '₹${summary.totalStockValue.toStringAsFixed(0)}',
                icon: Icons.account_balance_wallet,
                color: Colors.green,
                subtitle: 'Total value of current stock',
              ),
              InventorySummaryCard(
                title: 'Low Stock',
                value: summary.lowStockItems.toString(),
                icon: Icons.warning_amber,
                color: Colors.orange,
                subtitle: 'Items running low on stock',
              ),
              InventorySummaryCard(
                title: 'Out of Stock',
                value: summary.outOfStockItems.toString(),
                icon: Icons.error,
                color: Colors.red,
                subtitle: 'Items out of stock',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Stock Alerts
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Stock Alerts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Chip(
                        backgroundColor: alerts.isEmpty
                            ? Colors.green
                            : Colors.red,
                        label: Text(
                          alerts.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (alerts.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('All products are well stocked!'),
                      ),
                    )
                  else
                    ...criticalAlerts.map((a) => StockAlertCard(alert: a)),
                  if (alerts.length > 4)
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<InventoryBloc>(),
                            child: const StockAlertsPage(),
                          ),
                        ),
                      ),
                      child: Text('View all ${alerts.length} alerts →'),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Quick Actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Access',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _QuickAction(
                        icon: Icons.category,
                        label: 'By Category',
                        color: Colors.purple,
                        onTap: () {
                          // Get the bloc before navigation
                          final bloc = context.read<InventoryBloc>();
                          bloc.add(LoadCategoryInventory());

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: bloc,
                                child: const CategoryInventoryPage(),
                              ),
                            ),
                          );
                        },
                      ),
                      _QuickAction(
                        icon: Icons.priority_high,
                        label: 'Restock Needed',
                        color: Colors.red,
                        onTap: () {
                          // Get the bloc before navigation
                          final bloc = context.read<InventoryBloc>();
                          bloc.add(LoadRestockNeeded());

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: bloc,
                                child: const RestockNeededPage(),
                              ),
                            ),
                          );
                        },
                      ),
                      _QuickAction(
                        icon: Icons.trending_up,
                        label: 'Turnover Rate',
                        color: Colors.teal,
                        onTap: () => _showTurnoverDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTurnoverDialog(BuildContext context) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 1, 1);
    final end = DateTime(now.year, now.month, 0);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Inventory Turnover'),
        content: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (ctx, state) {
            if (state is InventoryTurnoverLoaded) {
              return Text(
                'Turnover Rate: ${state.turnover.toStringAsFixed(2)}x',
              );
            }
            if (state is InventoryLoading) {
              return const LinearProgressIndicator();
            }
            return const Text('Calculating...');
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<InventoryBloc>().add(
                LoadInventoryTurnover(start, end),
              );
            },
            child: const Text('Calculate Last Month'),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
