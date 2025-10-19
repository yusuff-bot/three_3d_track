import 'package:flutter/material.dart';
import 'dart:math';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String statusFilter = "All";
  String dateFilter = "All";
  String amountFilter = "All";

  // Example random orders
  final List<Map<String, String>> orders = List.generate(25, (index) {
    final statusList = ["Pending", "Shipped", "Delivered", "Cancelled"];
    final random = Random();
    final day = random.nextInt(28) + 1;
    final month = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct"];
    final date = "${month[random.nextInt(month.length)]} $day, 2025";
    final amount = "₹${(random.nextInt(50) + 5) * 100}.00";

    return {
      "date": date,
      "id": "#ORD${1000 + index}",
      "amount": amount,
      "status": statusList[random.nextInt(statusList.length)],
    };
  });

  // Filter logic
  List<Map<String, String>> get filteredOrders {
    List<Map<String, String>> filtered = orders.where((order) {
      final statusMatch = statusFilter == "All" || order["status"] == statusFilter;
      return statusMatch;
    }).toList();

    // Amount sort
    if (amountFilter == "Low to High") {
      filtered.sort((a, b) => _getAmount(a).compareTo(_getAmount(b)));
    } else if (amountFilter == "High to Low") {
      filtered.sort((a, b) => _getAmount(b).compareTo(_getAmount(a)));
    }

    return filtered;
  }

  double _getAmount(Map<String, String> order) {
    return double.tryParse(order["amount"]!.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  }

  // Filter dialogs
  Future<void> _showFilterDialog(
      String title, List<String> options, String selected, void Function(String) onSelected) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: options
                .map(
                  (option) => RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: selected,
                onChanged: (val) {
                  onSelected(val!);
                  Navigator.pop(context);
                },
              ),
            )
                .toList(),
          ),
        ),
      ),
    );
  }

  void _navigateToStatus(BuildContext context, String status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrdersByStatusPage(
          status: status,
          orders: orders.where((o) => o["status"] == status).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statuses = ["Pending", "Shipped", "Delivered", "Cancelled"];
    final grouped = {for (var s in statuses) s: filteredOrders.where((o) => o["status"] == s).toList()};

    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders Overview"),
        backgroundColor: const Color(0xFF0D80F2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Search bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search orders...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 🧭 Filters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showFilterDialog(
                      "Status",
                      ['All', 'Pending', 'Shipped', 'Delivered', 'Cancelled'],
                      statusFilter,
                          (val) => setState(() => statusFilter = val),
                    );
                  },
                  child: Text("Status: $statusFilter"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showFilterDialog(
                      "Date",
                      ['All', 'Today', 'This Week', 'This Month'],
                      dateFilter,
                          (val) => setState(() => dateFilter = val),
                    );
                  },
                  child: Text("Date: $dateFilter"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showFilterDialog(
                      "Amount",
                      ['All', 'Low to High', 'High to Low'],
                      amountFilter,
                          (val) => setState(() => amountFilter = val),
                    );
                  },
                  child: Text("Amount: $amountFilter"),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 📦 Grouped orders
            Expanded(
              child: ListView(
                children: grouped.entries.map((entry) {
                  final status = entry.key;
                  final ordersList = entry.value;
                  if (ordersList.isEmpty) return const SizedBox.shrink();

                  Color statusColor;
                  switch (status) {
                    case "Pending":
                      statusColor = Colors.orange;
                      break;
                    case "Shipped":
                      statusColor = Colors.blue;
                      break;
                    case "Delivered":
                      statusColor = Colors.green;
                      break;
                    case "Cancelled":
                      statusColor = Colors.red;
                      break;
                    default:
                      statusColor = Colors.grey;
                  }

                  return GestureDetector(
                    onTap: () => _navigateToStatus(context, status),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🏷️ Status header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "$status (${ordersList.length})",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Example of a few orders preview
                        ...ordersList.take(2).map((order) {
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text("Order ${order['id']}"),
                              subtitle: Text("${order['date']} • ${order['status']}"),
                              trailing: Text(
                                order['amount']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          );
                        }),
                        if (ordersList.length > 2)
                          Padding(
                            padding: const EdgeInsets.only(left: 16, top: 4),
                            child: Text(
                              "Tap to view all ${ordersList.length} $status orders →",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrdersByStatusPage extends StatelessWidget {
  final String status;
  final List<Map<String, String>> orders;

  const OrdersByStatusPage({super.key, required this.status, required this.orders});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status) {
      case "Pending":
        statusColor = Colors.orange;
        break;
      case "Shipped":
        statusColor = Colors.blue;
        break;
      case "Delivered":
        statusColor = Colors.green;
        break;
      case "Cancelled":
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("$status Orders"),
        backgroundColor: statusColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text("Order ${order['id']}"),
                subtitle: Text(order['date']!),
                trailing: Text(
                  order['amount']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
