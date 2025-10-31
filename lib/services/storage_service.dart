import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload image and get download URL
  Future<String?> uploadGroceryImage(String userId, String itemId, File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist at path: ${imageFile.path}');
      }

      final ref = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('groceries')
          .child('$itemId.jpg');

      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
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

