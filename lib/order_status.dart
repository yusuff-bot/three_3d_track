import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderStatusPage extends StatelessWidget {
  final String orderId;

  const OrderStatusPage({super.key, required this.orderId});

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance.collection('orders').doc(orderId);
    return Scaffold(
      appBar: AppBar(title: const Text('Order Status')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: ref.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text('Order not found'));
          }

          final data = snap.data!.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'Unknown';
          final total = data['total'] ?? 0;
          final items = List.from(data['items'] ?? []);
          final ownerId = data['ownerId'];
          final ownerName = data['ownerName'];
          final ownerEmail = data['ownerEmail'];
          final ownerPhone = data['ownerPhone'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Card(
                  child: ListTile(
                    title: const Text('Order Status'),
                    subtitle: Text(status.toString()),
                    trailing: Text(
                      '₹$total',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Items',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...items.map<Widget>((it) {
                  final map = Map<String, dynamic>.from(it as Map);
                  return ListTile(
                    title: Text(map['productName'] ?? map['name'] ?? 'Item'),
                    subtitle: Text(
                      'Qty: ${map['quantity'] ?? 1} • ₹${map['price'] ?? 0}',
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                const Text(
                  'Seller / Owner',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${ownerName ?? 'Not available'}'),
                        const SizedBox(height: 6),
                        Text('Email: ${ownerEmail ?? 'Not available'}'),
                        const SizedBox(height: 6),
                        Text('Phone: ${ownerPhone ?? 'Not available'}'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: ownerPhone != null
                                  ? () => _launchPhone(ownerPhone)
                                  : null,
                              icon: const Icon(Icons.call),
                              label: const Text('Call'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: ownerEmail != null
                                  ? () => _launchEmail(ownerEmail)
                                  : null,
                              icon: const Icon(Icons.email),
                              label: const Text('Email'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
