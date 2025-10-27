import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'productdetail.dart';
import 'product_model.dart';

class SearchResultsPage extends StatelessWidget {
  final String searchQuery;
  const SearchResultsPage({super.key, required this.searchQuery});

  Future<List<Product>> _fetchResults() async {
    final firestore = FirebaseFirestore.instance.collection('products');
    // Query by name and category. Use two queries and dedupe results by doc id.
    final nameQuery = await firestore
        .where('name', isGreaterThanOrEqualTo: searchQuery)
        .where('name', isLessThanOrEqualTo: '$searchQuery\uf8ff')
        .get();

    final categoryQuery = await firestore
        .where('category', isGreaterThanOrEqualTo: searchQuery)
        .where('category', isLessThanOrEqualTo: '$searchQuery\uf8ff')
        .get();

    // Deduplicate documents by id (Set of docs may rely on identity equality).
    final Map<String, QueryDocumentSnapshot> byId = {};
    for (final d in nameQuery.docs) {
      byId[d.id] = d;
    }
    for (final d in categoryQuery.docs) {
      byId[d.id] = d;
    }

    final docs = byId.values.toList();

    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      // Normalize imageUrls: prefer a list field, fallback to single image or placeholder
      List<String> imageUrls = [];
      if (data['imageUrls'] is List) {
        try {
          imageUrls = List<String>.from(data['imageUrls']);
        } catch (_) {
          imageUrls = data['imageUrls'].map((e) => e.toString()).toList();
        }
      } else if (data['imageUrl'] != null) {
        imageUrls = [data['imageUrl'].toString()];
      } else if (data['image'] != null) {
        imageUrls = [data['image'].toString()];
      } else {
        imageUrls = ['assets/placeholder.png'];
      }

      List<String> availableColors = [];
      if (data['availableColors'] is List) {
        try {
          availableColors = List<String>.from(
            data['availableColors'].map((c) => c.toString()),
          );
        } catch (_) {
          availableColors = data['availableColors']
              .map((c) => c.toString())
              .toList();
        }
      }

      List<String> availableSizes = [];
      if (data['availableSizes'] is List) {
        try {
          availableSizes = List<String>.from(
            data['availableSizes'].map((s) => s.toString()),
          );
        } catch (_) {
          availableSizes = data['availableSizes']
              .map((s) => s.toString())
              .toList();
        }
      }

      // map color name strings to actual Color objects expected by Product
      final mappedColors = availableColors
          .map((s) => Product.parseColor(s))
          .toList();

      return Product(
        id: doc.id,
        name: data['name'] ?? 'Unnamed Product',
        price: data['price']?.toString() ?? '0',
        description: data['description'] ?? 'No description available.',
        imageUrls: imageUrls,
        videoUrl: data['videoUrl']?.toString() ?? '',
        availableColors: mappedColors,
        availableSizes: availableSizes,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: searchQuery,
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.black),
          ),
        ),
      ),
      body: FutureBuilder<List<Product>>(
        future: _fetchResults(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No products found."));
          }

          final results = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final product = results[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetail(product: product),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey[200],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            product.imageUrls.first,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "₹${product.price}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
