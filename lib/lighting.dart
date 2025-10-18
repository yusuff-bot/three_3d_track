import 'package:flutter/material.dart';
import 'cartpage.dart';
import 'customerprofile.dart';
import 'filter_sort_modal.dart'; // Filter modal
import 'accessories.dart';

class LightingPage extends StatefulWidget {
  const LightingPage({super.key});

  @override
  State<LightingPage> createState() => _LightingPageState();
}

class _LightingPageState extends State<LightingPage> {
  int _selectedIndex = 1;

  final List<Map<String, String>> lightingCategories = [
    {"name": "Lamps", "price": "₹25", "image": "assets/lamps.png"},
    {"name": "Light Photo Frames", "price": "₹30", "image": "assets/photo_frames.png"},
    {"name": "LED Strips", "price": "₹55", "image": "assets/led_strips.png"},
    {"name": "Smart Bulbs", "price": "₹20", "image": "assets/smart_bulbs.png"},
    {"name": "Power Adapters", "price": "₹20", "image": "assets/power_adapters.png"},
    {"name": "Modernist Floor Lamp", "price": "₹150", "image": "assets/floor_lamp.png"},
  ];

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pop(context); // Back to home
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Electronics", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumbs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Home > Electronic Products > Lighting",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),

          // Category Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildCategoryTab("Accessories", false, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AccessoriesPage()),
                  );
                }),
                const SizedBox(width: 12),
                _buildCategoryTab("Lighting", true, null),
              ],
            ),
          ),

          // Grid of Lighting Products
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                itemCount: lightingCategories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final item = lightingCategories[index];
                  return _buildProductCard(item);
                },
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          final result = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => const FilterSortModal(),
          );

          if (result != null) {
            print(result); // TODO: Apply sorting/filtering logic
          }
        },
        icon: const Icon(Icons.filter_list),
        label: const Text("Filters"),
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

  // Category tab widget
  Widget _buildCategoryTab(String title, bool isSelected, VoidCallback? onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Product card widget
  Widget _buildProductCard(Map<String, String> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Image.asset(item["image"]!, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              item["name"]!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              item["price"]!,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
