import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/product_service.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<UpdateProductStock>(_onUpdateProductStock);
  }

  void _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductsLoadInProgress());
    try {
      final products = await ProductService.getProducts();
      emit(ProductsLoadSuccess(products: products));
    } catch (e) {
      emit(ProductsLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onAddProduct(
    AddProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await ProductService.createProduct(
        name: event.product['name'],
        categoryId: event.product['categoryId'],
        buyingPrice: event.product['buyingPrice'],
        sellingPrice: event.product['sellingPrice'],
        currentStock: event.product['currentStock'],
        barcode: event.product['barcode'],
        minStockLevel: event.product['minStockLevel'] ?? 10,
        supplierId: event.product['supplierId'],
      );

      // Reload products after adding
      add(LoadProducts());
    } catch (e) {
      emit(ProductOperationFailure(error: e.toString()));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await ProductService.updateProduct(
        id: event.product['id'],
        name: event.product['name'],
        categoryId: event.product['categoryId'],
        buyingPrice: event.product['buyingPrice'],
        sellingPrice: event.product['sellingPrice'],
        currentStock: event.product['currentStock'],
        barcode: event.product['barcode'],
        minStockLevel: event.product['minStockLevel'] ?? 10,
        supplierId: event.product['supplierId'],
      );

      // Reload products after updating
      add(LoadProducts());
    } catch (e) {
      emit(ProductOperationFailure(error: e.toString()));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await ProductService.deleteProduct(event.productId);
      // Reload products after deletion
      add(LoadProducts());
    } catch (e) {
      emit(ProductOperationFailure(error: e.toString()));
    }
  }

  Future<void> _onUpdateProductStock(
    UpdateProductStock event,
    Emitter<ProductState> emit,
  ) async {
    try {
      // For stock updates, we need to get the product first, then update
      final product = await ProductService.getProduct(event.productId);
      await ProductService.updateProduct(
        id: event.productId,
        name: product['name'],
        categoryId: product['categoryId'],
        buyingPrice: product['buyingPrice'],
        sellingPrice: product['sellingPrice'],
        currentStock: event.newStock,
        barcode: product['barcode'],
        minStockLevel: product['minStockLevel'] ?? 10,
        supplierId: product['supplierId'],
      );

      // Reload products after updating stock
      add(LoadProducts());
    } catch (e) {
      emit(ProductOperationFailure(error: e.toString()));
    }
  }
}
