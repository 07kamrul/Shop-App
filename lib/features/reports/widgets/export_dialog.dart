import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../blocs/product/product_bloc.dart';
import '../../../../blocs/sale/sale_bloc.dart';
import '../../../../core/utils/export_utils.dart';

class ExportDialog extends StatelessWidget {
  const ExportDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Data'),
      content: const Text('Choose what data you want to export as CSV:'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _exportSalesData(context),
          child: const Text('Sales Data'),
        ),
        ElevatedButton(
          onPressed: () => _exportProductsData(context),
          child: const Text('Products Data'),
        ),
        ElevatedButton(
          onPressed: () => _exportInventoryData(context),
          child: const Text('Inventory Data'),
        ),
      ],
    );
  }

  void _exportSalesData(BuildContext context) async {
    final saleState = context.read<SaleBloc>().state;

    if (saleState is SalesLoadSuccess) {
      _showLoadingDialog(context, 'Exporting Sales Data...');

      try {
        // Check storage permission
        final permissionStatus = await Permission.storage.request();
        if (!permissionStatus.isGranted) {
          Navigator.pop(context); // Close loading dialog
          _showExportResult(
            context,
            false,
            'Storage permission is required to export files.',
          );
          return;
        }

        // Get sales data directly from state
        final sales = saleState.sales;
        final data = ExportUtils.prepareSalesData(sales);

        final filePath = await ExportUtils.exportToCSVSimple(
          data: data,
          fileName: 'sales_export_${DateTime.now().millisecondsSinceEpoch}',
        );

        Navigator.pop(context); // Close loading dialog
        _showExportResult(context, true, filePath ?? 'Unknown location');
      } catch (e) {
        Navigator.pop(context); // Close loading dialog
        _showExportResult(context, false, e.toString());
      }
    } else {
      _showExportResult(
        context,
        false,
        'Sales data not available. Please load sales first.',
      );
    }
  }

  void _exportProductsData(BuildContext context) async {
    final productState = context.read<ProductBloc>().state;

    if (productState is ProductsLoadSuccess) {
      _showLoadingDialog(context, 'Exporting Products Data...');

      try {
        // Check storage permission
        final permissionStatus = await Permission.storage.request();
        if (!permissionStatus.isGranted) {
          Navigator.pop(context); // Close loading dialog
          _showExportResult(
            context,
            false,
            'Storage permission is required to export files.',
          );
          return;
        }

        // Get products data directly from state
        final products = productState.products;
        final data = ExportUtils.prepareProductsData(products);

        final filePath = await ExportUtils.exportToCSVSimple(
          data: data,
          fileName: 'products_export_${DateTime.now().millisecondsSinceEpoch}',
        );

        Navigator.pop(context); // Close loading dialog
        _showExportResult(context, true, filePath ?? 'Unknown location');
      } catch (e) {
        Navigator.pop(context); // Close loading dialog
        _showExportResult(context, false, e.toString());
      }
    } else {
      _showExportResult(
        context,
        false,
        'Products data not available. Please load products first.',
      );
    }
  }

  void _exportInventoryData(BuildContext context) async {
    final productState = context.read<ProductBloc>().state;

    if (productState is ProductsLoadSuccess) {
      _showLoadingDialog(context, 'Exporting Inventory Data...');

      try {
        // Check storage permission
        final permissionStatus = await Permission.storage.request();
        if (!permissionStatus.isGranted) {
          Navigator.pop(context); // Close loading dialog
          _showExportResult(
            context,
            false,
            'Storage permission is required to export files.',
          );
          return;
        }

        // Get products data directly from state
        final products = productState.products;
        final data = ExportUtils.prepareInventoryData(products);

        final filePath = await ExportUtils.exportToCSVSimple(
          data: data,
          fileName: 'inventory_export_${DateTime.now().millisecondsSinceEpoch}',
        );

        Navigator.pop(context); // Close loading dialog
        _showExportResult(context, true, filePath ?? 'Unknown location');
      } catch (e) {
        Navigator.pop(context); // Close loading dialog
        _showExportResult(context, false, e.toString());
      }
    } else {
      _showExportResult(
        context,
        false,
        'Inventory data not available. Please load products first.',
      );
    }
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  void _showExportResult(BuildContext context, bool success, String message) {
    // Close the loading dialog if it's still open
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(success ? 'Export Successful' : 'Export Failed'),
        icon: Icon(
          success ? Icons.check_circle : Icons.error,
          color: success ? Colors.green : Colors.red,
          size: 48,
        ),
        content: Text(
          success
              ? 'Data exported successfully!\n\nFile location: $message'
              : 'Export failed: $message',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          if (success)
            TextButton(
              onPressed: () {
                // You could add share functionality here
                // For now, just close the dialog
                Navigator.pop(context);
              },
              child: const Text('Share'),
            ),
        ],
      ),
    );
  }
}