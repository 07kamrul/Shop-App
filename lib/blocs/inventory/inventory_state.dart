// features/inventory/bloc/inventory_state.dart
part of 'inventory_bloc.dart';

abstract class InventoryState extends Equatable {
  const InventoryState();
  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryDashboardLoaded extends InventoryState {
  final InventorySummary summary;
  final List<StockAlert> alerts;
  const InventoryDashboardLoaded({required this.summary, required this.alerts});
  @override
  List<Object?> get props => [summary, alerts];
}

class CategoryInventoryLoaded extends InventoryState {
  final List<CategoryInventory> categories;
  const CategoryInventoryLoaded(this.categories);
  @override
  List<Object?> get props => [categories];
}

class RestockNeededLoaded extends InventoryState {
  final List<Product> products;
  const RestockNeededLoaded(this.products);
  @override
  List<Object?> get props => [products];
}

class InventoryTurnoverLoaded extends InventoryState {
  final double turnover;
  const InventoryTurnoverLoaded(this.turnover);
  @override
  List<Object?> get props => [turnover];
}

class InventoryError extends InventoryState {
  final String message;
  const InventoryError(this.message);
  @override
  List<Object?> get props => [message];
}
