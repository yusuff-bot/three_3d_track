import 'package:flutter/material.dart';

class ExpenseManagementPage extends StatelessWidget {
  const ExpenseManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Management"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Expenses Overview",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 3,
              child: ListTile(
                title: const Text("Total Expenses This Month"),
                trailing: const Text("₹12,500", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 3,
              child: ListTile(
                title: const Text("Utilities"),
                trailing: const Text("₹3,200"),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 3,
              child: ListTile(
                title: const Text("Salaries"),
                trailing: const Text("₹7,500"),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 3,
              child: ListTile(
                title: const Text("Miscellaneous"),
                trailing: const Text("₹1,800"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
