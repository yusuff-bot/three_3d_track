import 'package:flutter/material.dart';
import 'productdetail.dart';
import 'filters.dart';
import 'product_model.dart';

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
  const HomeOfficeDecorPage({super.key});

  @override
  State<HomeOfficeDecorPage> createState() => _HomeOfficeDecorPageState();
}

class _HomeOfficeDecorPageState extends State<HomeOfficeDecorPage> {
  int _selectedIndex = 1;

  Future<List<Product>> _fetchHomeDecorProducts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // 🖼 Each decor item now includes its own gallery and optional video
    final List<Map<String, dynamic>> decorCategories = [
      {
        "id": "vase001",
        "name": "Vases",
        "price": "₹60",
        "description":
        "This 3D printed vase features a unique, modern design, crafted from durable, eco-friendly materials. Perfect for displaying flowers or as a standalone decorative piece, it adds a touch of contemporary elegance to any space.",
        "images": [
          "assets/vase.png",
          "assets/vase1.png",
          "assets/vase2.png",
          "assets/vase3.png",
        ],
        "video":
        "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
        "colors": ["Red", "Green", "Blue", "Yellow"],
        "sizes": ["Small", "Medium", "Large"],
      },
      {
        "id": "mini001",
        "name": "Miniatures",
        "price": "₹15",
        "description":
        "Handcrafted 3D miniatures ideal for tabletop gaming and custom collections. Each piece is printed with intricate detail and high precision.",
        "images": [
          "assets/miniature.png",
          "assets/mini2.png",
          "assets/mini3.png",
          "assets/mini4.png",
        ],
        "video":
        "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4",
        "colors": ["Gray", "White", "Red"],
        "sizes": ["S", "M", "L"],
      },
      {
        "id": "frame001",
        "name": "Photo Frames",
        "price": "₹30",
        "description":
        "Elegant and modern photo frames crafted from eco-friendly materials. Perfect for preserving memories with a stylish touch.",
        "images": [
          "assets/photo.png",
          "assets/photo2.png",
          "assets/photo3.png",
          "assets/photo4.png",
        ],
        "video":
        "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
        "colors": ["White", "Yellow"],
        "sizes": ["A3", "A4", "A5"],
      },
      {
        "id": "desk001",
        "name": "Desk Organizers",
        "price": "₹50",
        "description":
        "Smartly designed 3D printed organizers to keep your workspace clean, efficient, and aesthetic.",
        "images": [
          "assets/desk.png",
          "assets/desk2.png",
          "assets/desk3.png",
          "assets/desk4.png",
        ],
        "video":
        "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4",
        "colors": ["Gray", "Blue"],
        "sizes": ["Standard"],
      },
      {
        "id": "statue001",
        "name": "Statues",
        "price": "₹25",
        "description":
        "Artistic 3D printed statues made from durable resin blends, ideal for home and office décor.",
        "images": [
          "assets/Status.png",
          "assets/statue2.png",
          "assets/statue3.png",
          "assets/statue4.png",
        ],
        "video":
        "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
        "colors": ["White", "Gray"],
        "sizes": ["Small", "Medium"],
      },
      {
        "id": "wall001",
        "name": "Wall Art",
        "price": "₹90",
        "description":
        "Contemporary wall art created using high-precision 3D printing. Adds depth and creativity to your interiors.",
        "images": [
          "assets/wall.png",
          "assets/wall2.png",
          "assets/wall3.png",
          "assets/wall4.png",
        ],
        "video":
        "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4",
        "colors": ["Blue", "White"],
        "sizes": ["Large"],
      },
    ];

    // ✅ FIXED: Changed `hardcodedData` → `decorCategories`
    return decorCategories.map((data) {
      return Product(
        id: data['id']!,
        name: data['name']!,
        price: data['price']!,
        description: data['description']!,
        imageUrls: List<String>.from(data['images']),
        videoUrl: data['video'] as String?,
        availableColors: (data['colors'] as List)
            .map((c) => _stringToColor(c as String))
            .toList(),
        availableSizes: List<String>.from(data['sizes']),
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
        title: const Text(
          "Home Decor",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
              "Home > Non-Electronic Products > Home Decor",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),

          // Product Grid
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _fetchHomeDecorProducts(),
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
                  return const Center(
                      child: Text("No Home Decor items found."));
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
                    return _buildDecorCard(products[index]);
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

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildDecorCard(Product item) {
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
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  item.imageUrls.first,
                  fit: BoxFit.cover,
                  width: double.infinity,
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
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.price,
                    style: const TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
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
