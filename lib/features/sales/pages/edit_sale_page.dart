import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shop_management/blocs/sale/sale_bloc.dart';
import 'package:shop_management/data/models/sale_model.dart';

class EditSalePage extends StatefulWidget {
  final Sale sale;

  const EditSalePage({super.key, required this.sale});

  @override
  State<EditSalePage> createState() => _EditSalePageState();
}

class _EditSalePageState extends State<EditSalePage> {
  late List<SaleItem> _items;
  late TextEditingController _customerNameCtrl;
  late TextEditingController _customerPhoneCtrl;
  late String _paymentMethod;

  @override
  void initState() {
    super.initState();
    _items = widget.sale.items.map((e) => e.copyWith()).toList();
    _customerNameCtrl = TextEditingController(
      text: widget.sale.customerName ?? '',
    );
    _customerPhoneCtrl = TextEditingController(
      text: widget.sale.customerPhone ?? '',
    );
    _paymentMethod = widget.sale.paymentMethod;
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            onPressed: () => _showDeleteConfirm(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Info
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sale #${widget.sale.id?.substring(0, 8).toUpperCase() ?? 'N/A'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('Date: ${formatter.format(widget.sale.createdAt)}'),
                  Text('Created by: ${widget.sale.createdBy}'),
                ],
              ),
            ),
          ),

          // Customer & Payment (editable)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _customerNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _customerPhoneCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Phone (optional)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _paymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'card', child: Text('Card')),
                      DropdownMenuItem(value: 'upi', child: Text('UPI')),
                      DropdownMenuItem(value: 'online', child: Text('Online')),
                    ],
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                ],
              ),
            ),
          ),

          // Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              itemBuilder: (context, i) {
                final item = _items[i];
                return Card(
                  child: ListTile(
                    title: Text(item.productName),
                    subtitle: Text(
                      'Qty: ${item.quantity} × ₹${item.unitSellingPrice.toStringAsFixed(2)}',
                    ),
                    trailing: Text(
                      '₹${item.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),

          // Summary & Save
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _summaryRow('Total Items', _items.length.toString()),
                  _summaryRow(
                    'Total Amount',
                    '₹${_items.fold<double>(0, (s, i) => s + i.totalAmount).toStringAsFixed(2)}',
                    valueColor: Colors.green,
                  ),
                  _summaryRow(
                    'Total Profit',
                    '₹${_items.fold<double>(0, (s, i) => s + i.totalProfit).toStringAsFixed(2)}',
                    valueColor: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  BlocConsumer<SaleBloc, SaleState>(
                    listener: (context, state) {
                      if (state is SaleOperationFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.error),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else if (state is SalesLoadSuccess) {
                        // After successful update/delete, list is refreshed
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sale updated successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: state is SaleOperationInProgress
                              ? null
                              : () => _updateSale(context),
                          child: state is SaleOperationInProgress
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Update Sale',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }

  void _updateSale(BuildContext context) {
    final updatedSale = widget.sale.copyWith(
      customerName: _customerNameCtrl.text.trim().isEmpty
          ? null
          : _customerNameCtrl.text.trim(),
      customerPhone: _customerPhoneCtrl.text.trim().isEmpty
          ? null
          : _customerPhoneCtrl.text.trim(),
      paymentMethod: _paymentMethod,
      items: _items,
      // Note: If your backend supports full update, send whole sale.
      // Otherwise you may need a separate "UpdateSale" event + service method.
    );

    // For now we reuse AddSale (replace) – you may want a dedicated UpdateSale event later.
    context.read<SaleBloc>().add(AddSale(sale: updatedSale));
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Sale?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SaleBloc>().add(DeleteSale(saleId: widget.sale.id!));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _customerPhoneCtrl.dispose();
    super.dispose();
  }
}
