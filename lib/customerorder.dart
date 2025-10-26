import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  final String userName;

  const OrdersPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    // Dummy orders list
    final List<Map<String, String>> orders = [
      {"id": "1001", "item": "Chair", "status": "Delivered"},
      {"id": "1002", "item": "Table", "status": "Pending"},
      {"id": "1003", "item": "Lamp", "status": "Shipped"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Orders"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(order['id']!),
              ),
              title: Text(order['item']!),
              subtitle: Text("Status: ${order['status']}"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to order detail page later
              },
            ),
          );
        },
      ),
    );
  }
}
