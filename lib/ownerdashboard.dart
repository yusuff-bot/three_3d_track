import 'package:flutter/material.dart';
import 'orders_page.dart';
import 'inventory_page.dart';
import 'expensepage.dart';
import 'update_category_page.dart';
import 'suggestions_page.dart';
import 'materialdetails.dart'; // <<< Import the Detail Screen

void main() => runApp(const OwnerDashboard(username: ''));

class OwnerDashboard extends StatelessWidget {
  final String username;

  const OwnerDashboard({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OwnerDashboardPage(username: username),
    );
  }
}

// ---------------- DASHBOARD BODY ----------------
class DashboardBody extends StatefulWidget {
  final String username;
  const DashboardBody({super.key, required this.username});

  @override
  State<DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<DashboardBody> {
  bool _ordersExpanded = false;

  final List<Map<String, dynamic>> orders = [
    {"id": "#101"},
    {"id": "#102"},
    {"id": "#103"},
    {"id": "#104"},
    {"id": "#105"},
  ];

  // UPDATED: Removed the "Resin - Grey" alert item
  final List<Map<String, dynamic>> inventoryAlerts = [
    {
      "name": "PLA - Blue",
      "subtitle": "In stock",
      "asset": 'assets/blue.png',
      "quantity": 200,
      "unit": "grams",
      "color": Colors.blue,
    },
    {
      "name": "ABS - Red",
      "subtitle": "Low stock",
      "asset": 'assets/red.png',
      "quantity": 150,
      "unit": "grams",
      "color": Colors.red,
    },
    // The "Resin - Grey" item has been removed from this list.
  ];

  final List<Map<String, dynamic>> quickLinks = [
    {"title": "Order Management", "page": const OrdersPage()},
    {"title": "Inventory Management", "page": const InventoryPage()},
    {"title": "Update Category", "page": const UpdateCategoryPage()},
    {"title": "Suggestion Categories", "page": const CustomerSuggestionsPage()},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome, ${widget.username}!",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          const SizedBox(height: 16),

          // ---------------- New Orders ----------------
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

          // ---------------- Inventory Alerts (MODIFIED) ----------------
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
                  // Loop through the new inventoryAlerts list
                  ...inventoryAlerts.map((alert) {
                    // Split the name for styling, e.g., "PLA - Blue"
                    final parts = alert['name'].split(' - ');
                    // Final part is the color name (e.g., "Blue")
                    final colorName = parts.length > 1 ? parts.last : '';
                    // Remaining part is the primary product/material name (e.g., "PLA")
                    final primaryName = parts.length > 1 ? parts.sublist(0, parts.length - 1).join(' - ') : parts[0];

                    return ListTile(
                      leading: Image.asset(alert['asset'], width: 40, height: 40),
                      title: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                          children: [
                            TextSpan(text: "$primaryName - "),
                            TextSpan(
                              text: colorName,
                              style: TextStyle(color: alert['color'], fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      subtitle: Text(alert['subtitle']),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      // Navigation to MaterialDetails, passing all unique data
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MaterialDetails(
                              itemName: alert['name'],
                              initialQuantity: alert['quantity'],
                              unit: alert['unit'], // Pass the unique unit (e.g., "grams")
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ---------------- Sales Overview ----------------
          const Text(
            "Sales Overview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard("Total Sales (This Week)", "₹45,200", Icons.bar_chart, Colors.blue),
              _buildStatCard("Profit (This Month)", "₹12,800", Icons.trending_up, Colors.green),
              _buildStatCard("Total Orders", "145", Icons.shopping_cart, Colors.orange),
              _buildStatCard("Products Sold", "378", Icons.inventory_2, Colors.purple),
            ],
          ),
          const SizedBox(height: 20),

          // ---------------- Quick Links ----------------
          const Text("Quick Links",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Column(
            children: quickLinks.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  if (link['page'] != null) {
                    Navigator.push(
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
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                  ],
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // -------------- Helper Function for Stats --------------
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

// ---------------- OWNER DASHBOARD PAGE ----------------
class OwnerDashboardPage extends StatefulWidget {
  final String username;
  const OwnerDashboardPage({super.key, required this.username});

  @override
  State<OwnerDashboardPage> createState() => _OwnerDashboardPageState();
}

class _OwnerDashboardPageState extends State<OwnerDashboardPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardBody(username: widget.username),
      const OrdersPage(),
      const InventoryPage(),
      const ExpenseManagementPage(),
    ];
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? "Owner Dashboard"
              : _selectedIndex == 1
              ? "Order Management"
              : _selectedIndex == 2
              ? "Inventory Management"
              : "Expense Management",
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Inventory"),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: "Expenses"),
        ],
      ),
    );
  }
}