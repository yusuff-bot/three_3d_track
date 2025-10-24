import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addproduct.dart';
import 'app_bottom_nav.dart';

class AddSubCategoryScreen extends StatefulWidget {
  final String categoryName;   // Name of the parent category
  final String categoryId;     // ID of the parent category (from Firestore)

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

  // Reference to subcategories under this category
  late final CollectionReference _subCategoriesRef;

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

  Future<void> _addSubCategory() async {
    final name = _subCategoryController.text.trim();
    if (name.isEmpty) return;

    try {
      // Add new subcategory in Firestore
      final docRef = await _subCategoriesRef.add({
        'name': name,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _subCategoryController.clear();

      // Navigate to Add Product screen for this new subcategory
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddProductScreen(
            categoryName: widget.categoryName,
            categoryId: widget.categoryId,
            subCategoryName: name,
            subCategoryId: docRef.id,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add subcategory: $e')),
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
        title: Text(widget.categoryName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Add Subcategory Form ---
            const Text(
              'Add New Sub-Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subCategoryController,
                    decoration: const InputDecoration(
                      hintText: 'Enter subcategory name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addSubCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B8D4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- Subcategories List ---
            const Text(
              'Sub-Categories List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _subCategoriesRef.orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No subcategories yet.'));
                  }

                  final subcategories = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: subcategories.length,
                    itemBuilder: (context, index) {
                      final doc = subcategories[index];
                      final subCategoryName = doc['name'];
                      final subCategoryId = doc.id;

                      return ListTile(
                        title: Text(subCategoryName),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Navigate to AddProductScreen for this subcategory
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddProductScreen(
                                categoryName: widget.categoryName,
                                categoryId: widget.categoryId,
                                subCategoryName: subCategoryName,
                                subCategoryId: subCategoryId,
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
