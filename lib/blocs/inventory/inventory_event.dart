// features/inventory/bloc/inventory_event.dart
part of 'inventory_bloc.dart';

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadInventoryDashboard extends InventoryEvent {}

class LoadCategoryInventory extends InventoryEvent {}

class LoadRestockNeeded extends InventoryEvent {}

class LoadInventoryTurnover extends InventoryEvent {
  final DateTime startDate;
  final DateTime endDate;
  const LoadInventoryTurnover(this.startDate, this.endDate);
  @override
  List<Object?> get props => [startDate, endDate];
}
