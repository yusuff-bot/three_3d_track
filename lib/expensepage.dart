import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();
    _seedDefaultExpensesIfEmpty();
  }

  Future<void> _seedDefaultExpensesIfEmpty() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('other_expenses')
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        final List<Map<String, dynamic>> defaultExpenses = [
          {
            "title": "Marketing Expense",
            "amount": 5000.0,
            "date": Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 5)))
          },
          {
            "title": "Equipment Maintenance",
            "amount": 8000.0,
            "date": Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 10)))
          },
          {
            "title": "Software Subscription",
            "amount": 2500.0,
            "date": Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 15)))
          },
          {
            "title": "Supplies",
            "amount": 3000.0,
            "date": Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 20)))
          },
          {
            "title": "Utilities",
            "amount": 2000.0,
            "date": Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 22)))
          },
          {
            "title": "Rent",
            "amount": 15000.0,
            "date": Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 25)))
          },
          {
            "title": "Insurance",
            "amount": 4000.0,
            "date": Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 28)))
          },
        ];
        for (var item in defaultExpenses) {
          final docRef =
              FirebaseFirestore.instance.collection('other_expenses').doc();
          batch.set(docRef, item);
        }
        await batch.commit();
      }
    } catch (_) {}
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

  void _addExpense() async {
    if (_titleController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final date = _selectedDate!;

    setState(() {
      _titleController.clear();
      _amountController.clear();
      _selectedDate = null;
    });

    try {
      await FirebaseFirestore.instance.collection('other_expenses').add({
        "title": title,
        "amount": amount,
        "date": Timestamp.fromDate(date),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("New expense added successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error adding expense: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, orderSnapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('other_expenses')
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, otherSnapshot) {
              if (orderSnapshot.connectionState == ConnectionState.waiting ||
                  otherSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final orderDocs = orderSnapshot.data?.docs ?? [];
              final otherDocs = otherSnapshot.data?.docs ?? [];

              final List<Map<String, dynamic>> orderExpenses =
                  orderDocs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final totalVal = data['total'] ?? 0;
                final double total = totalVal is num
                    ? totalVal.toDouble()
                    : (double.tryParse(totalVal.toString()) ?? 0.0);
                return {
                  "order": doc.id,
                  "amount": total,
                };
              }).toList();

              final List<Map<String, dynamic>> otherExpenses =
                  otherDocs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final amountVal = data['amount'] ?? 0;
                final double amount = amountVal is num
                    ? amountVal.toDouble()
                    : (double.tryParse(amountVal.toString()) ?? 0.0);
                return {
                  "title": data['title'] ?? 'Other Expense',
                  "amount": amount,
                };
              }).toList();

              final double totalOrders =
                  orderExpenses.fold(0.0, (sum, e) => sum + e['amount']);
              final double totalOthers =
                  otherExpenses.fold(0.0, (sum, e) => sum + e['amount']);
              final double aggregateTotal = totalOrders + totalOthers;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Manual Expense Entry Form
                    const Text("Add New Expense",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: "Expense Title",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Amount (₹)",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? "Select Date"
                                : DateFormat('dd MMM yyyy')
                                    .format(_selectedDate!),
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
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Total Expenditure
                    Text(
                      "Total Expenditure (Last 30 Days): ₹${aggregateTotal.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Order Expenses
                    const Text("Order Expenses",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    orderExpenses.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text("No order sales recorded as expenses.",
                                style: TextStyle(color: Colors.grey)),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: orderExpenses.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final order = orderExpenses[index];
                              return ListTile(
                                title: Text("Order #${order['order']}"),
                                trailing: Text("₹${order['amount']}"),
                                onTap: () {
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    otherExpenses.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text("No manually added expenses.",
                                style: TextStyle(color: Colors.grey)),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: otherExpenses.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final expense = otherExpenses[index];
                              return ListTile(
                                title: Text(expense['title']),
                                trailing: Text(
                                    "₹${expense['amount'].toStringAsFixed(2)}"),
                              );
                            },
                          ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}