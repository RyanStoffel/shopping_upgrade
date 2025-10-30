import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/data/categories.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user's grocery items stream
  Stream<List<GroceryItem>> getUserGroceryItems(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('groceries')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == data['category'])
            .value;
        
        return GroceryItem(
          id: doc.id,
          name: data['name'] as String,
          quantity: data['quantity'] as int,
          category: category,
          imageUrl: data['imageUrl'] as String?,
        );
      }).toList();
    });
  }

  // Add grocery item
  Future<String> addGroceryItem(
    String userId,
    String name,
    int quantity,
    String category,
    String? imageUrl,
  ) async {
    final docRef = await _firestore
        .collection('users')
        .doc(userId)
        .collection('groceries')
        .add({
      'name': name,
      'quantity': quantity,
      'category': category,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // Update grocery item
  Future<void> updateGroceryItem(
    String userId,
    String itemId,
    String name,
    int quantity,
    String category,
    String? imageUrl,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('groceries')
        .doc(itemId)
        .update({
      'name': name,
      'quantity': quantity,
      'category': category,
      'imageUrl': imageUrl,
    });
  }

  // Delete grocery item
  Future<void> deleteGroceryItem(String userId, String itemId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('groceries')
        .doc(itemId)
        .delete();
  }
}

