import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/services/supplier_service.dart';
import '../../data/models/supplier_model.dart';

part 'supplier_event.dart';
part 'supplier_state.dart';

class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  SupplierBloc() : super(SupplierInitial()) {
    on<LoadSuppliers>(_onLoadSuppliers);
    on<SearchSuppliers>(_onSearchSuppliers);
    on<AddSupplier>(_onAddSupplier);
    on<UpdateSupplier>(_onUpdateSupplier);
    on<DeleteSupplier>(_onDeleteSupplier);
    on<LoadTopSuppliers>(_onLoadTopSuppliers);
  }

  Future<void> _onLoadSuppliers(
    LoadSuppliers event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SuppliersLoadInProgress());
    try {
      final suppliersData = await SupplierService.getSuppliers();
      final suppliers = suppliersData.map((data) => Supplier.fromJson(data)).toList();
      emit(SuppliersLoadSuccess(suppliers: suppliers));
    } catch (e) {
      emit(SuppliersLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onSearchSuppliers(
    SearchSuppliers event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SuppliersLoadInProgress());
    try {
      final suppliersData = await SupplierService.searchSuppliers(event.query);
      final suppliers = suppliersData.map((data) => Supplier.fromJson(data)).toList();
      emit(SuppliersLoadSuccess(suppliers: suppliers));
    } catch (e) {
      emit(SuppliersLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onAddSupplier(
    AddSupplier event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SupplierOperationInProgress());
    try {
      await SupplierService.createSupplier(
        name: event.supplier.name,
        contactPerson: event.supplier.contactPerson,
        phone: event.supplier.phone,
        email: event.supplier.email,
        address: event.supplier.address,
      );

      // Reload suppliers after adding
      add(const LoadSuppliers());
    } catch (e) {
      emit(SupplierOperationFailure(error: e.toString()));
    }
  }

  Future<void> _onUpdateSupplier(
    UpdateSupplier event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SupplierOperationInProgress());
    try {
      final id = event.supplier.id;
      if (id == null) {
        emit(SupplierOperationFailure(error: 'Supplier id is null'));
        return;
      }

      await SupplierService.updateSupplier(
        id: id,
        name: event.supplier.name,
        contactPerson: event.supplier.contactPerson,
        phone: event.supplier.phone,
        email: event.supplier.email,
        address: event.supplier.address,
      );

      // Reload suppliers after updating
      add(const LoadSuppliers());
    } catch (e) {
      emit(SupplierOperationFailure(error: e.toString()));
    }
  }

  Future<void> _onDeleteSupplier(
    DeleteSupplier event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SupplierOperationInProgress());
    try {
      await SupplierService.deleteSupplier(event.supplierId);
      
      // Reload suppliers after deletion
      add(const LoadSuppliers());
    } catch (e) {
      emit(SupplierOperationFailure(error: e.toString()));
    }
  }

  Future<void> _onLoadTopSuppliers(
    LoadTopSuppliers event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SuppliersLoadInProgress());
    try {
      final suppliersData = await SupplierService.getTopSuppliers(limit: event.limit);
      final suppliers = suppliersData.map((data) => Supplier.fromJson(data)).toList();
      emit(SuppliersLoadSuccess(suppliers: suppliers));
    } catch (e) {
      emit(SuppliersLoadFailure(error: e.toString()));
    }
  }
}