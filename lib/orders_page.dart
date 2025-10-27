import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ownerdashboard.dart';

class OrderssPage extends StatefulWidget {
  const OrderssPage({super.key});

  @override
  State<OrderssPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrderssPage> {
  String statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final ordersRef = FirebaseFirestore.instance
        .collection('orders')
        .orderBy('timestamp', descending: true);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OwnerDashboard(username: '')),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: ordersRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty)
                    return const Center(child: Text('No orders found.'));

                  // Optionally filter by status
                  final filtered = statusFilter == 'All'
                      ? docs
                      : docs
                            .where(
                              (d) =>
                                  (d.data()
                                      as Map<String, dynamic>)['status'] ==
                                  statusFilter,
                            )
                            .toList();

                  return Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final d = filtered[index];
                        final data = d.data() as Map<String, dynamic>;
                        final id = d.id;
                        final status = data['status'] ?? 'Unknown';
                        final total = data['total'] ?? 0;

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text('Order $id'),
                            subtitle: Text(status),
                            trailing: Text(
                              '₹$total',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            onTap: () {
                              // TODO: open order detail and allow status updates
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
