import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj_inz/data/api/api_client.dart';

class FavoriteRepository {
  final ApiClient _api;

  FavoriteRepository({ApiClient? api})
      : _api = api ?? ApiClient(baseUrl: 'http://49.13.155.21:8000');

  String get _userId {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not logged in');
    }
    return uid;
  }

  // ---------- SHOPS ----------

  Future<List<String>> getFavoriteShopIds() async {
    final response = await _api.get(
      '/shops/favorites/$_userId',
      useAuthToken: true,
    );
    final List data = response as List;
    return data.map((e) => e['id'].toString()).toList();
  }

  Future<void> addShopToFavorites(String shopId) async {
    await _api.post(
      '/shops/favorites/$shopId',
      queryParameters: {'user_id': _userId},
      useAuthToken: true,
    );
  }

  Future<void> removeShopFromFavorites(String shopId) async {
    await _api.delete(
      '/shops/favorites/$shopId',
      queryParameters: {'user_id': _userId},
      useAuthToken: true,
    );
  }

  // ---------- CATEGORIES ----------

  Future<List<String>> getFavoriteCategoryIds() async {
    final response = await _api.get(
      '/shops/categories/favorites/$_userId',
      useAuthToken: true,
    );
    final List data = response as List;
    return data.map((e) => e['id'].toString()).toList();
  }

  Future<void> addCategoryToFavorites(String categoryId) async {
    await _api.post(
      '/shops/categories/favorites/$categoryId',
      queryParameters: {'user_id': _userId},
      useAuthToken: true,
    );
  }

  Future<void> removeCategoryFromFavorites(String categoryId) async {
    await _api.delete(
      '/shops/categories/favorites/$categoryId',
      queryParameters: {'user_id': _userId},
      useAuthToken: true,
    );
  }
}