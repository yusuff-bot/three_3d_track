import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'app_bottom_nav.dart';

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
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _photoUrl;
  String? _stlFileUrl;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      final file = result.files.first;
      final ref = FirebaseStorage.instance
          .ref()
          .child('products/${widget.subCategoryId}/${file.name}');
      await ref.putData(file.bytes!);
      final url = await ref.getDownloadURL();
      setState(() {
        _photoUrl = url;
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
          .child('products/${widget.subCategoryId}/${file.name}');
      await ref.putData(file.bytes!);
      final url = await ref.getDownloadURL();
      setState(() {
        _stlFileUrl = url;
      });
    }
  }

  Future<void> _saveProduct() async {
    final name = _nameController.text.trim();
    final price = _priceController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty || price.isEmpty || _photoUrl == null || _stlFileUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and upload files')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.categoryId)
          .collection('subcategories')
          .doc(widget.subCategoryId)
          .collection('products')
          .add({
        'name': name,
        'price': double.tryParse(price) ?? 0,
        'description': description,
        'photoUrl': _photoUrl,
        'stlFileUrl': _stlFileUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );

      Navigator.pop(context); // Go back to subcategory screen
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('${widget.subCategoryName} Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Description (optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // Photo Upload
            const Text(
              'Product Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _pickPhoto,
                child: Text(_photoUrl != null ? 'Photo Uploaded' : 'Upload Photo'),
              ),
            ),
            const SizedBox(height: 16),

            // STL Upload
            const Text(
              '3D STL File',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _pickSTLFile,
                child: Text(_stlFileUrl != null ? 'STL Uploaded' : 'Upload STL File'),
              ),
            ),
            const SizedBox(height: 80), // Spacer for save button
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _saveProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00B8D4),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Save Product'),
        ),
      ),
    );
  }
}
