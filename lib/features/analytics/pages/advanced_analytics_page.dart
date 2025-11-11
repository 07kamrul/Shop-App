import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_management/data/models/report_model.dart';
import 'package:shop_management/data/models/user_model.dart';
import '../../../../blocs/auth/auth_bloc.dart';
import '../../../../blocs/report/report_bloc.dart';
import '../../reports/widgets/profit_chart.dart';
import '../../reports/widgets/sales_pie_chart.dart';

class AdvancedAnalyticsPage extends StatefulWidget {
  const AdvancedAnalyticsPage({super.key});

  @override
  State<AdvancedAnalyticsPage> createState() => _AdvancedAnalyticsPageState();
}

class _AdvancedAnalyticsPageState extends State<AdvancedAnalyticsPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Show export dialog
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const Center(child: Text('Please log in to view analytics'));
          }

          final user = authState.user;

          return BlocProvider(
            create: (context) => ReportBloc()
              ..add(
                LoadDailySalesReport(
                  startDate: _startDate,
                  endDate: _endDate,
                ),
              )
              ..add(
                LoadTopSellingProducts(
                  startDate: _startDate,
                  endDate: _endDate,
                ),
              ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDateRangeSelector(context, user),
                  const SizedBox(height: 20),
                  Expanded(
                    child: BlocBuilder<ReportBloc, ReportState>(
                      builder: (context, state) {
                        if (state is ReportLoadInProgress) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (state is ReportLoadFailure) {
                          return Center(child: Text('Error: ${state.error}'));
                        }

                        // Handle multiple loaded states
                        List<DailySalesReport> dailyReports = [];
                        List<ProductSales> topProducts = [];

                        // We need to track which events have been completed
                        bool hasDailySales = false;
                        bool hasTopProducts = false;

                        // Check if we have the required data
                        if (state is DailySalesReportLoaded) {
                          dailyReports = state.reports;
                          hasDailySales = true;
                        }

                        if (state is TopSellingProductsLoaded) {
                          topProducts = state.products;
                          hasTopProducts = true;
                        }

                        // If we have both data sets, show the charts
                        if (hasDailySales && hasTopProducts) {
                          return ListView(
                            children: [
                              SizedBox(
                                height: 300,
                                child: ProfitChart(reports: dailyReports),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 300,
                                child: SalesPieChart(topProducts: topProducts),
                              ),
                            ],
                          );
                        }

                        // If we're still loading individual reports
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context, User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('From Date'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _selectStartDate(context, user),
                    child: Text(
                      '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('To Date'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _selectEndDate(context, user),
                    child: Text(
                      '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context, User user) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
      _refreshData(context, user);
    }
  }

  Future<void> _selectEndDate(BuildContext context, User user) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
      _refreshData(context, user);
    }
  }

  void _refreshData(BuildContext context, User user) {
    context.read<ReportBloc>()
      ..add(
        LoadDailySalesReport(
          startDate: _startDate,
          endDate: _endDate,
        ),
      )
      ..add(
        LoadTopSellingProducts(
          startDate: _startDate,
          endDate: _endDate,
        ),
      );
  }
}