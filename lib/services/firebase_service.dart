import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  FirebaseService({required this.userId});

  // Add meal to favorites
  Future<void> addFavorite(Meal meal) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(meal.id)
          .set({
        'id': meal.id,
        'name': meal.name,
        'thumbnail': meal.thumbnail,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding favorite: $e');
      rethrow;
    }
  }

  // Remove meal from favorites
  Future<void> removeFavorite(String mealId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(mealId)
          .delete();
    } catch (e) {
      print('Error removing favorite: $e');
      rethrow;
    }
  }

  // Check if a meal is in favorites
  Future<bool> isFavorite(String mealId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(mealId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }

  // Get all favorite meals as a stream
  Stream<List<Meal>> getFavorites() {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Meal.fromFirestore(data);
      }).toList();
    });
  }

  // Get all favorite meals as a future (for one-time fetch)
  Future<List<Meal>> getFavoritesList() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .orderBy('addedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Meal.fromFirestore(data);
      }).toList();
    } catch (e) {
      print('Error getting favorites list: $e');
      return [];
    }
  }

  // Get favorite count
  Future<int> getFavoritesCount() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting favorites count: $e');
      return 0;
    }
  }

  // Clear all favorites
  Future<void> clearAllFavorites() async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error clearing favorites: $e');
      rethrow;
    }
  }
}