import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_management/core/services/inventory_service.dart';
import 'package:shop_management/data/models/product_model.dart';
import '../../../../blocs/product/product_bloc.dart';
import '../../../../data/models/inventory_model.dart';

class StockAlertsPage extends StatelessWidget {
  const StockAlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is! ProductsLoadSuccess) {
          return Scaffold(
            appBar: AppBar(title: const Text('Stock Alerts')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final inventoryService = InventoryService();
        final alerts = inventoryService.getStockAlerts(state.products.cast<Product>());

        return Scaffold(
          appBar: AppBar(
            title: const Text('Stock Alerts'),
            actions: [
              if (alerts.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.notifications_off),
                  onPressed: () {
                    _markAllAsRead(context);
                  },
                  tooltip: 'Mark all as read',
                ),
            ],
          ),
          body: alerts.isEmpty ? _buildEmptyState() : _buildAlertsList(alerts),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 80, color: Colors.green[400]),
          const SizedBox(height: 16),
          const Text(
            'No Stock Alerts',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'All your products are well stocked. Great job managing your inventory!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList(List<StockAlert> alerts) {
    final outOfStockAlerts = alerts
        .where((a) => a.alertType == 'out_of_stock')
        .toList();
    final lowStockAlerts = alerts
        .where((a) => a.alertType == 'low_stock')
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (outOfStockAlerts.isNotEmpty) ...[
          _buildAlertSection('Out of Stock', outOfStockAlerts, Colors.red),
          const SizedBox(height: 20),
        ],
        if (lowStockAlerts.isNotEmpty) ...[
          _buildAlertSection('Low Stock', lowStockAlerts, Colors.orange),
        ],
      ],
    );
  }

  Widget _buildAlertSection(
    String title,
    List<StockAlert> alerts,
    Color color,
  ) {
    return Card(
      elevation: 2,
      color: color.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    title == 'Out of Stock' ? Icons.error : Icons.warning,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text(
                    alerts.length.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: color,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...alerts.map((alert) => _buildAlertItem(alert, color)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(StockAlert alert, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Stock Indicator
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                alert.currentStock.toString(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.categoryName,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  'Minimum stock: ${alert.minStockLevel}',
                  style: TextStyle(fontSize: 12, color: color),
                ),
              ],
            ),
          ),
          // Action Button
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: () {
              // Navigate to purchase order or restock
            },
            color: color,
            tooltip: 'Restock this item',
          ),
        ],
      ),
    );
  }

  void _markAllAsRead(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All alerts marked as read'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
