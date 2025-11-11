part of 'report_bloc.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object> get props => [];
}

class LoadProfitLossReport extends ReportEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadProfitLossReport({required this.startDate, required this.endDate});

  @override
  List<Object> get props => [startDate, endDate];
}

class LoadDailySalesReport extends ReportEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadDailySalesReport({required this.startDate, required this.endDate});

  @override
  List<Object> get props => [startDate, endDate];
}

class LoadTopSellingProducts extends ReportEvent {
  final DateTime startDate;
  final DateTime endDate;
  final int limit;

  const LoadTopSellingProducts({
    required this.startDate,
    required this.endDate,
    this.limit = 10,
  });

  @override
  List<Object> get props => [startDate, endDate, limit];
}
