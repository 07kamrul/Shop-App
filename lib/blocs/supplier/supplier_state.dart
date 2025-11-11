part of 'supplier_bloc.dart';

abstract class SupplierState extends Equatable {
  const SupplierState();

  @override
  List<Object> get props => [];
}

class SupplierInitial extends SupplierState {}

class SuppliersLoadInProgress extends SupplierState {}

class SuppliersLoadSuccess extends SupplierState {
  final List<Supplier> suppliers;

  const SuppliersLoadSuccess({required this.suppliers});

  @override
  List<Object> get props => [suppliers];
}

class SuppliersLoadFailure extends SupplierState {
  final String error;

  const SuppliersLoadFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class SupplierOperationInProgress extends SupplierState {}

class SupplierOperationSuccess extends SupplierState {}

class SupplierOperationFailure extends SupplierState {
  final String error;

  const SupplierOperationFailure({required this.error});

  @override
  List<Object> get props => [error];
}