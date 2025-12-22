import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/services/sale_service.dart';
import '../../data/models/sale_model.dart';

part 'sale_event.dart';
part 'sale_state.dart';

class SaleBloc extends Bloc<SaleEvent, SaleState> {
  SaleBloc() : super(SaleInitial()) {
    on<LoadSales>(_onLoadSales);
    on<LoadSalesByDateRange>(_onLoadSalesByDateRange);
    on<LoadTodaySales>(_onLoadTodaySales);
    on<AddSale>(_onAddSale);
    on<UpdateSale>(_onUpdateSale); // <-- Add this
    on<DeleteSale>(_onDeleteSale);
  }

  Future<void> _onLoadSales(LoadSales event, Emitter<SaleState> emit) async {
    emit(SalesLoadInProgress());
    try {
      final salesData = await SaleService.getSales();
      final sales = salesData.map((data) => Sale.fromJson(data)).toList();
      emit(SalesLoadSuccess(sales: sales));
    } catch (e) {
      emit(SalesLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onLoadSalesByDateRange(
    LoadSalesByDateRange event,
    Emitter<SaleState> emit,
  ) async {
    emit(SalesLoadInProgress());
    try {
      final salesData = await SaleService.getSales(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      final sales = salesData.map((data) => Sale.fromJson(data)).toList();
      emit(SalesLoadSuccess(sales: sales));
    } catch (e) {
      emit(SalesLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onLoadTodaySales(
    LoadTodaySales event,
    Emitter<SaleState> emit,
  ) async {
    emit(SalesLoadInProgress());
    try {
      final salesData = await SaleService.getTodaySales();
      final sales = salesData.map((data) => Sale.fromJson(data)).toList();
      emit(SalesLoadSuccess(sales: sales));
    } catch (e) {
      emit(SalesLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onAddSale(AddSale event, Emitter<SaleState> emit) async {
    emit(SaleOperationInProgress());
    try {
      await SaleService.createSale(
        customerId: event.sale.customerId,
        customerName: event.sale.customerName,
        customerPhone: event.sale.customerPhone,
        paymentMethod: event.sale.paymentMethod,
        items: event.sale.items.map((item) => item.toJson()).toList(),
      );

      // Reload sales after adding
      add(const LoadSales());
    } catch (e) {
      emit(SaleOperationFailure(error: e.toString()));
    }
  }

  Future<void> _onUpdateSale(UpdateSale event, Emitter<SaleState> emit) async {
    emit(SaleOperationInProgress());
    try {
      await SaleService.updateSale(
        saleId: event.saleId,
        customerId: event.updatedSale.customerId,
        customerName: event.updatedSale.customerName,
        customerPhone: event.updatedSale.customerPhone,
        paymentMethod: event.updatedSale.paymentMethod,
        items: event.updatedSale.items.map((item) => item.toJson()).toList(),
      );

      // Reload sales after update
      add(const LoadSales());
    } catch (e) {
      emit(SaleOperationFailure(error: e.toString()));
    }
  }

  Future<void> _onDeleteSale(DeleteSale event, Emitter<SaleState> emit) async {
    emit(SaleOperationInProgress());
    try {
      await SaleService.deleteSale(event.saleId);

      // Reload sales after deletion
      add(const LoadSales());
    } catch (e) {
      emit(SaleOperationFailure(error: e.toString()));
    }
  }
}
