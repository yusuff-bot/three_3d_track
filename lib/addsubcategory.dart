// addsubcategory.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'addproduct.dart';
import 'subcategory_products.dart';
import 'app_bottom_nav.dart';

class AddSubCategoryScreen extends StatefulWidget {
  final String categoryName;
  final String categoryId;

  const AddSubCategoryScreen({
    super.key,
    required this.categoryName,
    required this.categoryId,
  });

  @override
  State<AddSubCategoryScreen> createState() => _AddSubCategoryScreenState();
}

class _AddSubCategoryScreenState extends State<AddSubCategoryScreen> {
  final _subCategoryController = TextEditingController();
  late final CollectionReference _subCategoriesRef;

  String? _subCategoryImageUrl;
  String? _subCategoryImageName;

  @override
  void initState() {
    super.initState();
    _subCategoriesRef = FirebaseFirestore.instance
        .collection('categories')
        .doc(widget.categoryId)
        .collection('subcategories');
  }

  @override
  void dispose() {
    _subCategoryController.dispose();
    super.dispose();
  }

  Future<void> _pickSubCategoryImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      final file = result.files.first;
      final ref = FirebaseStorage.instance
          .ref()
          .child('subcategories/${widget.categoryId}/${file.name}');
      await ref.putData(file.bytes!);
      final url = await ref.getDownloadURL();
      setState(() {
        _subCategoryImageUrl = url;
        _subCategoryImageName = file.name;
      });
    }
  }

  Future<void> _addSubCategory() async {
    final name = _subCategoryController.text.trim();
    if (name.isEmpty) return;
    try {
      await _subCategoriesRef.add({
        'name': name,
        'imageUrl': _subCategoryImageUrl ?? null,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _subCategoryController.clear();
      setState(() {
        _subCategoryImageUrl = null;
        _subCategoryImageName = null;
      });

      // Instead of auto-navigation to AddProduct, remain on this screen.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subcategory added')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add subcategory: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text(widget.categoryName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Add New Sub-Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _subCategoryController,
                decoration: const InputDecoration(hintText: 'Enter subcategory name', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: _pickSubCategoryImage, child: Text(_subCategoryImageName != null ? 'Image chosen' : 'Upload Image')),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addSubCategory,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B8D4)),
              child: const Text('Add'),
            ),
          ]),
          const SizedBox(height: 32),
          const Text('Sub-Categories List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _subCategoriesRef.orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No subcategories yet.'));

                final subcategories = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: subcategories.length,
                  itemBuilder: (context, index) {
                    final doc = subcategories[index];
                    final subCategoryName = doc['name'];
                    final subCategoryId = doc.id;
                    final subImage = doc.data().toString().contains('imageUrl') ? doc['imageUrl'] : null;

                    return ListTile(
                      leading: subImage != null ? CircleAvatar(backgroundImage: NetworkImage(subImage)) : const CircleAvatar(child: Icon(Icons.list)),
                      title: Text(subCategoryName),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Open Subcategory product list which contains an "Add" button
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubcategoryProductsScreen(
                              categoryId: widget.categoryId,
                              categoryName: widget.categoryName,
                              subCategoryId: subCategoryId,
                              subCategoryName: subCategoryName,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ]),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}
