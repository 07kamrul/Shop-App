class ExportUtils {
  // Prepare sales data for CSV export
  static List<List<dynamic>> prepareSalesData(List<dynamic> sales) {
    final List<List<dynamic>> data = [];
    
    // Add header row
    data.add([
      'Sale ID',
      'Date',
      'Customer Name',
      'Payment Method',
      'Total Amount',
      'Total Items',
    ]);

    // Add data rows
    for (final sale in sales) {
      if (sale is Map<String, dynamic>) {
        data.add([
          sale['id'] ?? 'N/A',
          sale['dateTime'] ?? 'N/A',
          sale['customerName'] ?? 'Walk-in Customer',
          sale['paymentMethod'] ?? 'cash',
          sale['totalAmount'] ?? 0.0,
          (sale['items'] as List?)?.length ?? 0,
        ]);
      }
      // Add handling for Sale objects if needed
    }

    return data;
  }

  // Prepare products data for CSV export
  static List<List<dynamic>> prepareProductsData(List<dynamic> products) {
    final List<List<dynamic>> data = [];
    
    // Add header row
    data.add([
      'Product ID',
      'Name',
      'Barcode',
      'Buying Price',
      'Selling Price',
      'Current Stock',
      'Min Stock Level',
    ]);

    // Add data rows
    for (final product in products) {
      if (product is Map<String, dynamic>) {
        data.add([
          product['id'] ?? 'N/A',
          product['name'] ?? 'N/A',
          product['barcode'] ?? '',
          product['buyingPrice'] ?? 0.0,
          product['sellingPrice'] ?? 0.0,
          product['currentStock'] ?? 0,
          product['minStockLevel'] ?? 10,
        ]);
      }
      // Add handling for Product objects if needed
    }

    return data;
  }

  // Prepare inventory data for CSV export
  static List<List<dynamic>> prepareInventoryData(List<dynamic> products) {
    final List<List<dynamic>> data = [];
    
    // Add header row
    data.add([
      'Product ID',
      'Name',
      'Current Stock',
      'Min Stock Level',
      'Stock Status',
      'Buying Price',
      'Selling Price',
      'Profit Margin',
    ]);

    // Add data rows
    for (final product in products) {
      if (product is Map<String, dynamic>) {
        final currentStock = product['currentStock'] ?? 0;
        final minStockLevel = product['minStockLevel'] ?? 10;
        final buyingPrice = product['buyingPrice'] ?? 0.0;
        final sellingPrice = product['sellingPrice'] ?? 0.0;
        final profitMargin = sellingPrice > 0 
            ? ((sellingPrice - buyingPrice) / sellingPrice) * 100 
            : 0.0;
        final stockStatus = currentStock <= minStockLevel 
            ? 'Low Stock' 
            : 'In Stock';

        data.add([
          product['id'] ?? 'N/A',
          product['name'] ?? 'N/A',
          currentStock,
          minStockLevel,
          stockStatus,
          buyingPrice,
          sellingPrice,
          profitMargin.toStringAsFixed(2),
        ]);
      }
    }

    return data;
  }

  // Simple CSV export method
  static Future<String?> exportToCSVSimple({
    required List<List<dynamic>> data,
    required String fileName,
  }) async {
    try {
      final StringBuffer csvContent = StringBuffer();
      
      for (final row in data) {
        final encodedRow = row.map((cell) {
          final cellStr = cell.toString();
          // Escape quotes and wrap in quotes if contains comma
          if (cellStr.contains(',') || cellStr.contains('"')) {
            return '"${cellStr.replaceAll('"', '""')}"';
          }
          return cellStr;
        }).join(',');
        
        csvContent.writeln(encodedRow);
      }

      // In a real implementation, you would save this to a file
      // For now, we'll just return a success message
      return 'Documents/$fileName.csv';
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }
}