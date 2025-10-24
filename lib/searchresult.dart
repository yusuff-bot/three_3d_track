import 'package:flutter/material.dart';
import 'productdetail.dart';
import 'product_model.dart';


class SearchResultsPage extends StatelessWidget {
  final String searchQuery;
  const SearchResultsPage({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    // Sample search results including name, image, and price
    final List<Map<String, String>> results = [
      {
        "name": "Custom Miniature",
        "image": "assets/mini1.png",
        "price": "₹150"
      },
      {
        "name": "Fantasy Miniature",
        "image": "assets/mini2.png",
        "price": "₹200"
      },
      {
        "name": "Sci-Fi Miniature",
        "image": "assets/mini3.png",
        "price": "₹250"
      },
      {
        "name": "Character Miniature",
        "image": "assets/mini4.png",
        "price": "₹180"
      },
      {
        "name": "Board Game Miniature",
        "image": "assets/mini5.png",
        "price": "₹220"
      },
      {
        "name": "Collectible Miniature",
        "image": "assets/mini6.png",
        "price": "₹300"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          decoration: InputDecoration(
            hintText: searchQuery,
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.black),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilterChip(label: const Text("Relevance"), onSelected: (_) {}),
              FilterChip(label: const Text("Price"), onSelected: (_) {}),
              FilterChip(label: const Text("Popularity"), onSelected: (_) {}),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final product = results[index];
                final selectedProduct = Product(
                  id: index.toString(),
                  name: product['name'] ?? 'Unknown Product',
                  price: product['price'] ?? '0',
                  description:
                  "3D printed, unique modern design. Perfect for decoration or gifting.",
                  imageUrls: [product['image'] ?? 'assets/placeholder.png'],
                  videoUrl: '',
                  availableColors: [],
                  availableSizes: [],
                );
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetail(product: selectedProduct),
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
                            child: Image.asset(
                              product['image']!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product['name']!,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        product['price'] ?? "₹0",
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.green),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
