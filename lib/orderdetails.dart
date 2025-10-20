import 'package:flutter/material.dart';
import 'ownerdashboard.dart';

// Dummy data for demonstration
final List<Map<String, dynamic>> ordersData = [
  {
    "id": "#101",
    "customer": {
      "name": "Sophia Clark",
      "email": "sophia.clark@email.com",
      "phone": "9876543210",
      "address": "Margao, Goa"
    },
    "products": [
      {"name": "Customized Phone Case", "color": "Red", "size": "Medium", "quantity": 2, "unitPrice": 300},
      {"name": "Personalized Keychain", "color": "Blue", "size": "Large", "quantity": 1, "unitPrice": 50},
    ],
    "status": "In Production",
  },
  {
    "id": "#102",
    "customer": {
      "name": "John Doe",
      "email": "john.doe@email.com",
      "phone": "9123456780",
      "address": "Panaji, Goa"
    },
    "products": [
      {"name": "3D Printed Figurine", "color": "White", "size": "Small", "quantity": 1, "unitPrice": 1200},
    ],
    "status": "Ready for Shipping",
  },
  // Add more orders here
];

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: ordersData.length,
        itemBuilder: (context, index) {
          final order = ordersData[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text("Order ${order['id']}"),
              subtitle: Text("Customer: ${order['customer']['name']}"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => OrderDetailPage(order: order)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class OrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderDetailPage({super.key, required this.order});

  int getTotal() {
    int total = 0;
    for (var product in order['products']) {
      total += (product['quantity'] as int) * (product['unitPrice'] as int);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final customer = order['customer'] as Map<String, dynamic>;
    final products = order['products'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text("Order ${order['id']} Details"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Back to dashboard/orders page
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Info
            const Text("Customer Details",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text("Name: ${customer['name']}"),
            Text("Email: ${customer['email']}"),
            Text("Phone: ${customer['phone']}"),
            Text("Address: ${customer['address']}"),
            const Divider(height: 32),

            // Product Details
            const Text("Products",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Column(
              children: products.map<Widget>((product) {
                final prod = product as Map<String, dynamic>;
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(prod['name']),
                    subtitle: Text(
                        "Color: ${prod['color']}, Size: ${prod['size']}\nQuantity: ${prod['quantity']} x ₹${prod['unitPrice']}"),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text("Total Price: ₹${getTotal()}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(height: 32),

            // Order Status
            const Text("Order Status",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order['status'], style: const TextStyle(fontSize: 16)),
                ElevatedButton(
                  onPressed: () {
                    // Implement status update logic if needed
                  },
                  child: const Text("Update Status"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
