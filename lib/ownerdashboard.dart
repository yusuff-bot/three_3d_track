import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'orders_page.dart';
import 'inventory_page.dart';
import 'expensepage.dart';
import 'suggestions_page.dart';
import 'addcategory.dart';
import 'perproductdetail.dart';
import 'welcome.dart';
import 'customerdashboard.dart';

// ------------------ ENTRY POINT ------------------
void main() => runApp(const OwnerDashboard(username: ''));

// ------------------ OWNER DASHBOARD WRAPPER ------------------
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

// ------------------ DASHBOARD BODY ------------------
class DashboardBody extends StatefulWidget {
  final String username;
  const DashboardBody({super.key, required this.username});

  @override
  State<DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<DashboardBody> {
  bool _ordersExpanded = false;

  // ✅ Sample orders with full details
  final List<Map<String, dynamic>> orders = [
    {
      "id": "#101",
      "customerName": "Sam Miller",
      "customerEmail": "sam.miller@example.com",
      "customerPhone": "+91 9876543210",
      "customerAddress": "123 Maple Street, Springfield",
      "items": [
        {"name": "Miniature Warrior", "quantity": 2, "price": 450},
        {"name": "Miniature Mage", "quantity": 1, "price": 500},
      ],
      "shippingMethod": "Courier",
      "shippingStatus": "Pending",
      "total": 1400
    },
    {
      "id": "#102",
      "customerName": "Jennifer Smith",
      "customerEmail": "jennifer.smith@example.com",
      "customerPhone": "+91 9123456789",
      "customerAddress": "56 Oak Avenue, Shelbyville",
      "items": [
        {"name": "Custom Phone Case", "quantity": 1, "price": 1200}
      ],
      "shippingMethod": "Courier",
      "shippingStatus": "Shipped",
      "total": 1200
    },
    {
      "id": "#103",
      "customerName": "Noah Evans",
      "customerEmail": "noah.evans@example.com",
      "customerPhone": "+91 9988776655",
      "customerAddress": "78 Pine Street, Capital City",
      "items": [
        {"name": "Architectural Model", "quantity": 1, "price": 5500}
      ],
      "shippingMethod": "Pickup",
      "shippingStatus": "Delivered",
      "total": 5500
    },
    {
      "id": "#104",
      "customerName": "Sophia Bennett",
      "customerEmail": "sophia.bennett@example.com",
      "customerPhone": "+91 9876512345",
      "customerAddress": "12 Birch Road, Ogdenville",
      "items": [
        {"name": "Cosplay Prop Sword", "quantity": 1, "price": 2100}
      ],
      "shippingMethod": "Courier",
      "shippingStatus": "Pending",
      "total": 2100
    },
    {
      "id": "#105",
      "customerName": "Liam Davis",
      "customerEmail": "liam.davis@example.com",
      "customerPhone": "+91 9658741230",
      "customerAddress": "90 Cedar Lane, North Haverbrook",
      "items": [
        {"name": "Custom Pendant", "quantity": 1, "price": 500}
      ],
      "shippingMethod": "Courier",
      "shippingStatus": "Delivered",
      "total": 500
    },
  ];

  // ✅ Only keep Update Category and Suggestion Categories
  final List<Map<String, dynamic>> quickLinks = [
    {"title": "Update Category", "page": const ManageCategoriesScreen()},
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
                            MaterialPageRoute(
                              builder: (_) => OrderDetailPage(orderData: order),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

// ---- Inventory Alerts Card ----
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

            // PLA - Blue
            ListTile(
              leading: Image.asset('assets/blue.png', width: 40, height: 40),
              title: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(text: "PLA - 200g - "),
                    TextSpan(
                      text: "Blue",
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              subtitle: const Text("In stock"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InventoryDetailScreen(
                      itemName: "PLA - Blue",
                      collectionName: "inventory_raw",
                    ),
                  ),
                );
              },
            ),

            // ABS - Red
            ListTile(
              leading: Image.asset('assets/red.png', width: 40, height: 40),
              title: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(text: "ABS - 150g - "),
                    TextSpan(
                      text: "Red",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              subtitle: const Text("Low stock"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InventoryDetailScreen(
                      itemName: "ABS - Red",
                      collectionName: "inventory_raw",
                    ),
                  ),
                );
              },
            ),
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
              _buildStatCard(
                  "Total Sales (This Week)", "₹45,200", Icons.bar_chart, Colors.blue),
              _buildStatCard(
                  "Profit (This Month)", "₹12,800", Icons.trending_up, Colors.green),
              _buildStatCard(
                  "Total Orders", "145", Icons.shopping_cart, Colors.orange),
              _buildStatCard(
                  "Products Sold", "378", Icons.inventory_2, Colors.purple),
            ],
          ),
          const SizedBox(height: 20),

          // ---------------- Quick Links ----------------
          const Text("Quick Links",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
    );
  }

  // ---------------- Helper Function for Stats ----------------
  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
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
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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

// ------------------ OWNER DASHBOARD PAGE ------------------
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
      const OrderssPage(),
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
          _selectedIndex == 0 ? "Owner Dashboard"
              :_selectedIndex == 1 ? "Order Management"
              :_selectedIndex == 2 ? "Inventory Management"
              :_selectedIndex == 3 ? "Expense Management"
          :"",
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront, color: Colors.blueAccent),
            tooltip: 'Switch to Customer View',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardPage(
                    username: widget.username,
                    userEmail: widget.username,
                  ),
                ),
                (route) => false,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            tooltip: 'Logout',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('user_role');
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Welcome()),
                  (route) => false,
                );
              }
            },
          ),
        ],
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

// ------------------ ORDER DETAIL PAGE ------------------
class OrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> orderData;
  const OrderDetailPage({super.key, required this.orderData});

  double getTotal() {
    double total = 0;
    for (var item in orderData['items']) {
      total += (item['quantity'] * item['price']);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order ${orderData['id']} Details"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // ---------------- Customer Details ----------------
            const Text(
              "Customer Details",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name: ${orderData['customerName']}"),
                    Text("Email: ${orderData['customerEmail']}"),
                    Text("Phone: ${orderData['customerPhone']}"),
                    Text("Address: ${orderData['customerAddress']}"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ---------------- Ordered Items ----------------
            const Text(
              "Ordered Items",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            ...orderData['items'].map<Widget>((item) {
              double subtotal = item['quantity'] * item['price'];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          item['name'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text("Qty: ${item['quantity']}"),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text("₹${item['price']}"),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text("Subtotal: ₹${subtotal.toStringAsFixed(2)}"),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 16),

            // ---------------- Shipping Details ----------------
            const Text(
              "Shipping Details",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Method: ${orderData['shippingMethod']}"),
                    Text("Status: ${orderData['shippingStatus']}"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ---------------- Total Amount ----------------
            Card(
              color: Colors.blue[50],
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  "Total Amount: ₹${getTotal().toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}