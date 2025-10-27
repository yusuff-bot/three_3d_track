import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addproduct.dart';
import 'productdetail.dart';
import 'product_model.dart';
import 'src/safe_network_image.dart';

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
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return const Center(child: Text('No products yet.'));

          final products = snapshot.data!.docs;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final doc = products[index];
              final name = doc['name'];
              final price = doc['price'];
              // Prefer 'imageUrls' (array) and fall back to 'photoUrl' for older docs
              String? photoUrl;
              final data = doc.data() as Map<String, dynamic>?;
              if (data != null) {
                final imgs = data.containsKey('imageUrls')
                    ? data['imageUrls']
                    : null;
                if (imgs is List && imgs.isNotEmpty) {
                  photoUrl = imgs.first as String?;
                } else if (data.containsKey('photoUrl')) {
                  photoUrl = data['photoUrl'] as String?;
                }
              } else {
                photoUrl = null;
              }

              final placeholder = 'https://via.placeholder.com/56x56?text=Prod';
              return ListTile(
                leading: SizedBox(
                  width: 56,
                  height: 56,
                  child: SafeNetworkImage(
                    image: photoUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    placeholderUrl: placeholder,
                  ),
                ),
                title: Text(name),
                subtitle: Text('₹${price.toString()}'),
                onTap: () {
                  // Build a Product model from the document and open ProductDetail to view (including 3D model)
                  final data = doc.data() as Map<String, dynamic>?;
                  if (data != null) {
                    final product = Product.fromMap(data, doc.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetail(product: product),
                      ),
                    );
                  }
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
