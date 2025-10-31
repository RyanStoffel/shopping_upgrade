import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/services/storage_service.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = StorageService();
  final _imagePicker = ImagePicker();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false;
  File? _selectedImage;

  Future<void> _pickImage() async {
    try {
      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        final file = File(pickedImage.path);
        if (await file.exists()) {
          setState(() {
            _selectedImage = file;
          });
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });

      try {
        String? imageUrl;

        // Upload image if one is selected
        if (_selectedImage != null) {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            throw Exception('User not logged in. Please sign in again.');
          }

          // Check if file exists
          if (!await _selectedImage!.exists()) {
            throw Exception('Selected image file not found');
          }

          // Generate a temporary ID for the upload
          final tempId = DateTime.now().millisecondsSinceEpoch.toString();
          try {
            imageUrl = await _storageService.uploadGroceryImage(
              user.uid,
              tempId,
              _selectedImage!,
            );

            if (imageUrl == null) {
              throw Exception('Failed to upload image: No URL returned');
            }
          } catch (e) {
            throw Exception('Failed to upload image: $e');
          }
        }

        final url = Uri.https(
            'shopping-list-csc322-1a686-default-rtdb.firebaseio.com',
            'shopping-list.json');
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(
            {
              'name': _enteredName,
              'quantity': _enteredQuantity,
              'category': _selectedCategory.title,
              if (imageUrl != null) 'imageUrl': imageUrl,
            },
          ),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to save item: ${response.statusCode}');
        }

        final Map<String, dynamic> resData = json.decode(response.body);

        if (!context.mounted) {
          return;
        }

        Navigator.of(context).pop(
          GroceryItem(
            id: resData['name'],
            name: _enteredName,
            quantity: _enteredQuantity,
            category: _selectedCategory,
            imageUrl: imageUrl,
          ),
        );
      } catch (error) {
        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save item: $error'),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );

        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters.';
                  }
                  return null;
                },
                onSaved: (value) {
                  // if (value == null) {
                  //   return;
                  // }
                  _enteredName = value!;
                },
              ), // instead of TextField()
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_selectedImage != null)
                    Expanded(
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade700,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  if (_selectedImage != null) const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _isSending ? null : _pickImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label:
                        Text(_selectedImage != null ? 'Change' : 'Add Image'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be a valid, positive number.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Add Item'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
