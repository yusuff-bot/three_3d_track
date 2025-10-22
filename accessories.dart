import 'package:flutter/material.dart';
import 'filters.dart';

class AccessoriesPage extends StatefulWidget {
  const AccessoriesPage({super.key});

  @override
  State<AccessoriesPage> createState() => _AccessoriesPageState();
}

class _AccessoriesPageState extends State<AccessoriesPage> {
  int _selectedIndex = 1;

  // List of accessory categories (no price here)
  final List<Map<String, String>> accessories = [
    {
      "name": "Customizable Keychains",
      "image": "assets/keychain.png",
      "desc": "Leather keychain with customization."
    },
    {
      "name": "Personalized Desk Organizers",
      "image": "assets/desk.png",
      "desc": "Minimalist desk organizer set."
    },
    {
      "name": "3D Printed Phone Stands",
      "image": "assets/stand.png",
      "desc": "Foldable modern phone stand."
    },
    {
      "name": "Unique Bookmarks",
      "image": "assets/bookmarks.png",
      "desc": "Paper bookmark with leaf design."
    },
    {
      "name": "Customizable Coasters",
      "image": "assets/coaster.png",
      "desc": "Round wooden layered coasters."
    },
    {
      "name": "3D Printed Pen Holders",
      "image": "assets/holder.png",
      "desc": "Metal mesh pen holder with pens."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: const Text(
          "Accessories",
          style: TextStyle(
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
              "Home > Non-Electronic Products > Accessories",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),

          // Category Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildCategoryTab("🛍️ Accessories", true),
                const SizedBox(width: 10),
                _buildCategoryTab("🏠 Home & Office Decor", false),
              ],
            ),
          ),

          // Grid of Accessories
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // extra space at bottom
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: accessories.length,
              itemBuilder: (context, index) {
                final item = accessories[index];
                return _buildAccessoryCard(item);
              },
            ),
          ),
        ],
      ),

      // Floating Filter Button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          final result = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => const FilterSortModal(), // opens the modal
          );

          if (result != null) {
            // result is a map with selected sort and availability
            print(result);
            // TODO: Apply sorting/filtering logic to your accessories list here
          }
        },
        icon: const Icon(Icons.filter_list),
        label: const Text("Filters"),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // Compact category tab
  Widget _buildCategoryTab(String title, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blueAccent : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blueAccent : Colors.grey.shade400,
          width: 1,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  // Accessory Card (no price, left-aligned text)
  Widget _buildAccessoryCard(Map<String, String> item) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start, // left-align text
        children: [
          // Image section
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Image.asset(
                item["image"]!,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Product name
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              item["name"]!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(height: 4),
          // Short description (optional)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              item["desc"]!,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
