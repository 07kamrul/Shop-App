part of 'sale_bloc.dart';

abstract class SaleEvent extends Equatable {
  const SaleEvent();

  @override
  List<Object> get props => [];
}

class LoadSales extends SaleEvent {
  const LoadSales();

  @override
  List<Object> get props => [];
}

class LoadSalesByDateRange extends SaleEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadSalesByDateRange({required this.startDate, required this.endDate});

  @override
  List<Object> get props => [startDate, endDate];
}

class LoadTodaySales extends SaleEvent {
  const LoadTodaySales();

  @override
  List<Object> get props => [];
}

class AddSale extends SaleEvent {
  final Sale sale;

  const AddSale({required this.sale});

  @override
  List<Object> get props => [sale];
}

class DeleteSale extends SaleEvent {
  final String saleId;

  const DeleteSale({required this.saleId});

  @override
  List<Object> get props => [saleId];
}

class UpdateSale extends SaleEvent {
  final String saleId;
  final Sale updatedSale;

  const UpdateSale({required this.saleId, required this.updatedSale});

  @override
  List<Object> get props => [saleId, updatedSale];
}
