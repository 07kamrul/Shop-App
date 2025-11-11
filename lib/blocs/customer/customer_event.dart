part of 'customer_bloc.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object> get props => [];
}

class LoadCustomers extends CustomerEvent {
  const LoadCustomers();

  @override
  List<Object> get props => [];
}

class SearchCustomers extends CustomerEvent {
  final String query;

  const SearchCustomers({required this.query});

  @override
  List<Object> get props => [query];
}

class AddCustomer extends CustomerEvent {
  final Customer customer;

  const AddCustomer({required this.customer});

  @override
  List<Object> get props => [customer];
}

class UpdateCustomer extends CustomerEvent {
  final Customer customer;

  const UpdateCustomer({required this.customer});

  @override
  List<Object> get props => [customer];
}

class DeleteCustomer extends CustomerEvent {
  final String customerId;

  const DeleteCustomer({required this.customerId});

  @override
  List<Object> get props => [customerId];
}

class LoadTopCustomers extends CustomerEvent {
  final int limit;

  const LoadTopCustomers({this.limit = 10});

  @override
  List<Object> get props => [limit];
}