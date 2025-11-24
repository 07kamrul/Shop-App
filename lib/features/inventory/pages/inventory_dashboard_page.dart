import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_management/core/services/inventory_service.dart';
import 'package:shop_management/data/models/product_model.dart';
import 'package:shop_management/features/inventory/widgets/inventory_summary_card.dart';
import '../../../../blocs/auth/auth_bloc.dart';
import '../../../../blocs/product/product_bloc.dart';
import '../../../../data/models/inventory_model.dart';
import '../widgets/stock_alert_card.dart';
import 'inventory_detail_page.dart';
import 'stock_alerts_page.dart';

class InventoryDashboardPage extends StatelessWidget {
  const InventoryDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;

    return BlocProvider(
      // Fixed: Use direct ProductBloc() instead of getIt<ProductBloc>()
      create: (context) => ProductBloc()..add(LoadProducts()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventory Management'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<ProductBloc>().add(LoadProducts());
              },
            ),
          ],
        ),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductsLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProductsLoadFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load inventory',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(state.error),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProductBloc>().add(LoadProducts());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is ProductsLoadSuccess) {
              final products = List<Product>.from(state.products);
              final inventoryService = InventoryService();
              final summary = inventoryService.getInventorySummary(
                products,
              );
              final alerts = inventoryService.getStockAlerts(products);

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Cards
                      _buildSummaryCards(summary),
                      const SizedBox(height: 20),

                      // Stock Alerts Section
                      _buildStockAlertsSection(alerts, context),
                      const SizedBox(height: 20),

                      // Quick Actions
                      _buildQuickActions(context, products),
                    ],
                  ),
                ),
              );
            }

            return const Center(child: Text('Load inventory data'));
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCards(InventorySummary summary) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        InventorySummaryCard(
          title: 'Total Products',
          value: summary.totalProducts.toString(),
          icon: Icons.inventory_2,
          color: Colors.blue,
          subtitle: 'Active items',
        ),
        InventorySummaryCard(
          title: 'Stock Value',
          value: '₹${summary.totalStockValue.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: Colors.green,
          subtitle: 'Current valuation',
        ),
        InventorySummaryCard(
          title: 'Low Stock',
          value: summary.lowStockItems.toString(),
          icon: Icons.warning_amber,
          color: Colors.orange,
          subtitle: 'Need attention',
        ),
        InventorySummaryCard(
          title: 'Out of Stock',
          value: summary.outOfStockItems.toString(),
          icon: Icons.error_outline,
          color: Colors.red,
          subtitle: 'Urgent restock',
        ),
      ],
    );
  }

  Widget _buildStockAlertsSection(
    List<StockAlert> alerts,
    BuildContext context,
  ) {
    final criticalAlerts = alerts.take(3).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Stock Alerts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (alerts.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${alerts.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (criticalAlerts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, size: 48, color: Colors.green),
                    SizedBox(height: 8),
                    Text(
                      'All products are well stocked!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  ...criticalAlerts.map(
                    (alert) => StockAlertCard(alert: alert),
                  ),
                  const SizedBox(height: 12),
                  if (alerts.length > 3)
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StockAlertsPage(),
                            ),
                          );
                        },
                        child: Text(
                          'View all ${alerts.length} alerts',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, List<Product> products) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildQuickActionCard(
                  icon: Icons.analytics,
                  title: 'Inventory Report',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            InventoryDetailPage(products: products),
                      ),
                    );
                  },
                ),
                _buildQuickActionCard(
                  icon: Icons.warning,
                  title: 'Stock Alerts',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StockAlertsPage(),
                      ),
                    );
                  },
                ),
                _buildQuickActionCard(
                  icon: Icons.category,
                  title: 'By Category',
                  color: Colors.blue,
                  onTap: () {
                    _showCategoryInventory(context, products);
                  },
                ),
                _buildQuickActionCard(
                  icon: Icons.add_box,
                  title: 'Add Product',
                  color: Colors.green,
                  onTap: () {
                    // TODO: Navigate to Add Product screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Add Product - Coming Soon!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryInventory(BuildContext context, List<Product> products) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Category Inventory'),
        content: const Text('Category-wise breakdown coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
