import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../blocs/auth/auth_bloc.dart';
import '../../../../blocs/report/report_bloc.dart';
import '../../../../data/models/report_model.dart';
import '../../../../core/utils/calculations.dart';

class SalesReportPage extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const SalesReportPage({
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
            appBar: AppBar(title: const Text('Sales Report')),
            body: const Center(child: Text('Please log in to view reports')),
          );
        }

        return BlocProvider(
          create: (context) => ReportBloc()
            ..add(LoadDailySalesReport(startDate: startDate, endDate: endDate)),
          child: Scaffold(
            appBar: AppBar(title: const Text('Sales Report')),
            body: BlocBuilder<ReportBloc, ReportState>(
              builder: (context, state) {
                if (state is ReportLoadInProgress) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DailySalesReportLoaded) {
                  final reports = state.reports;
                  return _SalesReportContent(
                    reports: reports,
                    startDate: startDate,
                    endDate: endDate,
                  );
                }

                if (state is ReportLoadFailure) {
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
                        Text(
                          'Failed to load sales report',
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
                              LoadDailySalesReport(
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
}

class _SalesReportContent extends StatefulWidget {
  final List<DailySalesReport> reports;
  final DateTime startDate;
  final DateTime endDate;

  const _SalesReportContent({
    required this.reports,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<_SalesReportContent> createState() => _SalesReportContentState();
}

class _SalesReportContentState extends State<_SalesReportContent> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final totalSales = widget.reports.fold<double>(
      0.0,
      (sum, report) => sum + report.totalSales,
    );
    final totalProfit = widget.reports.fold<double>(
      0.0,
      (sum, report) => sum + report.totalProfit,
    );
    final totalTransactions = widget.reports.fold<int>(
      0,
      (sum, report) => sum + report.totalTransactions,
    );
    final double averageSale = totalTransactions > 0
        ? totalSales / totalTransactions
        : 0.0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Summary Cards
          _buildSummaryCards(
            totalSales,
            totalProfit,
            totalTransactions,
            averageSale,
          ),
          const SizedBox(height: 16),
          // Sales Chart with Expand Button
          _buildSalesChart(widget.reports),
          const SizedBox(height: 16),
          // Daily Breakdown takes all remaining space
          Expanded(child: _buildDailyBreakdown(widget.reports)),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
    double totalSales,
    double totalProfit,
    int totalTransactions,
    double averageSale,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildSummaryCard(
          'Total Sales',
          Calculations.formatCurrency(totalSales),
          Colors.blue,
          Icons.shopping_cart,
        ),
        _buildSummaryCard(
          'Total Profit',
          Calculations.formatCurrency(totalProfit),
          Colors.green,
          Icons.attach_money,
        ),
        _buildSummaryCard(
          'Transactions',
          totalTransactions.toString(),
          Colors.orange,
          Icons.receipt,
        ),
        _buildSummaryCard(
          'Avg Sale',
          Calculations.formatCurrency(averageSale),
          Colors.purple,
          Icons.trending_up,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart(List<DailySalesReport> reports) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sales Trend',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            // Only show chart content when expanded
            if (_isExpanded) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 250,
                child: SfCartesianChart(
                  primaryXAxis: DateTimeAxis(
                    title: const AxisTitle(text: 'Date'),
                    dateFormat: DateFormat('MMM dd'),
                  ),
                  primaryYAxis: NumericAxis(
                    title: const AxisTitle(text: 'Amount (₹)'),
                    numberFormat: NumberFormat.currency(
                      symbol: '₹',
                      decimalDigits: 0,
                    ),
                  ),
                  legend: const Legend(isVisible: true),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CartesianSeries>[
                    LineSeries<DailySalesReport, DateTime>(
                      name: 'Sales',
                      dataSource: reports,
                      xValueMapper: (DailySalesReport report, _) => report.date,
                      yValueMapper: (DailySalesReport report, _) =>
                          report.totalSales,
                      markerSettings: const MarkerSettings(isVisible: true),
                      color: Colors.blue,
                    ),
                    LineSeries<DailySalesReport, DateTime>(
                      name: 'Profit',
                      dataSource: reports,
                      xValueMapper: (DailySalesReport report, _) => report.date,
                      yValueMapper: (DailySalesReport report, _) =>
                          report.totalProfit,
                      markerSettings: const MarkerSettings(isVisible: true),
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDailyBreakdown(List<DailySalesReport> reports) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daily Breakdown',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (!_isExpanded)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Full View',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: reports.isEmpty
                  ? const Center(
                      child: Text(
                        'No sales data available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return _buildDailyReportItem(report);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyReportItem(DailySalesReport report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(report.date),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${report.totalTransactions} transaction${report.totalTransactions == 1 ? '' : 's'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Margin: ${report.profitMargin.toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Calculations.formatCurrency(report.totalSales),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                Calculations.formatCurrency(report.totalProfit),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
