import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'expense_details.dart';

class ExpenseManagementPage extends StatefulWidget {
  const ExpenseManagementPage({super.key});

  @override
  State<ExpenseManagementPage> createState() => _ExpenseManagementPage();
}

class _ExpenseManagementPage extends State<ExpenseManagementPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime? _selectedDate;

  // Dummy expenses data
  List<Map<String, dynamic>> orderExpenses = [
    {"order": "#12345", "amount": 2500},
    {"order": "#98765", "amount": 1800},
    {"order": "#11223B", "amount": 3200},
  ];

  List<Map<String, dynamic>> otherExpenses = [
    {"title": "Marketing Expense", "amount": 5000},
    {"title": "Equipment Maintenance", "amount": 8000},
    {"title": "Software Subscription", "amount": 2500},
    {"title": "Supplies", "amount": 3000},
    {"title": "Utilities", "amount": 2000},
    {"title": "Rent", "amount": 15000},
    {"title": "Insurance", "amount": 4000},
  ];

  double get totalLast30Days {
    double totalOrders = orderExpenses.fold(0, (sum, e) => sum + e['amount']);
    double totalOthers = otherExpenses.fold(0, (sum, e) => sum + e['amount']);
    return totalOrders + totalOthers;
  }

  void _pickDate() async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addExpense() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() {
      otherExpenses.add({
        "title": _titleController.text,
        "amount": double.tryParse(_amountController.text) ?? 0,
        "date": _selectedDate
      });
      _titleController.clear();
      _amountController.clear();
      _selectedDate = null;
    });
  }

  int _selectedIndex = 3; // Expenses tab active

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
      // Navigate to other screens if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Manual Expense Entry Form
            const Text("Add New Expense",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Expense Title",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount (₹)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? "Select Date"
                        : DateFormat('dd MMM yyyy').format(_selectedDate!),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D80F2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Add Expense",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Total Expenditure
            Text(
              "Total Expenditure (Last 30 Days): ₹${totalLast30Days.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Order Expenses
            const Text("Order Expenses",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orderExpenses.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final order = orderExpenses[index];
                return ListTile(
                  title: Text("Order ${order['order']}"),
                  trailing: Text("₹${order['amount']}"),
                     onTap: ()
                     {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExpenseDetailsPage(
                            orderId: order['order'],
                            costPerUnit: 7.50,
                            materialCost: 3.50,
                            quantity: 15,
                          ),
                        ),
                      );
                      },
                );
              },
            ),
            const SizedBox(height: 16),

            // Other Expenses
            const Text("Other Expenses",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: otherExpenses.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final expense = otherExpenses[index];
                return ListTile(
                  title: Text(expense['title']),
                  trailing: Text("₹${expense['amount']}"),
                );
              },
            ),
          ],
        ),
      ),
      );
  }
}