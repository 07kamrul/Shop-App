import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_management/core/services/inventory_service.dart';
import 'package:shop_management/data/models/product_model.dart';
import 'package:shop_management/features/inventory/widgets/inventory_summary_card.dart';
import '../../../../blocs/product/product_bloc.dart';
import '../../../../data/models/inventory_model.dart';
import '../widgets/stock_alert_card.dart';
import 'inventory_detail_page.dart';
import 'stock_alerts_page.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _onRefresh,
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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 80, color: Colors.red),
                    const SizedBox(height: 24),
                    const Text(
                      'Failed to load inventory',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.error,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _onRefresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ProductsLoadSuccess) {
            final products = List<Product>.from(state.products);

            // Use static methods directly — no instance needed
            final summary = InventoryService.getInventorySummary(products);
            final alerts = InventoryService.getStockAlerts(products);

            return RefreshIndicator(
              onRefresh: () async => _onRefresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    _buildSummarySection(summary),
                    const SizedBox(height: 24),

                    // Stock Alerts
                    _buildStockAlertsSection(alerts, context),
                    const SizedBox(height: 24),

                    // Quick Actions
                    _buildQuickActionsSection(context, products),

                    const SizedBox(height: 40), // Bottom padding
                  ],
                ),
              ),
            );
          }

          // Initial or unknown state
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No inventory data'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Load Data'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummarySection(InventorySummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inventory Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
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
              value: '₹${summary.totalStockValue.toStringAsFixed(0)}',
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
        ),
      ],
    );
  }

  Widget _buildStockAlertsSection(List<StockAlert> alerts, BuildContext context) {
    final criticalAlerts = alerts.take(3).toList();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${alerts.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (criticalAlerts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, size: 56, color: Colors.green),
                    SizedBox(height: 12),
                    Text(
                      'All products are well stocked!',
                      style: TextStyle(fontSize: 16, color: Colors.green),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  ...criticalAlerts.map((alert) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: StockAlertCard(alert: alert),
                      )),
                  const SizedBox(height: 12),
                  if (alerts.length > 3)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StockAlertsPage(),
                            ),
                          );
                        },
                        child: Text('View all ${alerts.length} alerts'),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, List<Product> products) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              childAspectRatio: 1.4,
              children: [
                _buildActionCard(
                  icon: Icons.analytics,
                  title: 'Full Report',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InventoryDetailPage(products: products),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  icon: Icons.warning_rounded,
                  title: 'All Alerts',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StockAlertsPage()),
                    );
                  },
                ),
                _buildActionCard(
                  icon: Icons.category_outlined,
                  title: 'By Category',
                  color: Colors.blue,
                  onTap: () => _showComingSoon(context, 'Category View'),
                ),
                _buildActionCard(
                  icon: Icons.add_box,
                  title: 'Add Product',
                  color: Colors.green,
                  onTap: () => _showComingSoon(context, 'Add Product'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature - Coming Soon!')),
    );
  }
}