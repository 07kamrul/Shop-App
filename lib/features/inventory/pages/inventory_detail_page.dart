import 'package:flutter/material.dart';
import 'package:shop_management/core/services/inventory_service.dart';
import 'package:shop_management/data/models/inventory_model.dart';
import 'package:shop_management/data/models/product_model.dart';
import '../widgets/inventory_product_card.dart';

class InventoryDetailPage extends StatelessWidget {
  final List<Product> products;

  const InventoryDetailPage({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final inventoryService = InventoryService();
    final summary = inventoryService.getInventorySummary(products);
    final productsNeedingRestock = inventoryService.getProductsNeedingRestock(
      products,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              _exportInventoryReport(context, products);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Row
            _buildQuickSummary(summary),
            const SizedBox(height: 20),

            // Restock Priority Section
            if (productsNeedingRestock.isNotEmpty) ...[
              _buildRestockPrioritySection(productsNeedingRestock),
              const SizedBox(height: 20),
            ],

            // All Products List
            Expanded(child: _buildProductsList(products)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSummary(InventorySummary summary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSummaryItem('Total Products', summary.totalProducts.toString()),
        _buildSummaryItem(
          'Stock Value',
          '₹${summary.totalStockValue.toStringAsFixed(0)}',
        ),
        _buildSummaryItem(
          'Alerts',
          (summary.lowStockItems + summary.outOfStockItems).toString(),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRestockPrioritySection(List<Product> productsNeedingRestock) {
    return Card(
      elevation: 2,
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.priority_high, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Restock Priority',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text('${productsNeedingRestock.length} items'),
                  backgroundColor: Colors.orange[100],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...productsNeedingRestock
                .take(3)
                .map(
                  (product) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: product.currentStock == 0
                          ? Colors.red
                          : Colors.orange,
                      child: Text(
                        product.currentStock.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(product.name),
                    subtitle: Text('Min: ${product.minStockLevel}'),
                    trailing: Text(
                      '₹${product.buyingPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            if (productsNeedingRestock.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '+ ${productsNeedingRestock.length - 3} more items need restock',
                  style: const TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList(List<Product> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Products',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return InventoryProductCard(product: product);
            },
          ),
        ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Inventory'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterOption('All Products', true),
            _buildFilterOption('Low Stock Only', false),
            _buildFilterOption('Out of Stock Only', false),
            _buildFilterOption('By Category', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String title, bool isSelected) {
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? Colors.blue : Colors.grey,
      ),
      title: Text(title),
      onTap: () {},
    );
  }

  void _exportInventoryReport(BuildContext context, List<Product> products) {
    // Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Inventory report export feature coming soon!'),
      ),
    );
  }
}
