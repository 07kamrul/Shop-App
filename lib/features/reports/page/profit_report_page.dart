import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/auth/auth_bloc.dart';
import '../../../../blocs/report/report_bloc.dart';
import '../../../../data/models/report_model.dart';
import '../../../../core/utils/calculations.dart';

class ProfitReportPage extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const ProfitReportPage({
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
            appBar: AppBar(title: const Text('Profit & Loss Report')),
            body: const Center(child: Text('Please log in to view reports')),
          );
        }

        return BlocProvider(
          create: (context) => ReportBloc()
            ..add(
              LoadProfitLossReport(
                startDate: startDate,
                endDate: endDate,
              ),
            ),
          child: Scaffold(
            appBar: AppBar(title: const Text('Profit & Loss Report')),
            body: BlocBuilder<ReportBloc, ReportState>(
              builder: (context, state) {
                if (state is ReportLoadInProgress) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ProfitLossReportLoaded) {
                  final report = state.report;
                  return _buildProfitReportContent(report);
                }

                if (state is ReportLoadFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load report',
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
                              LoadProfitLossReport(
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

  Widget _buildProfitReportContent(ProfitLossReport report) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Summary Cards
          _buildSummaryCards(report),
          const SizedBox(height: 20),

          // Detailed Breakdown
          Expanded(child: _buildDetailedBreakdown(report)),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(ProfitLossReport report) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildSummaryCard(
          'Total Revenue',
          Calculations.formatCurrency(report.totalRevenue),
          Colors.green,
          Icons.arrow_upward,
        ),
        _buildSummaryCard(
          'Total Cost',
          Calculations.formatCurrency(report.totalCost),
          Colors.orange,
          Icons.shopping_cart,
        ),
        _buildSummaryCard(
          'Gross Profit',
          Calculations.formatCurrency(report.grossProfit),
          Colors.blue,
          Icons.attach_money,
        ),
        _buildSummaryCard(
          'Profit Margin',
          Calculations.formatPercentage(report.grossProfitMargin),
          Colors.purple,
          Icons.percent,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedBreakdown(ProfitLossReport report) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detailed Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildBreakdownItem(
                    'Total Revenue',
                    report.totalRevenue,
                    Colors.green,
                  ),
                  _buildBreakdownItem(
                    'Cost of Goods Sold',
                    report.totalCost,
                    Colors.orange,
                  ),
                  _buildBreakdownItem(
                    'Gross Profit',
                    report.grossProfit,
                    Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _buildProfitMarginItem(report.grossProfitMargin),
                  if (report.operatingExpenses != null) ...[
                    const SizedBox(height: 16),
                    _buildBreakdownItem(
                      'Operating Expenses',
                      report.operatingExpenses!,
                      Colors.red,
                    ),
                  ],
                  if (report.netProfit != null) ...[
                    const SizedBox(height: 16),
                    _buildBreakdownItem(
                      'Net Profit',
                      report.netProfit!,
                      Colors.green,
                    ),
                  ],
                  if (report.netProfitMargin != null) ...[
                    const SizedBox(height: 16),
                    _buildProfitMarginItem(
                      report.netProfitMargin!,
                      label: 'Net Profit Margin',
                      color: Colors.green,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildDateRangeInfo(report.startDate, report.endDate),
                  if (report.categoryBreakdown.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildCategoryBreakdown(report.categoryBreakdown),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            Calculations.formatCurrency(value),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitMarginItem(
    double margin, {
    String label = 'Profit Margin',
    Color color = Colors.blue,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            Calculations.formatPercentage(margin),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(List<CategoryReport> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category Breakdown',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...categories.map((category) => _buildCategoryItem(category)),
      ],
    );
  }

  Widget _buildCategoryItem(CategoryReport category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.categoryName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sales: ${Calculations.formatCurrency(category.totalSales)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  'Profit: ${Calculations.formatCurrency(category.totalProfit)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  'Margin: ${Calculations.formatPercentage(category.profitMargin)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeInfo(DateTime startDate, DateTime endDate) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Report Period: ${_formatDate(startDate)} - ${_formatDate(endDate)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}