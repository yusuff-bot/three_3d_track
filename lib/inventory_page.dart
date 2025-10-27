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

  List<Map<String, dynamic>> premadeProducts = [
    {"name": "Custom Phone Cases", "quantity": 15},
    {"name": "Personalized Keychains", "quantity": 20},
    {"name": "3D Printed Figurines", "quantity": 12},
    {"name": "Customized Coasters", "quantity": 8},
  ];

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

  void _adjustQuantity(List<Map<String, dynamic>> list, int index, bool increase) {
    setState(() {
      if (increase) {
        list[index]["quantity"] += 1;
      } else {
        list[index]["quantity"] = (list[index]["quantity"] - 1).clamp(0, 9999);
      }
    });
  }

  void _showAddItemDialog() {
    String newItemName = "";
    int newQuantity = 1;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add New Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Item Name"),
              onChanged: (val) => newItemName = val,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Quantity"),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                newQuantity = int.tryParse(val) ?? 1;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (newItemName.isNotEmpty) {
                setState(() {
                  if (_tabController.index == 0) {
                    premadeProducts.add({
                      "name": newItemName,
                      "quantity": newQuantity,
                    });
                  } else {
                    rawMaterials.add({
                      "name": newItemName,
                      "quantity": newQuantity,
                    });
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryList(List<Map<String, dynamic>> items) {
    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InventoryDetailScreen(
                  itemName: item["name"],
                  initialQuantity: item["quantity"],
                ),
              ),
            ).then((_) {
              setState(() {});
            });
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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

  // 🔹 Back navigation behavior: Always go to Owner Dashboard
  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OwnerDashboard(username: 'Owner')),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0, // ✅ removes the grey box above tabs
          title: const Text(
            "",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const OwnerDashboard(username: 'Owner')),
              );
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Align(
              alignment: Alignment.center,
              child: TabBar(
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
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildInventoryList(premadeProducts),
            _buildInventoryList(rawMaterials),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepPurple,
          onPressed: _showAddItemDialog,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
