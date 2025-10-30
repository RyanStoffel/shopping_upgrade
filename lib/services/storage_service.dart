import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload image and get download URL
  Future<String?> uploadGroceryImage(String userId, String itemId, File imageFile) async {
    try {
      final ref = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('groceries')
          .child('$itemId.jpg');

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Delete image
  Future<void> deleteGroceryImage(String userId, String itemId) async {
    try {
      final ref = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('groceries')
          .child('$itemId.jpg');
      
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}

