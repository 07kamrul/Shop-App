part of 'product_bloc.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

class ProductInitial extends ProductState {}

class ProductsLoadInProgress extends ProductState {}

class ProductsLoadSuccess extends ProductState {
  final List<dynamic> products;

  const ProductsLoadSuccess({required this.products});

  @override
  List<Object> get props => [products];
}

class ProductsLoadFailure extends ProductState {
  final String error;

  const ProductsLoadFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class ProductOperationInProgress extends ProductState {}

class ProductOperationSuccess extends ProductState {}

class ProductOperationFailure extends ProductState {
  final String error;

  const ProductOperationFailure({required this.error});

  @override
  List<Object> get props => [error];
}