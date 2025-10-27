import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_status.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String? uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid;
  }

  int _calculateTotal(List<QueryDocumentSnapshot> docs) {
    int total = 0;
    for (var d in docs) {
      final data = d.data() as Map<String, dynamic>;
      final price = (data['price'] ?? 0);
      final quantity = (data['quantity'] ?? 1);
      if (price is int) total += price * (quantity as int);
      if (price is String)
        total += (int.tryParse(price) ?? 0) * (quantity as int);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Cart')),
        body: const Center(child: Text('Please sign in to view your cart.')),
      );
    }

    final itemsRef = FirebaseFirestore.instance
        .collection('carts')
        .doc(uid)
        .collection('items');

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: StreamBuilder<QuerySnapshot>(
        stream: itemsRef.orderBy('timestamp', descending: false).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }
          final totalPrice = _calculateTotal(docs);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final item = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: item['baseImage'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        item['baseImage'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.broken_image),
                                      ),
                                    )
                                  : const Center(child: Icon(Icons.image)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['productName'] ?? 'Unnamed',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Size: ${item['selectedSize'] ?? '-'} • Color: ${item['selectedColor'] ?? '-'}",
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                        onPressed: () async {
                                          final q =
                                              (item['quantity'] ?? 1) as int;
                                          if (q > 1) {
                                            await doc.reference.update({
                                              'quantity': q - 1,
                                            });
                                          }
                                        },
                                      ),
                                      Text("${item['quantity'] ?? 1}"),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                        ),
                                        onPressed: () async {
                                          final q =
                                              (item['quantity'] ?? 1) as int;
                                          await doc.reference.update({
                                            'quantity': q + 1,
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await doc.reference.delete();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Total and Checkout
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹$totalPrice',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          // Create order document from cart items. Also try to
                          // resolve seller/owner contact if items belong to a
                          // single owner.
                          final batch = FirebaseFirestore.instance.batch();
                          final orderRef = FirebaseFirestore.instance
                              .collection('orders')
                              .doc();
                          final orderItems = docs.map((d) => d.data()).toList();

                          // Attempt to collect ownerIds from product documents
                          final ownerIds = <String>{};
                          for (final it in orderItems) {
                            try {
                              final map = Map<String, dynamic>.from(it as Map);
                              final pid = map['productId'] as String?;
                              if (pid != null && pid.isNotEmpty) {
                                final prod = await FirebaseFirestore.instance
                                    .collection('products')
                                    .doc(pid)
                                    .get();
                                if (prod.exists) {
                                  final pdata = prod.data();
                                  if (pdata is Map<String, dynamic> &&
                                      pdata['ownerId'] != null) {
                                    ownerIds.add(pdata['ownerId'].toString());
                                  }
                                }
                              }
                            } catch (_) {}
                          }

                          String? ownerId;
                          String? ownerName;
                          String? ownerEmail;
                          String? ownerPhone;

                          if (ownerIds.length == 1) {
                            ownerId = ownerIds.first;
                            try {
                              final ownerDoc = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(ownerId)
                                  .get();
                              if (ownerDoc.exists) {
                                final od = ownerDoc.data();
                                if (od is Map<String, dynamic>) {
                                  ownerName = od['name']?.toString();
                                  ownerEmail = od['email']?.toString();
                                  ownerPhone = od['phone']?.toString();
                                }
                              }
                            } catch (_) {}
                          }

                          final orderData = {
                            'userId': uid,
                            'items': orderItems,
                            'total': totalPrice,
                            'status': 'Pending',
                            'timestamp': FieldValue.serverTimestamp(),
                            'ownerId': ownerId,
                            'ownerName': ownerName,
                            'ownerEmail': ownerEmail,
                            'ownerPhone': ownerPhone,
                          };

                          batch.set(orderRef, orderData);
                          for (var d in docs) batch.delete(d.reference);

                          try {
                            await batch.commit();
                            // Navigate to order status page for live updates
                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      OrderStatusPage(orderId: orderRef.id),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to place order'),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
