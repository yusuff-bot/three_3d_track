import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_model.dart';
import 'productdetail.dart';
import 'filters.dart';

Color _stringToColor(String colorString) {
  switch (colorString.toLowerCase()) {
    case 'red':
      return Colors.red;
    case 'green':
      return Colors.green;
    case 'blue':
      return Colors.blue;
    case 'yellow':
      return Colors.yellow;
    case 'white':
      return Colors.white;
    case 'gray':
      return Colors.grey;
    default:
      return Colors.grey;
  }
}

class HomeOfficeDecorPage extends StatefulWidget {
  final String parentCategory; // e.g. "Non-Electronic"
  final String subCategory; // e.g. "Home Decor"

  const HomeOfficeDecorPage({
    super.key,
    this.parentCategory = "Non-Electronic",
    this.subCategory = "Home Decor",
  });

  @override
  State<HomeOfficeDecorPage> createState() => _HomeOfficeDecorPageState();
}

class _HomeOfficeDecorPageState extends State<HomeOfficeDecorPage> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = fetchProductsByCategory(widget.subCategory);
  }

  // Fetch products from Firestore dynamically
  Future<List<Product>> fetchProductsByCategory(String category) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: category)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      return Product(
        id: doc.id,
        name: data?['name'] ?? 'Unnamed Product',
        price: data?['price']?.toString() ?? '0',
        description: data?['description'] ?? '',
        imageUrls: List<String>.from(data?['imageUrls'] ?? []),
        videoUrl: data?['videoUrl'],
        modelUrl: data?['modelUrl'],
        material: data?['material'],
        availableColors: (data?['colors'] != null)
            ? (data!['colors'] as List)
                  .map((c) => _stringToColor(c.toString()))
                  .toList()
            : [],
        availableSizes: List<String>.from(data?['sizes'] ?? []),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          widget.subCategory,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Home > ${widget.parentCategory} > ${widget.subCategory}",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),

          // Product Grid
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error loading products: ${snapshot.error}"),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No products found."));
                }

                final products = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(products[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Floating Filters Button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => const FilterSortModal(),
          );
        },
        icon: const Icon(Icons.filter_list),
        label: const Text("Filters"),
      ),
    );
  }

  Widget _buildProductCard(Product item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetail(product: item)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: item.imageUrls.isNotEmpty
                    ? Image.network(
                        item.imageUrls.first,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 40),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₹${item.price}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
