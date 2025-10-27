import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'product_model.dart';
import 'customize.dart';
import 'addproduct.dart';
import 'model_viewer_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fs;

class ProductDetail extends StatefulWidget {
  final Product product;
  final String? categoryId;
  final String? categoryName;
  final String? subCategoryId;
  final String? subCategoryName;

  const ProductDetail({
    super.key,
    required this.product,
    this.categoryId,
    this.categoryName,
    this.subCategoryId,
    this.subCategoryName,
  });

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.product.videoUrl != null &&
        widget.product.videoUrl!.isNotEmpty) {
      _videoController = VideoPlayerController.network(widget.product.videoUrl!)
        ..initialize().then((_) {
          if (mounted) setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          "Product Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              // Open AddProductScreen in edit mode
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddProductScreen(
                    categoryName: widget.categoryName ?? '',
                    categoryId: widget.categoryId ?? '',
                    subCategoryName: widget.subCategoryName ?? '',
                    subCategoryId: widget.subCategoryId ?? '',
                    productId: product.id,
                  ),
                ),
              );
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                "Home > Non-Electronic Products > Home Decor > ${product.name}",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),

            // Main Image / Video / 3D Preview
            SizedBox(
              height: 300,
              width: double.infinity,
              child: product.modelUrl != null && product.modelUrl!.isNotEmpty
                  ? ModelViewer(
                      src: product.modelUrl!,
                      alt: product.name,
                      autoRotate: true,
                      cameraControls: true,
                      backgroundColor: Colors.white,
                    )
                  : (_videoController != null &&
                            _videoController!.value.isInitialized
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              AspectRatio(
                                aspectRatio:
                                    _videoController!.value.aspectRatio,
                                child: VideoPlayer(_videoController!),
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    _videoController!.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                  onPressed: () {
                                    if (_videoController!.value.isPlaying) {
                                      _videoController!.pause();
                                    } else {
                                      _videoController!.play();
                                    }
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          )
                        : (product.imageUrls.isNotEmpty
                              ? Image.network(
                                  product.imageUrls.first,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.broken_image, size: 50))),
            ),

            // Image Gallery
            if (product.imageUrls.isNotEmpty)
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: product.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(product.imageUrls[index]),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Starts at ₹${product.price}",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (product.material != null && product.material!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Material: ${product.material!}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : "No description available.",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Colors
                  if (product.availableColors.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Available Colors:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: product.availableColors
                              .map(
                                (c) => Container(
                                  width: 28,
                                  height: 28,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black12),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),

                  // Sizes
                  if (product.availableSizes.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Available Sizes:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: product.availableSizes
                              .map((s) => Chip(label: Text(s)))
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),

                  // Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Customize(
                                productName: product.name,
                                productImage: product.imageUrls.isNotEmpty
                                    ? product.imageUrls.first
                                    : "assets/placeholder.png",
                                availableColors: product.availableColors,
                                availableSizes: product.availableSizes,
                                modelUrl: product.modelUrl,
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Customize",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please sign in to place an order',
                                ),
                              ),
                            );
                            return;
                          }

                          final item = {
                            'productId': product.id,
                            'productName': product.name,
                            'price': int.tryParse(product.price) ?? 0,
                            'quantity': 1,
                          };

                          // Try to resolve owner for this product
                          String? ownerId;
                          String? ownerName;
                          String? ownerEmail;
                          String? ownerPhone;
                          try {
                            final prod = await fs.FirebaseFirestore.instance
                                .collection('products')
                                .doc(product.id)
                                .get();
                            final pdata = prod.data();
                            if (pdata is Map<String, dynamic> &&
                                pdata['ownerId'] != null) {
                              ownerId = pdata['ownerId'].toString();
                              final ownerDoc = await fs
                                  .FirebaseFirestore
                                  .instance
                                  .collection('users')
                                  .doc(ownerId)
                                  .get();
                              final od = ownerDoc.data();
                              if (od is Map<String, dynamic>) {
                                ownerName = od['name']?.toString();
                                ownerEmail = od['email']?.toString();
                                ownerPhone = od['phone']?.toString();
                              }
                            }
                          } catch (_) {}

                          try {
                            final orderRef = await fs.FirebaseFirestore.instance
                                .collection('orders')
                                .add({
                                  'userId': uid,
                                  'items': [item],
                                  'total': item['price'],
                                  'status': 'Pending',
                                  'timestamp': fs.FieldValue.serverTimestamp(),
                                  'ownerId': ownerId,
                                  'ownerName': ownerName,
                                  'ownerEmail': ownerEmail,
                                  'ownerPhone': ownerPhone,
                                });
                            // Navigate to order status screen
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Place Order",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // External Video Button
                  if (product.videoUrl != null && product.videoUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ElevatedButton.icon(
                        onPressed: () => _openUrl(product.videoUrl!),
                        icon: const Icon(Icons.video_collection),
                        label: const Text("Watch Video"),
                      ),
                    ),

                  // 3D Model Button
                  if (product.modelUrl != null && product.modelUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Open in-app full screen model viewer instead of launching external URL
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ModelViewerScreen(
                                modelUrl: product.modelUrl!,
                                title: product.name,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.view_in_ar),
                        label: const Text("View 3D Model"),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
