import 'package:flutter/material.dart';
import 'orders_page.dart';
import 'inventory_page.dart';
import 'update_category_page.dart';
import 'suggestions_page.dart';
import 'expensepage.dart';

void main() => runApp(const OwnerDashboard(username: '',));

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key, required String username});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const OwnerDashboardPage(),
    );
  }
}

class OwnerDashboardPage extends StatefulWidget {
  const OwnerDashboardPage({super.key});

  @override
  State<OwnerDashboardPage> createState() => _OwnerDashboardPageState();
}

class _OwnerDashboardPageState extends State<OwnerDashboardPage> {
  int _selectedIndex = 0;
  bool _ordersExpanded = false;

  final List<Map<String, dynamic>> orders = [
    {"id": "#101"},
    {"id": "#102"},
    {"id": "#103"},
    {"id": "#104"},
    {"id": "#105"},
  ];

  final List<Map<String, dynamic>> quickLinks = [
    {"title": "Order Management", "page": const OrdersPage()},
    {"title": "Inventory Management", "page": const InventoryPage()},
    {"title": "Update Category", "page": const UpdateCategoryPage()},
    {"title": "Suggestion Categories", "page": const SuggestionsPage()},
  ];

  final List<Widget> _pages = [
    const OwnerDashboardPage(), // Dashboard itself
    const OrdersPage(),
    const InventoryPage(),
    const ExpenseManagementPage(),
  ];

  void _onBottomNavTap(int index) {
    if (index == _selectedIndex) return; // prevent reloading same page
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => _pages[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Owner Dashboard",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 5 New Orders
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text(
                        "5 New Orders",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          _ordersExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        ),
                        onPressed: () {
                          setState(() {
                            _ordersExpanded = !_ordersExpanded;
                          });
                        },
                      ),
                    ),
                    if (_ordersExpanded)
                      ...orders.map(
                            (order) => ListTile(
                          title: Text("Order ${order['id']}"),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const OrdersPage()),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Inventory Alerts
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Inventory Alert",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.blue),
                      title: const Text("PLA - 200g"),
                      subtitle: const Text("In stock"),
                    ),
                    ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.red),
                      title: const Text("ABS - 150g"),
                      subtitle: const Text("Low stock"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Dashboard Image
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/chart.png',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Total Sales This Week
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Total Sales This Week",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      "₹30,250",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Links (titles only)
            const Text(
              "Quick Links",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              children: quickLinks
                  .map(
                    (link) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () {
                      if (link['page'] != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => link['page']),
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          link['title']!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: "Orders"),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory), label: "Inventory"),
          BottomNavigationBarItem(
              icon: Icon(Icons.attach_money), label: "Expenses"),
        ],
      ),
    );
  }
}
