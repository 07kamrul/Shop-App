import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/services/report_service.dart';
import '../../data/models/report_model.dart';

part 'report_event.dart';
part 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  ReportBloc() : super(ReportInitial()) {
    on<LoadProfitLossReport>(_onLoadProfitLossReport);
    on<LoadDailySalesReport>(_onLoadDailySalesReport);
    on<LoadTopSellingProducts>(_onLoadTopSellingProducts);
  }

  Future<void> _onLoadProfitLossReport(
    LoadProfitLossReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoadInProgress());
    try {
      final reportData = await ReportService.getProfitLossReport(
        startDate: event.startDate,
        endDate: event.endDate,
      );

      // Convert the response to ProfitLossReport model
      final report = ProfitLossReport.fromJson(reportData);
      emit(ProfitLossReportLoaded(report: report));
    } catch (e) {
      emit(ReportLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onLoadDailySalesReport(
    LoadDailySalesReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoadInProgress());
    try {
      final reportsData = await ReportService.getDailySalesReport(
        startDate: event.startDate,
        endDate: event.endDate,
      );

      // Convert the response to List<DailySalesReport>
      final reports = reportsData
          .map((data) => DailySalesReport.fromJson(data))
          .toList();
      emit(DailySalesReportLoaded(reports: reports));
    } catch (e) {
      emit(ReportLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onLoadTopSellingProducts(
    LoadTopSellingProducts event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoadInProgress());
    try {
      final productsData = await ReportService.getTopSellingProducts(
        startDate: event.startDate,
        endDate: event.endDate,
        limit: event.limit,
      );

      // Convert the response to List<ProductSales>
      final products = productsData
          .map((data) => ProductSales.fromJson(data))
          .toList();
      emit(TopSellingProductsLoaded(products: products));
    } catch (e) {
      emit(ReportLoadFailure(error: e.toString()));
    }
  }
}
