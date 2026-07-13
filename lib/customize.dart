import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'cartpage.dart';

class Customize extends StatefulWidget {
  final String productName;
  final String productImage;
  final List<Color> availableColors;
  final List<String> availableSizes;
  final String? modelUrl; // 3D model URL (optional)

  const Customize({
    super.key,
    required this.productName,
    required this.productImage,
    required this.availableColors,
    required this.availableSizes,
    this.modelUrl,
  });

  @override
  State<Customize> createState() => _CustomizeState();
}

class _CustomizeState extends State<Customize> {
  Color? selectedColor;
  String? selectedSize;
  int quantity = 1;
  File? uploadedDesign;
  bool show3DModel = true;
  bool _isUploading = false;

  Future<String?> _uploadDesignImage(File file) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      final fileName = 'designs/${uid}_${DateTime.now().millisecondsSinceEpoch}.png';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading custom design to Firebase Storage: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.availableColors.isNotEmpty) {
      selectedColor = widget.availableColors.first;
    }
    if (widget.availableSizes.isNotEmpty) {
      selectedSize = widget.availableSizes.first;
    }
  }

  Future<void> pickDesign() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => uploadedDesign = File(file.path));
    }
  }

  void showSizeChart() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Size Chart",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Table(
                border: TableBorder.all(color: Colors.grey),
                children: const [
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Size",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Dimensions (cm)",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text("Small")),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text("10 x 10 x 15"),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text("Medium"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text("15 x 15 x 22"),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text("Large")),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text("20 x 20 x 30"),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Center(
                  child: Text("Close", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double getSizeScale() {
    switch (selectedSize) {
      case "Small":
      case "S":
        return 0.8;
      case "Medium":
      case "M":
        return 1.0;
      case "Large":
      case "L":
        return 1.2;
      case "XL":
        return 1.4;
      default:
        return 1.0;
    }
  }

  void _incrementQuantity() => setState(() => quantity++);
  void _decrementQuantity() {
    if (quantity > 1) setState(() => quantity--);
  }

  Future<void> _addToCart() async {
    if (selectedColor == null || selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a color and a size."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to add items to cart')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    String? customDesignUrl;
    if (uploadedDesign != null) {
      customDesignUrl = await _uploadDesignImage(uploadedDesign!);
      if (customDesignUrl == null) {
        setState(() {
          _isUploading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to upload custom design image. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    final customizedItem = {
      'productName': widget.productName,
      'baseImage': widget.productImage,
      'selectedColor': selectedColor!.value,
      'selectedSize': selectedSize,
      'uploadedDesignPath': customDesignUrl,
      'quantity': quantity,
    };

    debugPrint('--- Item Added to Cart ---');
    debugPrint('Product: ${customizedItem['productName']}');
    debugPrint('Size: ${customizedItem['selectedSize']}');
    debugPrint('Color: ${customizedItem['selectedColor']}');
    if (customizedItem['uploadedDesignPath'] != null) {
      debugPrint('Custom Design: YES (Stored in Firestore as Storage URL)');
    }

    try {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(uid)
          .collection('items')
          .add({
            'productName': customizedItem['productName'],
            'baseImage': customizedItem['baseImage'],
            'selectedColor': customizedItem['selectedColor'],
            'selectedSize': customizedItem['selectedSize'],
            'uploadedDesignPath': customizedItem['uploadedDesignPath'],
            'quantity': customizedItem['quantity'],
            'timestamp': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${widget.productName} added to cart!"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartPage()),
        );
      }
    } catch (e) {
      debugPrint('Failed to add to cart: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add item to cart')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _placeOrder() async {
    if (selectedColor == null || selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select color and size')),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to place an order')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    String? customDesignUrl;
    if (uploadedDesign != null) {
      customDesignUrl = await _uploadDesignImage(uploadedDesign!);
      if (customDesignUrl == null) {
        setState(() {
          _isUploading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to upload custom design image. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    final item = {
      'productName': widget.productName,
      'baseImage': widget.productImage,
      'selectedColor': selectedColor!.value,
      'selectedSize': selectedSize,
      'uploadedDesignPath': customDesignUrl,
      'quantity': quantity,
    };

    // Try to resolve owner for this product (best-effort - might be missing)
    String? ownerId;
    String? ownerName;
    String? ownerEmail;
    String? ownerPhone;

    try {
      final orderRef = await fs.FirebaseFirestore.instance
          .collection('orders')
          .add({
            'userId': uid,
            'items': [item],
            'total': 0,
            'status': 'Pending',
            'timestamp': fs.FieldValue.serverTimestamp(),
            'ownerId': ownerId,
            'ownerName': ownerName,
            'ownerEmail': ownerEmail,
            'ownerPhone': ownerPhone,
          });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderStatusPage(orderId: orderRef.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to place order')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double scale = getSizeScale();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Customize Your Product",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.grey,
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Toggle 3D / Image preview
                if (widget.modelUrl != null && widget.modelUrl!.isNotEmpty)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => setState(() => show3DModel = !show3DModel),
                      child: Text(
                        show3DModel ? "View Image" : "View 3D Model",
                        style: const TextStyle(color: Colors.lightBlue),
                      ),
                    ),
                  ),
                Center(
                  child: Container(
                    height: 250 * scale,
                width: 250 * scale,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[200],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (show3DModel &&
                        widget.modelUrl != null &&
                        widget.modelUrl!.isNotEmpty)
                      // 3D model with color overlay
                      Stack(
                        children: [
                          ModelViewer(
                            src: widget.modelUrl!,
                            alt: widget.productName,
                            autoRotate: true,
                            cameraControls: true,
                            backgroundColor: Colors.white,
                          ),
                          if (selectedColor != null)
                            Container(
                              decoration: BoxDecoration(
                                color: selectedColor!.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                        ],
                      )
                    else
                      Image.asset(
                        widget.productImage,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        color: selectedColor?.withOpacity(0.5),
                        colorBlendMode: BlendMode.modulate,
                      ),
                    if (uploadedDesign != null)
                      Image.file(uploadedDesign!, fit: BoxFit.contain),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.productName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Colors
            const Text(
              "Select Color",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: widget.availableColors.map((color) {
                return GestureDetector(
                  onTap: () => setState(() => selectedColor = color),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedColor == color
                            ? Colors.black
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Sizes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Select Size",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: showSizeChart,
                  child: const Text(
                    "View Size Chart",
                    style: TextStyle(color: Colors.lightBlue),
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 10,
              children: widget.availableSizes.map((size) {
                return ChoiceChip(
                  label: Text(size),
                  selected: selectedSize == size,
                  onSelected: (_) => setState(() => selectedSize = size),
                  selectedColor: Colors.lightBlue.shade100,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Quantity Selector
            Row(
              children: [
                const Text(
                  "Quantity:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _decrementQuantity,
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        onPressed: _incrementQuantity,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: pickDesign,
              icon: const Icon(Icons.upload),
              label: const Text("Upload Your Design"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _addToCart,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Add to Cart",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _placeOrder,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.lightBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Place Order",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
          if (_isUploading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.lightBlue),
                    SizedBox(height: 16),
                    Text(
                      'Uploading custom design...',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
