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
    final summary = InventoryService.getInventorySummary(products);
    final productsNeedingRestock = InventoryService.getProductsNeedingRestock(
      products,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Report'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export',
            onPressed: () => _exportInventoryReport(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Fixed: Use the outer context safely
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Refreshed!'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickSummary(summary),
              const SizedBox(height: 24),

              if (productsNeedingRestock.isNotEmpty) ...[
                _buildRestockPrioritySection(productsNeedingRestock),
                const SizedBox(height: 24),
              ],

              const Text(
                'All Products',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _buildProductsList(products),

              // Ensures scroll works even with little content
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSummary(InventorySummary summary) {
    final totalAlerts = summary.lowStockItems + summary.outOfStockItems;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(
              label: 'Total Products',
              value: summary.totalProducts.toString(),
              color: Colors.blue,
            ),
            _buildSummaryItem(
              label: 'Stock Value',
              value: '₹${summary.totalStockValue.toStringAsFixed(0)}',
              color: Colors.green,
            ),
            _buildSummaryItem(
              label: 'Alerts',
              value: totalAlerts.toString(),
              color: totalAlerts > 0 ? Colors.red : Colors.grey,
              bold: totalAlerts > 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required Color color,
    bool bold = false,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildRestockPrioritySection(List<Product> productsNeedingRestock) {
    final displayItems = productsNeedingRestock.take(5).toList();

    return Card(
      color: Colors.orange[50],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.priority_high, color: Colors.orange[700], size: 28),
                const SizedBox(width: 10),
                const Text(
                  'Restock Priority',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const Spacer(),
                Chip(
                  backgroundColor: Colors.orange[200],
                  label: Text(
                    '${productsNeedingRestock.length} items',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...displayItems.map(
              (product) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: product.currentStock == 0
                        ? Colors.red
                        : Colors.orange,
                    child: Text(
                      product.currentStock.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Min: ${product.minStockLevel} • Buying: ₹${product.buyingPrice.toStringAsFixed(0)}',
                  ),
                  trailing: Icon(
                    product.currentStock == 0 ? Icons.error : Icons.warning,
                    color: product.currentStock == 0
                        ? Colors.red
                        : Colors.orange,
                  ),
                ),
              ),
            ),
            if (productsNeedingRestock.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Center(
                  child: Text(
                    '+ ${productsNeedingRestock.length - 5} more items need attention',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList(List<Product> products) {
    if (products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No products found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: InventoryProductCard(product: product),
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Filter Inventory'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption(context, 'All Products', true),
            _buildFilterOption(context, 'Low Stock Only', false),
            _buildFilterOption(context, 'Out of Stock Only', false),
            _buildFilterOption(context, 'High Value Items', false),
            _buildFilterOption(context, 'By Category', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(BuildContext context, String title, bool isSelected) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
      ),
      title: Text(title),
      onTap: () {
        // Future: handle selection
      },
    );
  }

  void _exportInventoryReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting inventory report...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
