// features/inventory/bloc/inventory_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_management/core/services/inventory_service.dart';
import 'package:shop_management/data/models/inventory_model.dart';
import 'package:shop_management/data/models/product_model.dart';

part 'inventory_event.dart';
part 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  InventoryBloc() : super(InventoryInitial()) {
    on<LoadInventoryDashboard>(_onLoadDashboard);
    on<LoadCategoryInventory>(_onLoadCategoryInventory);
    on<LoadRestockNeeded>(_onLoadRestockNeeded);
    on<LoadInventoryTurnover>(_onLoadTurnover);
  }

  Future<void> _onLoadDashboard(
    LoadInventoryDashboard event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    try {
      final results = await Future.wait([
        InventoryService.getInventorySummaryFromApi(),
        InventoryService.getStockAlertsFromApi(),
      ]);

      final summary = results[0] as InventorySummary;
      final alerts = results[1] as List<StockAlert>;

      emit(InventoryDashboardLoaded(summary: summary, alerts: alerts));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onLoadCategoryInventory(
    LoadCategoryInventory event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    try {
      final categoryData = await InventoryService.getCategoryInventoryFromApi();
      emit(CategoryInventoryLoaded(categoryData));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onLoadRestockNeeded(
    LoadRestockNeeded event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    try {
      final products =
          await InventoryService.getProductsNeedingRestockFromApi();
      emit(RestockNeededLoaded(products));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onLoadTurnover(
    LoadInventoryTurnover event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    try {
      final turnover = await InventoryService.getInventoryTurnoverFromApi(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(InventoryTurnoverLoaded(turnover));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }
}
