import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shop_management/blocs/sale/sale_bloc.dart';
import 'package:shop_management/data/models/sale_model.dart';
import 'edit_sale_page.dart';

class SaleListPage extends StatefulWidget {
  const SaleListPage({super.key});

  @override
  State<SaleListPage> createState() => _SaleListPageState();
}

class _SaleListPageState extends State<SaleListPage> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadTodaySales(); // Load today by default
  }

  void _loadTodaySales() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay
        .add(const Duration(days: 1))
        .subtract(const Duration(seconds: 1));

    setState(() => _selectedDate = startOfDay);
    context.read<SaleBloc>().add(
      LoadSalesByDateRange(startDate: startOfDay, endDate: endOfDay),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: Colors.green),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      final startOfDay = DateTime(picked.year, picked.month, picked.day);
      final endOfDay = startOfDay
          .add(const Duration(days: 1))
          .subtract(const Duration(seconds: 1));

      setState(() => _selectedDate = startOfDay);
      context.read<SaleBloc>().add(
        LoadSalesByDateRange(startDate: startOfDay, endDate: endOfDay),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Select Date',
            onPressed: _pickDate,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_selectedDate == null) {
                context.read<SaleBloc>().add(const LoadSales());
              } else {
                _pickDate(); // reload same day
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedDate == null
                      ? 'All Sales'
                      : 'Sales - ${dateFormat.format(_selectedDate!)}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedDate == null
                      ? 'Tap calendar to filter by day'
                      : 'Tap calendar to change date',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // Sales List + Summary
          Expanded(
            child: BlocBuilder<SaleBloc, SaleState>(
              builder: (context, state) {
                if (state is SalesLoadInProgress) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SalesLoadFailure) {
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
                        const Text('Failed to load sales'),
                        Text(state.error, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _selectedDate == null
                              ? () => context.read<SaleBloc>().add(
                                  const LoadSales(),
                                )
                              : _pickDate,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is SalesLoadSuccess) {
                  final sales = state.sales;

                  if (sales.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedDate == null
                                ? 'No sales recorded yet'
                                : 'No sales on ${dateFormat.format(_selectedDate!)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  // Calculate totals for the day
                  final totalRevenue = sales.fold<double>(
                    0,
                    (sum, sale) =>
                        sum +
                        sale.items.fold<double>(0, (s, i) => s + i.totalAmount),
                  );
                  final totalProfit = sales.fold<double>(
                    0,
                    (sum, sale) =>
                        sum +
                        sale.items.fold<double>(0, (s, i) => s + i.totalProfit),
                  );

                  return Column(
                    children: [
                      // Day Summary
                      Card(
                        margin: const EdgeInsets.all(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _summaryRow('Total Sales', '${sales.length}'),
                              _summaryRow(
                                'Revenue',
                                '₹${totalRevenue.toStringAsFixed(2)}',
                                valueColor: Colors.green,
                                bold: true,
                              ),
                              _summaryRow(
                                'Profit',
                                '₹${totalProfit.toStringAsFixed(2)}',
                                valueColor: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // List of sales
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            if (_selectedDate == null) {
                              context.read<SaleBloc>().add(const LoadSales());
                            } else {
                              _pickDate();
                            }
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemCount: sales.length,
                            itemBuilder: (context, index) {
                              return _SaleCard(sale: sales[index]);
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return const Center(child: Text('Select a date to view sales'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    Color? valueColor,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: valueColor,
              fontSize: bold ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sale Card Widget (unchanged, just cleaner)
class _SaleCard extends StatelessWidget {
  final Sale sale;
  const _SaleCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');
    final totalAmount = sale.items.fold<double>(0, (s, i) => s + i.totalAmount);
    final totalProfit = sale.items.fold<double>(0, (s, i) => s + i.totalProfit);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ListTile(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => EditSalePage(sale: sale))),
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Text(
            sale.items.length.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
        title: Text(
          sale.customerName ?? 'Walk-in Customer',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${sale.items.length} item${sale.items.length > 1 ? 's' : ''} • ${sale.paymentMethod.toUpperCase()}',
            ),
            Text(timeFormat.format(sale.createdAt)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            Text(
              '+₹${totalProfit.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
