import 'api_service.dart';

class CategoryService {
  // Get all categories
  static Future<List<dynamic>> getCategories() async {
    final response = await ApiService.get('/categories');
    return List<dynamic>.from(response);
  }

  // Get category by ID
  static Future<dynamic> getCategory(String id) async {
    return await ApiService.get('/categories/$id');
  }

  // Create new category
  static Future<dynamic> createCategory({
    required String name,
    String? parentCategoryId,
    String? description,
    double? profitMarginTarget,
  }) async {
    final data = {
      'name': name,
      'parentCategoryId': parentCategoryId,
      'description': description,
      'profitMarginTarget': profitMarginTarget,
    };

    return await ApiService.post('/categories', data);
  }

  // Update category
  static Future<dynamic> updateCategory({
    required String id,
    required String name,
    String? parentCategoryId,
    String? description,
    double? profitMarginTarget,
  }) async {
    final data = {
      'name': name,
      'parentCategoryId': parentCategoryId,
      'description': description,
      'profitMarginTarget': profitMarginTarget,
    };

    return await ApiService.put('/categories/$id', data);
  }

  // Delete category
  static Future<void> deleteCategory(String id) async {
    await ApiService.delete('/categories/$id');
  }
}
