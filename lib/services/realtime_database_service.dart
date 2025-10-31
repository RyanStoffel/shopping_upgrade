import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/data/categories.dart';

class RealtimeDatabaseService {
  final String _baseUrl = 'shopping-list-csc322-1a686-default-rtdb.firebaseio.com';
  final String _path = 'shopping-list';

  // Get all grocery items
  Future<List<GroceryItem>> getGroceryItems() async {
    final url = Uri.https(_baseUrl, '$_path.json');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load items: ${response.statusCode}');
    }

    final Map<String, dynamic>? data = json.decode(response.body);
    
    if (data == null) {
      return [];
    }

    final List<GroceryItem> items = [];
    data.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        try {
          final category = categories.entries
              .firstWhere(
                  (catItem) => catItem.value.title == value['category'])
              .value;
          
          items.add(GroceryItem(
            id: key,
            name: value['name'] as String,
            quantity: value['quantity'] as int,
            category: category,
            imageUrl: value['imageUrl'] as String?,
          ));
        } catch (e) {
          // Skip items with invalid category
          print('Error parsing item $key: $e');
        }
      }
    });

    return items;
  }

  // Delete grocery item
  Future<void> deleteGroceryItem(String itemId) async {
    final url = Uri.https(_baseUrl, '$_path/$itemId.json');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete item: ${response.statusCode}');
    }
  }
}

