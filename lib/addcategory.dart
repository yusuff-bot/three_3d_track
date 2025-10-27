import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'addsubcategory.dart';
import 'edit_category.dart';
import 'app_bottom_nav.dart';
// platform-specific upload helper (conditional import)
import 'src/file_upload_helper_io.dart'
    if (dart.library.html) 'src/file_upload_helper_web.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _categoryController = TextEditingController();
  final CollectionReference _categoriesRef = FirebaseFirestore.instance
      .collection('categories');

  String? _categoryImageUrl;
  String? _categoryImageName;

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  // PICK IMAGE
  Future<void> _pickCategoryImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null) {
      final file = result.files.first;
      final ref = FirebaseStorage.instance.ref().child(
        'categories/${file.name}',
      );

      // Infer content type
      String contentType = 'application/octet-stream';
      final lower = file.extension?.toLowerCase() ?? file.name.toLowerCase();
      if (lower.endsWith('png')) contentType = 'image/png';
      if (lower.endsWith('jpg') || lower.endsWith('jpeg'))
        contentType = 'image/jpeg';

      final metadata = SettableMetadata(contentType: contentType);

      // Use platform helper to upload (putFile on native, putData on web)
      final uploadTask = uploadFileToStorage(ref, file, metadata);
      await uploadTask.whenComplete(() {});
      final url = await ref.getDownloadURL();
      setState(() {
        _categoryImageUrl = url;
        _categoryImageName = file.name;
      });
    }
  }

  // ADD CATEGORY (with optional image)
  Future<void> _addCategory() async {
    final name = _categoryController.text.trim();
    if (name.isEmpty) return;

    try {
      final docRef = await _categoriesRef.add({
        'name': name,
        'imageUrl': _categoryImageUrl ?? null,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear inputs
      _categoryController.clear();
      setState(() {
        _categoryImageUrl = null;
        _categoryImageName = null;
      });

      // Navigate to Subcategory screen for this new category
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AddSubCategoryScreen(categoryName: name, categoryId: docRef.id),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add category: $e')));
    }
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Manage Categories'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      hintText: 'Enter category name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _pickCategoryImage,
                  child: Text(
                    _categoryImageName != null
                        ? 'Image chosen'
                        : 'Upload Image',
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B8D4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Categories List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _categoriesRef
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No categories yet.'));
                  }

                  final categories = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final doc = categories[index];
                      final categoryName = doc['name'];
                      final categoryId = doc.id;
                      final categoryImage =
                          doc.data().toString().contains('imageUrl')
                          ? doc['imageUrl']
                          : null;

                      return ListTile(
                        leading: categoryImage != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(categoryImage),
                              )
                            : const CircleAvatar(child: Icon(Icons.category)),
                        title: Text(categoryName),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // Open EditCategoryScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditCategoryScreen(
                                      categoryId: categoryId,
                                      currentName: categoryName,
                                      currentImageUrl: categoryImage,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                        onTap: () {
                          // Navigate to AddSubCategoryScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddSubCategoryScreen(
                                categoryName: categoryName,
                                categoryId: categoryId,
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
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}
