import 'package:flutter/material.dart';
import 'cartpage.dart';
import 'customerprofile.dart';
import 'homedecor.dart';
import 'accessories.dart';

class customerhomepage extends StatefulWidget {
  const customerhomepage({super.key});

  @override
  State<customerhomepage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<customerhomepage> {
  int _selectedIndex = 0;

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> categories = [
      {"name": "Home Decor", "image": "assets/decor.png"},
      {"name": "Art", "image": "assets/art.png"},
      {"name": "Accessories", "image": "assets/accessories.png"},
      {"name": "Fashion", "image": "assets/fashion.png"},
      {"name": "Jewelry", "image": "assets/jewellery.png"},
      {"name": "Other", "image": "assets/other.png"},
    ];

    final List<Map<String, String>> featuredProducts = [
      {"name": "Modern Vase", "price": "₹1200", "image": "assets/vase.png"},
      {"name": "Geometric Lamp", "price": "₹1500", "image": "assets/lmp.png"},
      {"name": "Custom iPhone", "price": "₹900", "image": "assets/phone.png"},
      {"name": "Toy", "price": "₹2000", "image": "assets/toy.png"},
    ];

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
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search products...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Categories title
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

            // Categories Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return GestureDetector(
                    onTap: () {
                      if (category['name'] == "Home Decor") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomeOfficeDecorPage(), // 👈 Open the decor page
                          ),
                        );
                      }
                      else if (category['name'] == "Accessories") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AccessoriesPage(),
                          ),
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
                              child: Image.asset(
                                category['image']!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category['name']!,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Featured Products
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
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: featuredProducts.length,
                itemBuilder: (context, index) {
                  final product = featuredProducts[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
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
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              color: Colors.grey[200],
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.asset(
                                product['image']!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              product['name']!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              product['price']!,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Can't find a category?
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                "Can't find a category?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
