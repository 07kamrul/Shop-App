import 'api_service.dart';

class ProductService {
  // Get all products
  static Future<List<dynamic>> getProducts() async {
    final response = await ApiService.get('/products');
    return List<dynamic>.from(response);
  }

  // Get product by ID
  static Future<dynamic> getProduct(String id) async {
    return await ApiService.get('/products/$id');
  }

  // Create new product
  static Future<dynamic> createProduct({
    required String name,
    required String categoryId,
    required double buyingPrice,
    required double sellingPrice,
    required int currentStock,
    String? barcode,
    int minStockLevel = 10,
    String? supplierId,
  }) async {
    final data = {
      'name': name,
      'barcode': barcode,
      'categoryId': categoryId,
      'buyingPrice': buyingPrice,
      'sellingPrice': sellingPrice,
      'currentStock': currentStock,
      'minStockLevel': minStockLevel,
      'supplierId': supplierId,
    };

    return await ApiService.post('/products', data);
  }

  // Update product
  static Future<dynamic> updateProduct({
    required String id,
    required String name,
    required String categoryId,
    required double buyingPrice,
    required double sellingPrice,
    required int currentStock,
    String? barcode,
    int minStockLevel = 10,
    String? supplierId,
  }) async {
    final data = {
      'name': name,
      'barcode': barcode,
      'categoryId': categoryId,
      'buyingPrice': buyingPrice,
      'sellingPrice': sellingPrice,
      'currentStock': currentStock,
      'minStockLevel': minStockLevel,
      'supplierId': supplierId,
    };

    return await ApiService.put('/products/$id', data);
  }

  // Delete product
  static Future<void> deleteProduct(String id) async {
    await ApiService.delete('/products/$id');
  }

  // Get low stock products
  static Future<List<dynamic>> getLowStockProducts() async {
    final response = await ApiService.get('/products/low-stock');
    return List<dynamic>.from(response);
  }

  // Search products
  static Future<List<dynamic>> searchProducts(String query) async {
    final response = await ApiService.get(
      '/products/search',
      queryParams: {'query': query},
    );
    return List<dynamic>.from(response);
  }
}
