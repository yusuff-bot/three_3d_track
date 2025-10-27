import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_model.dart';
import 'productdetail.dart';
import 'homeoffice_decor.dart';
import 'accessories.dart';
import 'subcategories_screen.dart';
import 'src/safe_network_image.dart';
import 'search.dart';
import 'customerprofile.dart';
import 'customerorder.dart';
import 'cartpage.dart';

// ---------------- HomeTab ----------------
class HomeTab extends StatefulWidget {
  final String userName;
  final String userEmail;

  const HomeTab({super.key, required this.userName, required this.userEmail});

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
    final snapshot = await FirebaseFirestore.instance
        .collection('categories')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      // Prefer new admin field 'imageUrl', fall back to legacy 'image'
      final img = data?['imageUrl'] ?? data?['image'];
      return {
        'id': doc.id,
        'name': data?['name']?.toString() ?? 'Unnamed',
        'image': img?.toString() ?? 'assets/placeholder.png',
      };
    }).toList();
  }

  // ✅ Fetch featured products
  Future<List<Product>> _fetchFeaturedProducts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .orderBy('timestamp', descending: true)
        .limit(5) // limit featured products
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

  Color _stringToColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xff')));
    } catch (_) {
      return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return a non-Scaffold widget so the outer Scaffold (in CustomerHomePage)
    // can control the BottomNavigationBar. We render a header that looks
    // like an AppBar and then the existing scrollable content below it.
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Column(
        children: [
          // NOTE: AppBar moved to CustomerHomePage so the BottomNavigationBar
          // stays visible. Keep a small spacer so content doesn't sit under
          // the app bar when CustomerHomePage provides it.
          const SizedBox(height: 0),

          Expanded(
            // Important: keep content scrollable and add bottom padding so it
            // doesn't get hidden behind the BottomNavigationBar.
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                bottom: kBottomNavigationBarHeight,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SearchPage(
                                userName: widget.userName,
                                userEmail: widget.userEmail,
                              ),
                            ),
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
                                vertical: 0,
                                horizontal: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                        return const Center(
                          child: Text("No categories found."),
                        );
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
                                // Navigate to subcategories list for this category
                                final catId = category['id']!;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SubcategoriesScreen(
                                      categoryId: catId,
                                      categoryName: category['name']!,
                                    ),
                                  ),
                                );
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
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: double.infinity,
                                          child: SafeNetworkImage(
                                            image: category['image'] ?? '',
                                            fit: BoxFit.cover,
                                            placeholderUrl:
                                                'https://via.placeholder.com/400x400?text=Category',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    category['name']!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 220,
                    child: FutureBuilder<List<Product>>(
                      future: _featuredProductsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        }

                        final products = snapshot.data ?? [];
                        if (products.isEmpty) {
                          return const Center(
                            child: Text("No featured products available."),
                          );
                        }

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
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
                                          ProductDetail(product: product),
                                    ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 120,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(16),
                                              ),
                                          color: Colors.grey[200],
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(16),
                                              ),
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
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          "₹${product.price}",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.green,
                                          ),
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
                ], // end inner Column children
              ), // end inner Column
            ), // end SingleChildScrollView
          ), // end Expanded
        ], // end outer Column children
      ), // end outer Column
    ); // end Container
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
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeTab(userName: widget.userName, userEmail: widget.userEmail),
      // Pass user info to SearchPage so it can navigate back to the correct
      // CustomerHomePage with the same context.
      SearchPage(userName: widget.userName, userEmail: widget.userEmail),
      const CartPage(),
      SettingsPage(userName: widget.userName, userEmail: widget.userEmail),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Show an AppBar from the parent Scaffold so it doesn't get hidden by
    // nested Scaffolds and so the BottomNavigationBar remains visible.
    return Scaffold(
      // Always show the AppBar so the top navigation is visible on all tabs
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
      body: _pages[_selectedIndex], // Shows selected page
      bottomNavigationBar: BottomNavigationBar(
        // Diagnostic: make the bar visually obvious in case it was blending
        // into the page background or being overlapped. If you still don't
        // see the bar after this change, the pages may be pushed as full
        // screen routes that cover the scaffold.
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // Update selected page
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
