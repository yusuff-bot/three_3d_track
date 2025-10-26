import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_model.dart';
import 'productdetail.dart';
import 'homeoffice_decor.dart';
import 'accessories.dart';
import 'search.dart';
import 'customerprofile.dart';
import 'customerorder.dart';

// ---------------- HomeTab ----------------
class HomeTab extends StatefulWidget {
  final String userName;
  final String userEmail;

  const HomeTab({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Future<List<Map<String, String>>> _categoriesFuture;
  late Future<List<Product>> _featuredProductsFuture;

  @override
  void initState() {
    super.initState();
    _uploadDefaultCategories(); // ✅ Push hardcoded categories to Firestore
    _categoriesFuture = _fetchCategories();
    _featuredProductsFuture = _fetchFeaturedProducts();
  }

  // ✅ Upload hardcoded default categories to Firebase (only if not already there)
  Future<void> _uploadDefaultCategories() async {
    final categories = [
      {"name": "Home Decor", "type": "non-electronic"},
      {"name": "Art", "type": "non-electronic"},
      {"name": "Accessories", "type": "electronic"},
      {"name": "Fashion", "type": "non-electronic"},
      {"name": "Jewelry", "type": "non-electronic"},
      {"name": "Components", "type": "electronic"},
    ];

    final firestore = FirebaseFirestore.instance.collection('categories');
    for (var category in categories) {
      final docRef = firestore.doc(category['name']);
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        await docRef.set({
          'name': category['name'],
          'type': category['type'],
          'image': '', // placeholder for now, you’ll upload images later
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // ✅ Fetch categories from Firestore
  Future<List<Map<String, String>>> _fetchCategories() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('categories').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'name': data['name']?.toString() ?? 'Unnamed',
        'image': data['image']?.toString() ?? 'assets/placeholder.png',
      };
    }).toList();
  }

  // ✅ Fetch featured products
  Future<List<Product>> _fetchFeaturedProducts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('isFeatured', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Product(
        id: doc.id,
        name: data['name'] ?? 'Unnamed Product',
        price: data['price']?.toString() ?? '0',
        description: data['description'] ?? '',
        imageUrls: List<String>.from(data['imageUrls'] ?? []),
        videoUrl: data['videoUrl'],
        modelUrl: data['modelUrl'],
        material: data['material'],
        availableColors: (data['colors'] != null)
            ? (data['colors'] as List)
            .map((c) => _stringToColor(c.toString()))
            .toList()
            : [],
        availableSizes: List<String>.from(data['sizes'] ?? []),
      );
    }).toList();
  }

  Color _stringToColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xff')));
    } catch (_) {
      return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "3D Track",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchPage()),
                  );
                },
                child: IgnorePointer(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search products...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Categories Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Categories",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),

            FutureBuilder<List<Map<String, String>>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text("No categories found."));
                }

                final categories = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return GestureDetector(
                        onTap: () {
                          final name = category['name']!.toLowerCase();
                          if (name.contains("home")) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HomeOfficeDecorPage(
                                  subCategory: category['name']!,
                                ),
                              ),
                            );
                          } else if (name.contains("accessories")) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AccessoriesPage()),
                            );
                          }
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: category['image']!.startsWith('http')
                                      ? Image.network(
                                    category['image']!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image),
                                  )
                                      : Image.asset(
                                    category['image']!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category['name']!,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Featured Products Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Featured Products",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: FutureBuilder<List<Product>>(
                future: _featuredProductsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final products = snapshot.data ?? [];
                  if (products.isEmpty) {
                    return const Center(
                        child: Text("No featured products available."));
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetail(product: product)),
                            );
                          },
                          child: Container(
                            width: 160,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 5,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 120,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                    color: Colors.grey[200],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                    child: product.imageUrls.isNotEmpty
                                        ? Image.network(
                                      product.imageUrls.first,
                                      fit: BoxFit.cover,
                                    )
                                        : const Icon(Icons.broken_image),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    product.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  child: Text(
                                    "₹${product.price}",
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------- CustomerHomePage ----------------
class CustomerHomePage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const CustomerHomePage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeTab(userName: widget.userName, userEmail: widget.userEmail),
      OrdersPage(userName: widget.userName),
      SettingsPage(userName: widget.userName, userEmail: widget.userEmail),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
























