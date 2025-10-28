import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'subcategory_products.dart';
import 'src/safe_network_image.dart';

class SubcategoriesScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const SubcategoriesScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  CollectionReference get _subcatsRef => FirebaseFirestore.instance
      .collection('categories')
      .doc(categoryId)
      .collection('subcategories');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: StreamBuilder<QuerySnapshot>(
        stream: _subcatsRef.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return const Center(child: Text('No subcategories yet.'));

          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unnamed';
              final id = doc.id;
              // Prefer admin 'imageUrl' field, then legacy 'image'
              final image = (data['imageUrl'] ?? data['image']) ?? '';
              final placeholder = 'https://via.placeholder.com/56x56?text=Sub';

              return ListTile(
                leading: SizedBox(
                  width: 56,
                  height: 56,
                  child: SafeNetworkImage(
                    image: image,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    placeholderUrl: placeholder,
                  ),
                ),
                title: Text(name),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SubcategoryProductsScreen(
                        categoryId: categoryId,
                        categoryName: categoryName,
                        subCategoryId: id,
                        subCategoryName: name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
