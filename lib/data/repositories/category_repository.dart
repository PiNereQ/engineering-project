import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proj_inz/data/models/category_model.dart';
import 'package:proj_inz/data/models/shop_model.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // szukanie kategorii po nazwie (prefixowe dopasowanie po name)
  Future<List<Category>> searchCategoriesByName(String query) async {
    if (query.isEmpty) return [];

    final lowercaseQuery = query.toLowerCase();

    final snapshot = await _firestore
        .collection('categories')
        .where('name', isGreaterThanOrEqualTo: lowercaseQuery)
        .where('name', isLessThan: lowercaseQuery + 'z')
        .get();

    return snapshot.docs.map((doc) {
      return Category(
        id: doc.id,
        name: doc['name'],
      );
    }).toList();
  }

  // pobieranie sklepow przypisanych do danej kategorii
  Future<List<Shop>> fetchShopsByCategory(Category category) async {
    final querySnapshot = await _firestore
        .collection('shops')
        .where('categoryIds', arrayContains: category.id)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Shop(
        id: doc.id,
        name: data['name'],
        bgColor: data['bgColor'],
        nameColor: data['nameColor'],
        categoryIds: List<String>.from(data['categoryIds'] ?? []),
      );
    }).toList();
  }
}
