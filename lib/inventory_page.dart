import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _seedDefaultInventoryIfEmpty();
  }

  Future<void> _seedDefaultInventoryIfEmpty() async {
    try {
      final premadeSnap = await FirebaseFirestore.instance
          .collection('inventory_premade')
          .limit(1)
          .get();
      if (premadeSnap.docs.isEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        final List<Map<String, dynamic>> defaultPremade = [
          {"name": "Custom Phone Cases", "quantity": 15},
          {"name": "Personalized Keychains", "quantity": 20},
          {"name": "3D Printed Figurines", "quantity": 12},
          {"name": "Customized Coasters", "quantity": 8},
        ];
        for (var item in defaultPremade) {
          final docRef = FirebaseFirestore.instance
              .collection('inventory_premade')
              .doc(item['name']);
          batch.set(docRef, item);
        }
        await batch.commit();
      }

      final rawSnap = await FirebaseFirestore.instance
          .collection('inventory_raw')
          .limit(1)
          .get();
      if (rawSnap.docs.isEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        final List<Map<String, dynamic>> defaultRaw = [
          {"name": "PLA Filament", "quantity": 25},
          {"name": "Resin Bottles", "quantity": 18},
          {"name": "Acrylic Sheets", "quantity": 30},
          {"name": "Adhesive Spray", "quantity": 10},
          {"name": "ABS - Red", "quantity": 150, "threshold": 200},
          {"name": "PLA - Blue", "quantity": 200},
        ];
        for (var item in defaultRaw) {
          final docRef = FirebaseFirestore.instance
              .collection('inventory_raw')
              .doc(item['name']);
          batch.set(docRef, item);
        }
        await batch.commit();
      }
    } catch (_) {}
  }

  void _adjustQuantity(
      String collectionName, String itemName, int currentQty, bool increase) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection(collectionName).doc(itemName);
      final newQty = (increase ? currentQty + 1 : currentQty - 1).clamp(0, 9999);
      await docRef.update({'quantity': newQty});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error adjusting quantity: $e")),
        );
      }
    }
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
            onPressed: () async {
              if (newItemName.trim().isNotEmpty) {
                final collection = _tabController.index == 0
                    ? 'inventory_premade'
                    : 'inventory_raw';
                try {
                  await FirebaseFirestore.instance
                      .collection(collection)
                      .doc(newItemName.trim())
                      .set({
                    "name": newItemName.trim(),
                    "quantity": newQuantity,
                  });
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error adding item: $e")),
                    );
                  }
                }
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryStream(String collectionName) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text("No items in inventory."));
        }
        return ListView.builder(
          itemCount: docs.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final name = data['name'] ?? doc.id;
            final quantity = data['quantity'] ?? 0;

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InventoryDetailScreen(
                      itemName: name,
                      collectionName: collectionName,
                    ),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Quantity: $quantity",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () =>
                                _adjustQuantity(collectionName, name, quantity, false),
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () =>
                                _adjustQuantity(collectionName, name, quantity, true),
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
      },
    );
  }

  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) => const OwnerDashboard(username: 'Owner')),
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
          elevation: 0,
          title: const Text(
            "Inventory Management",
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
            _buildInventoryStream('inventory_premade'),
            _buildInventoryStream('inventory_raw'),
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
