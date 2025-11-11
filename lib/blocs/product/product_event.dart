part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class LoadProducts extends ProductEvent {}

class AddProduct extends ProductEvent {
  final Map<String, dynamic> product;

  const AddProduct({required this.product});

  @override
  List<Object> get props => [product];
}

class UpdateProduct extends ProductEvent {
  final Map<String, dynamic> product;

  const UpdateProduct({required this.product});

  @override
  List<Object> get props => [product];
}

class DeleteProduct extends ProductEvent {
  final String productId;

  const DeleteProduct({required this.productId});

  @override
  List<Object> get props => [productId];
}

class UpdateProductStock extends ProductEvent {
  final String productId;
  final int newStock;

  const UpdateProductStock({required this.productId, required this.newStock});

  @override
  List<Object> get props => [productId, newStock];
}
