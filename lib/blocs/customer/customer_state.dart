part of 'customer_bloc.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomersLoadInProgress extends CustomerState {}

class CustomersLoadSuccess extends CustomerState {
  final List<Customer> customers;

  const CustomersLoadSuccess({required this.customers});

  @override
  List<Object> get props => [customers];
}

class CustomersLoadFailure extends CustomerState {
  final String error;

  const CustomersLoadFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class CustomerOperationInProgress extends CustomerState {}

class CustomerOperationSuccess extends CustomerState {}

class CustomerOperationFailure extends CustomerState {
  final String error;

  const CustomerOperationFailure({required this.error});

  @override
  List<Object> get props => [error];
}