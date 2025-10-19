import 'package:flutter/material.dart';

class ExpenseDetailsPage extends StatelessWidget {
  final String orderId;
  final double costPerUnit;
  final double materialCost;
  final int quantity;

  const ExpenseDetailsPage({
    super.key,
    required this.orderId,
    required this.costPerUnit,
    required this.materialCost,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    // Example: Dynamic items in this order
    // You can replace this with real data later
    final List<Map<String, dynamic>> itemsInOrder = [
      {"item": "Custom T-Shirt", "qty": 2, "price": 500},
      {"item": "Printed Mug", "qty": 1, "price": 350},
      {"item": "Sticker Pack", "qty": 3, "price": 150},
    ];

    double totalItemsCost = itemsInOrder.fold(0, (sum, e) => sum + (e['price'] * e['qty']));
    double totalExpense = totalItemsCost + materialCost + (quantity * costPerUnit);

    return Scaffold(
      appBar: AppBar(
        title: Text("Expense Details - $orderId"),
        backgroundColor: const Color(0xFF0D80F2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Order Overview",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Order ID: $orderId", style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text("Quantity: $quantity", style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text("Cost per Unit: ₹${costPerUnit.toStringAsFixed(2)}"),
                      const SizedBox(height: 8),
                      Text("Material Cost: ₹${materialCost.toStringAsFixed(2)}"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Items in Order",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemsInOrder.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = itemsInOrder[index];
                  return ListTile(
                    title: Text(item['item']),
                    subtitle: Text("Quantity: ${item['qty']}"),
                    trailing: Text("₹${(item['price'] * item['qty']).toStringAsFixed(2)}"),
                  );
                },
              ),

              const SizedBox(height: 24),
              const Divider(thickness: 1.5),

              Text(
                "Total Items Cost: ₹${totalItemsCost.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                "Material Cost: ₹${materialCost.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                "Total Expense: ₹${totalExpense.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D80F2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
