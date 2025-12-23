import 'package:flutter/foundation.dart' hide Category;
import 'package:proj_inz/core/utils/utils.dart';
import 'package:proj_inz/data/models/category_model.dart';
import 'package:proj_inz/data/models/shop_model.dart';
import 'package:proj_inz/data/api/api_client.dart';

class CategoryRepository {
  final ApiClient _api;

  CategoryRepository({ApiClient? api}) : _api = api ?? ApiClient(baseUrl: 'http://49.13.155.21:8000');

  /// Search categories by name (GET /categories and filter client-side)
  Future<List<Category>> searchCategoriesByName(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await _api.get('/categories');
      final List<dynamic> categoriesData = response is List ? response : [];
      
      final lowercaseQuery = query.toLowerCase();
      
      return categoriesData
          .where((data) => (data['name'] as String).toLowerCase().contains(lowercaseQuery))
          .map((data) => Category(
                id: data['id'].toString(),
                name: data['name'] as String,
              ))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('Error searching categories: $e');
      rethrow;
    }
  }

  /// Fetch shops by category (GET /shops and filter by category)
  Future<List<Shop>> fetchShopsByCategory(Category category) async {
    try {
      final response = await _api.get('/shops');
      final List<dynamic> shopsData = response is List ? response : [];
      
      // Filter shops that belong to this category
      // Note: This assumes categories field in response contains category info
      return shopsData
          .where((data) {
            // Check if shop has this category
            final categories = data['categories'] as String?;
            return categories != null && categories.contains(category.name);
          })
          .map((data) => Shop(
                id: data['id'].toString(),
                name: data['name'] as String,
                bgColor: parseColor(data['bg_color']),
                nameColor: parseColor(data['name_color']),
                categoryIds: [category.id],
              ))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching shops for category ${category.name}: $e');
      rethrow;
    }
  }
}
