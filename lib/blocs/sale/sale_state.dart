part of 'sale_bloc.dart';

abstract class SaleState extends Equatable {
  const SaleState();

  @override
  List<Object> get props => [];
}

class SaleInitial extends SaleState {}

class SalesLoadInProgress extends SaleState {}

class SalesLoadSuccess extends SaleState {
  final List<Sale> sales;

  const SalesLoadSuccess({required this.sales});

  @override
  List<Object> get props => [sales];
}

class SalesLoadFailure extends SaleState {
  final String error;

  const SalesLoadFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class SaleOperationInProgress extends SaleState {}

class SaleOperationSuccess extends SaleState {}

class SaleOperationFailure extends SaleState {
  final String error;

  const SaleOperationFailure({required this.error});

  @override
  List<Object> get props => [error];
}