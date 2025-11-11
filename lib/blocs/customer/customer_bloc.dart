import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/services/customer_service.dart';
import '../../data/models/customer_model.dart';

part 'customer_event.dart';
part 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  CustomerBloc() : super(CustomerInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<SearchCustomers>(_onSearchCustomers);
    on<AddCustomer>(_onAddCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
    on<LoadTopCustomers>(_onLoadTopCustomers);
  }

  Future<void> _onLoadCustomers(
    LoadCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomersLoadInProgress());
    try {
      final customersData = await CustomerService.getCustomers();
      final customers = customersData.map((data) => Customer.fromJson(data)).toList();
      emit(CustomersLoadSuccess(customers: customers));
    } catch (e) {
      emit(CustomersLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onSearchCustomers(
    SearchCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomersLoadInProgress());
    try {
      final customersData = await CustomerService.searchCustomers(event.query);
      final customers = customersData.map((data) => Customer.fromJson(data)).toList();
      emit(CustomersLoadSuccess(customers: customers));
    } catch (e) {
      emit(CustomersLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onAddCustomer(
    AddCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerOperationInProgress());
    try {
      await CustomerService.createCustomer(
        name: event.customer.name,
        phone: event.customer.phone,
        email: event.customer.email,
        address: event.customer.address,
      );

      // Reload customers after adding
      add(const LoadCustomers());
    } catch (e) {
      emit(CustomerOperationFailure(error: e.toString()));
    }
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerOperationInProgress());
    try {
      final id = event.customer.id;
      if (id == null) {
        emit(CustomerOperationFailure(error: 'Customer id is null'));
        return;
      }

      await CustomerService.updateCustomer(
        id: id,
        name: event.customer.name,
        phone: event.customer.phone,
        email: event.customer.email,
        address: event.customer.address,
      );

      // Reload customers after updating
      add(const LoadCustomers());
    } catch (e) {
      emit(CustomerOperationFailure(error: e.toString()));
    }
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerOperationInProgress());
    try {
      await CustomerService.deleteCustomer(event.customerId);
      
      // Reload customers after deletion
      add(const LoadCustomers());
    } catch (e) {
      emit(CustomerOperationFailure(error: e.toString()));
    }
  }

  Future<void> _onLoadTopCustomers(
    LoadTopCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomersLoadInProgress());
    try {
      final customersData = await CustomerService.getTopCustomers(limit: event.limit);
      final customers = customersData.map((data) => Customer.fromJson(data)).toList();
      emit(CustomersLoadSuccess(customers: customers));
    } catch (e) {
      emit(CustomersLoadFailure(error: e.toString()));
    }
  }
}