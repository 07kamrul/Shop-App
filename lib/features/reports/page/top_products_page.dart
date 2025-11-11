import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../blocs/auth/auth_bloc.dart';
import '../../../../blocs/report/report_bloc.dart';
import '../../../../data/models/report_model.dart';
import '../../../../core/utils/calculations.dart';

class TopProductsPage extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const TopProductsPage({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return Scaffold(
            appBar: AppBar(title: const Text('Top Products')),
            body: const Center(child: Text('Please log in to view reports')),
          );
        }

        return BlocProvider(
          create: (context) => ReportBloc()
            ..add(
              LoadTopSellingProducts(
                startDate: startDate,
                endDate: endDate,
              ),
            ),
          child: Scaffold(
            appBar: AppBar(title: const Text('Top Products')),
            body: BlocBuilder<ReportBloc, ReportState>(
              builder: (context, state) {
                if (state is ReportLoadInProgress) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TopSellingProductsLoaded) {
                  final products = state.products;
                  return _buildTopProductsContent(products);
                }

                if (state is ReportLoadFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load top products',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.error,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ReportBloc>().add(
                              LoadTopSellingProducts(
                                startDate: startDate,
                                endDate: endDate,
                              ),
                            );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return const Center(child: Text('Load report to see data'));
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopProductsContent(List<ProductSales> products) {
    final totalSales = products.fold<double>(
      0.0,
      (sum, product) => sum + product.totalSales,
    );
    final totalProfit = products.fold<double>(
      0.0,
      (sum, product) => sum + product.totalProfit,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Summary
          _buildSummary(totalSales, totalProfit, products.length),
          const SizedBox(height: 20),

          // Products Chart
          Expanded(flex: 2, child: _buildProductsChart(products)),

          // Products List
          const SizedBox(height: 20),
          Expanded(flex: 3, child: _buildProductsList(products)),
        ],
      ),
    );
  }

  Widget _buildSummary(
    double totalSales,
    double totalProfit,
    int productCount,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(
              'Total Sales',
              Calculations.formatCurrency(totalSales),
              Colors.blue,
            ),
            _buildSummaryItem(
              'Total Profit',
              Calculations.formatCurrency(totalProfit),
              Colors.green,
            ),
            _buildSummaryItem(
              'Products',
              productCount.toString(),
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildProductsChart(List<ProductSales> products) {
    final topProducts = products.take(5).toList();
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Products by Sales',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: topProducts.isEmpty
                  ? const Center(
                      child: Text(
                        'No product data available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : SfCircularChart(
                      legend: const Legend(
                        isVisible: true,
                        overflowMode: LegendItemOverflowMode.wrap,
                        position: LegendPosition.bottom,
                      ),
                      tooltipBehavior: TooltipBehavior(
                        enable: true,
                        format: 'point.x : ₹point.y',
                      ),
                      series: <CircularSeries>[
                        DoughnutSeries<ProductSales, String>(
                          dataSource: topProducts,
                          xValueMapper: (ProductSales sales, _) => sales.productName,
                          yValueMapper: (ProductSales sales, _) => sales.totalSales,
                          dataLabelMapper: (ProductSales sales, _) =>
                              '${sales.productName}\n₹${sales.totalSales.toStringAsFixed(0)}',
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside,
                            textStyle: TextStyle(fontSize: 10),
                          ),
                          enableTooltip: true,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList(List<ProductSales> products) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product Performance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: products.isEmpty
                  ? const Center(
                      child: Text(
                        'No products found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _buildProductItem(product, index + 1);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(ProductSales product, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.quantitySold} units sold',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  'Margin: ${product.profitMargin.toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Calculations.formatCurrency(product.totalSales),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                Calculations.formatCurrency(product.totalProfit),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '₹${product.profitPerUnit.toStringAsFixed(2)}/unit',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.blue.shade400;
    }
  }
}