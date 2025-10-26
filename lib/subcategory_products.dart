// subcategory_products.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addproduct.dart';

class SubcategoryProductsScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;
  final String subCategoryId;
  final String subCategoryName;

  const SubcategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.subCategoryId,
    required this.subCategoryName,
  });

  CollectionReference get _productsRef => FirebaseFirestore.instance
      .collection('categories')
      .doc(categoryId)
      .collection('subcategories')
      .doc(subCategoryId)
      .collection('products');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(subCategoryName)),
      body: StreamBuilder<QuerySnapshot>(
        stream: _productsRef.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No products yet.'));

          final products = snapshot.data!.docs;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final doc = products[index];
              final name = doc['name'];
              final price = doc['price'];
              final photoUrl = doc['photoUrl'];
              return ListTile(
                leading: photoUrl != null ? Image.network(photoUrl, width: 56, height: 56, fit: BoxFit.cover) : const Icon(Icons.production_quantity_limits),
                title: Text(name),
                subtitle: Text('₹${price.toString()}'),
                onTap: () {
                  // Optionally navigate to product detail/edit screen if you implement that
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductScreen(
                categoryName: categoryName,
                categoryId: categoryId,
                subCategoryName: subCategoryName,
                subCategoryId: subCategoryId,
              ),
            ),
          );
        },
        label: const Text('Add Product'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
