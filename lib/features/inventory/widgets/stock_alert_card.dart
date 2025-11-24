import 'package:flutter/material.dart';
import '../../../../data/models/inventory_model.dart';

class StockAlertCard extends StatelessWidget {
  final StockAlert alert;

  const StockAlertCard({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = alert.alertType == 'out_of_stock';
    final color = isOutOfStock ? Colors.red : Colors.orange;
    final icon = isOutOfStock ? Icons.error_outline : Icons.warning_amber;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.productName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stock: ${alert.currentStock} / ${alert.minStockLevel}',
                  style: TextStyle(fontSize: 12, color: color),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isOutOfStock ? 'OUT' : 'LOW',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
