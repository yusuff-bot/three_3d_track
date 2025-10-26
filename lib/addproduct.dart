import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class AddProductScreen extends StatefulWidget {
  final String categoryName;
  final String categoryId;
  final String subCategoryName;
  final String subCategoryId;

  const AddProductScreen({
    super.key,
    required this.categoryName,
    required this.categoryId,
    required this.subCategoryName,
    required this.subCategoryId,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _materialController = TextEditingController();
  final _colorController = TextEditingController();
  final _heightController = TextEditingController();
  final _widthController = TextEditingController();
  final _lengthController = TextEditingController();

  List<String> _uploadedPhotos = [];
  String? _photoUrl;
  String? _stlFileUrl;

  // Dynamic categories
  String? selectedParent;
  String? selectedSubCategory;
  List<String> parentCategories = [];
  List<String> subCategories = [];

  @override
  void initState() {
    super.initState();
    loadParentCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _materialController.dispose();
    _colorController.dispose();
    _heightController.dispose();
    _widthController.dispose();
    _lengthController.dispose();
    super.dispose();
  }

  // --- FIRESTORE FETCH METHODS ---
  Future<void> loadParentCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    parentCategories = snapshot.docs
        .map((doc) => doc['parentCategory'] as String)
        .toSet()
        .toList();
    setState(() {});
  }

  Future<void> loadSubCategories(String parent) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('parentCategory', isEqualTo: parent)
        .get();
    subCategories = snapshot.docs
        .map((doc) => doc['category'] as String)
        .toSet()
        .toList();
    setState(() {});
  }

  // --- FILE PICKING ---
  Future<void> _pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null) {
      List<String> uploadedUrls = [];
      for (final file in result.files) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('products/${file.name}');
        await ref.putData(file.bytes!);
        final url = await ref.getDownloadURL();
        uploadedUrls.add(url);
      }
      setState(() {
        _photoUrl = uploadedUrls.first;
        _uploadedPhotos = uploadedUrls;
      });
    }
  }

  Future<void> _pickSTLFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['stl'],
    );
    if (result != null) {
      final file = result.files.first;
      final ref = FirebaseStorage.instance
          .ref()
          .child('products/${file.name}');
      await ref.putData(file.bytes!);
      final url = await ref.getDownloadURL();
      setState(() {
        _stlFileUrl = url;
      });
    }
  }

  // --- SAVE PRODUCT ---
  Future<void> _saveProduct() async {
    final name = _nameController.text.trim();
    final price = _priceController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty ||
        price.isEmpty ||
        _photoUrl == null ||
        _stlFileUrl == null ||
        selectedParent == null ||
        selectedSubCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and upload files')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'name': name,
        'price': price,
        'description': description,
        'imageUrls': _uploadedPhotos.isNotEmpty ? _uploadedPhotos : [_photoUrl],
        'modelUrl': _stlFileUrl,
        'material': _materialController.text.trim(),
        'colors': _colorController.text.trim().split(','), // comma separated colors
        'sizes': ['S', 'M', 'L'], // Optional: you can add a size picker later
        'category': selectedSubCategory,
        'parentCategory': selectedParent,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Price
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Material
            TextField(
              controller: _materialController,
              decoration: const InputDecoration(
                hintText: 'Material',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Colors
            TextField(
              controller: _colorController,
              decoration: const InputDecoration(
                hintText: 'Colors (comma separated, e.g., red,blue)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Parent Category Dropdown
            DropdownButtonFormField<String>(
              value: selectedParent,
              hint: const Text('Select Parent Category'),
              items: parentCategories.map((parent) {
                return DropdownMenuItem(value: parent, child: Text(parent));
              }).toList(),
              onChanged: (value) {
                selectedParent = value;
                selectedSubCategory = null;
                loadSubCategories(value!);
                setState(() {});
              },
            ),
            const SizedBox(height: 16),

            // Subcategory Dropdown
            DropdownButtonFormField<String>(
              value: selectedSubCategory,
              hint: const Text('Select Subcategory'),
              items: subCategories.map((sub) {
                return DropdownMenuItem(value: sub, child: Text(sub));
              }).toList(),
              onChanged: (value) {
                selectedSubCategory = value;
                setState(() {});
              },
            ),
            const SizedBox(height: 16),

            // Upload Photo
            OutlinedButton(
              onPressed: _pickPhoto,
              child: Text(_photoUrl != null ? 'Photo Uploaded' : 'Upload Photo'),
            ),
            const SizedBox(height: 16),

            // Upload STL
            OutlinedButton(
              onPressed: _pickSTLFile,
              child: Text(_stlFileUrl != null ? 'STL Uploaded' : 'Upload STL File'),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProduct,
                child: const Text('Save Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
