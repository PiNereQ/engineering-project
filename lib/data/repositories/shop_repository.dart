import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:proj_inz/data/models/shop_model.dart';

class ShopRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _shopCache = <String, Shop>{};

  Future<Shop> fetchShopById(String shopId) async {
    if (_shopCache.containsKey(shopId)) {
      return _shopCache[shopId]!;
    }

    try {
      final doc = await _firestore.collection('shops').doc(shopId).get();

      if (!doc.exists) {
        throw Exception("Shop with ID $shopId not found");
      }

      final data = doc.data()!;
      final shop = Shop(
        id: doc.id,
        name: data['name'] as String,
        bgColor: data['bgColor'] as int,
        nameColor: data['nameColor'] as int,
        categoryIds: List<String>.from(data['categoryIds'] ?? []),
      );

      _shopCache[shopId] = shop;
      return shop;
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching shop with ID $shopId: $e');
      rethrow;
    }
  }

  Future<List<Shop>> fetchAllShops() async {
    try {
      final querySnapshot = await _firestore.collection('shops').get();

      final shops = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Shop(
          id: doc.id,
          name: data['name'] as String,
          bgColor: data['bgColor'] as int,
          nameColor: data['nameColor'] as int,
          categoryIds: List<String>.from(data['categoryIds'] ?? []),
        );
      }).toList();

      for (final shop in shops) {
        _shopCache[shop.id] = shop;
      }

      return shops;
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching all shops: $e');
      rethrow;
    }
  }

  // szukanie sklepow po nazwie (prefixowe dopasowanie po nameLowercase)
  Future<List<Shop>> searchShopsByName(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final lowercaseQuery = query.toLowerCase();

    try {
      final querySnapshot = await _firestore
          .collection('shops')
          .where('nameLowercase', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('nameLowercase', isLessThan: lowercaseQuery + 'z')
          .get();

      final shops = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Shop(
          id: doc.id,
          name: data['name'] as String,
          bgColor: data['bgColor'] as int,
          nameColor: data['nameColor'] as int,
          categoryIds: List<String>.from(data['categoryIds'] ?? []),
        );
      }).toList();

      for (final shop in shops) {
        _shopCache[shop.id] = shop;
      }

      return shops;
    } catch (e) {
      if (kDebugMode) debugPrint('Error searching shops: $e');
      rethrow;
    }
  }

  void clearCache() {
    _shopCache.clear();
  }
}
