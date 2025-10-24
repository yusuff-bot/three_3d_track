import 'package:flutter/material.dart';
import 'ownerdashboard.dart';
import 'perproductdetail.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Premade products inventory
  List<Map<String, dynamic>> premadeProducts = [
    {"name": "Custom Phone Cases", "quantity": 15},
    {"name": "Personalized Keychains", "quantity": 20},
    {"name": "3D Printed Figurines", "quantity": 12},
    {"name": "Customized Coasters", "quantity": 8},
  ];

  // Raw materials inventory
  List<Map<String, dynamic>> rawMaterials = [
    {"name": "PLA Filament", "quantity": 25},
    {"name": "Resin Bottles", "quantity": 18},
    {"name": "Acrylic Sheets", "quantity": 30},
    {"name": "Adhesive Spray", "quantity": 10},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // Adjusted this to use the passed list and index to ensure state is updated correctly
  void _adjustQuantity(List<Map<String, dynamic>> list, int index, bool increase) {
    setState(() {
      if (increase) {
        list[index]["quantity"] += 1;
      } else {
        list[index]["quantity"] = (list[index]["quantity"] - 1).clamp(0, 9999);
      }
    });
  }

  Widget _buildInventoryList(List<Map<String, dynamic>> items) {
    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final item = items[index];

        // <<< 2. WRAP CARD IN INKWELL FOR NAVIGATION
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InventoryDetailScreen(
                  // Pass the name of the item
                  itemName: item["name"],
                  // Pass the current quantity
                  initialQuantity: item["quantity"],
                ),
              ),
              // We use .then() to update the quantity on this page
              // after the detail screen pops, assuming the detail screen
              // doesn't update the state directly but tells us to refresh.
              // *NOTE: A better way is using Riverpod/Provider, but this works for simple state.*
            ).then((_) {
              // Since the Detail Screen manages its own state and saves changes,
              // we don't have a simple return value here. In a real app,
              // we'd refetch data from a database. For this local list demo,
              // you might need to adjust the logic if you want changes made in
              // the Detail Screen to reflect here immediately.
              // For now, this just rebuilds the list, but it won't reflect changes
              // made in the Detail Screen unless you update the List here
              // (e.g., passing a callback function to the detail screen).
              setState(() {
                // This forces a rebuild and refiltering, good practice for
                // refreshing the list view.
              });
            });
          },
          child: Card( // The rest of the card structure remains the same
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Product Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["name"],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Quantity: ${item['quantity']}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),

                  // Adjust buttons (for quick +/- 1 adjustments)
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _adjustQuantity(items, index, false),
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () => _adjustQuantity(items, index, true),
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Navigate back to Owner Dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OwnerDashboard(username: "")),
            );
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepPurple,
          tabs: const [
            Tab(text: "Premade Products"),
            Tab(text: "Raw Materials"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInventoryList(premadeProducts),
          _buildInventoryList(rawMaterials),
        ],
      ),
    );
  }
}