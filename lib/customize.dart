import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class customize extends StatefulWidget {
  final String productName;
  final String productImage;
  final List<Color> availableColors;
  final List<String> availableSizes;

  const customize({
    super.key,
    required this.productName,
    required this.productImage,
    required this.availableColors,
    required this.availableSizes,
  });

  @override
  State<customize> createState() => _customizeState();
}

class _customizeState extends State<customize> {
  Color? selectedColor;
  String? selectedSize;
  File? uploadedDesign;

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
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Size", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Dimensions (cm)", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ]),
                  TableRow(children: [
                    Padding(padding: EdgeInsets.all(8), child: Text("Small")),
                    Padding(padding: EdgeInsets.all(8), child: Text("10 x 10 x 15")),
                  ]),
                  TableRow(children: [
                    Padding(padding: EdgeInsets.all(8), child: Text("Medium")),
                    Padding(padding: EdgeInsets.all(8), child: Text("15 x 15 x 22")),
                  ]),
                  TableRow(children: [
                    Padding(padding: EdgeInsets.all(8), child: Text("Large")),
                    Padding(padding: EdgeInsets.all(8), child: Text("20 x 20 x 30")),
                  ]),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: const Center(
                    child: Text("Close", style: TextStyle(color: Colors.white))),
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

  @override
  Widget build(BuildContext context) {
    final double scale = getSizeScale();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text("Customize Your Product",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Product Preview with Color & Size
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
                  // Product Image
                  Image.asset(
                    widget.productImage,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    color: selectedColor != null
                        ? selectedColor!.withOpacity(0.5)
                        : null,
                    colorBlendMode: BlendMode.modulate,
                  ),
                  // Uploaded Design
                  if (uploadedDesign != null)
                    Image.file(
                      uploadedDesign!,
                      fit: BoxFit.contain,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(widget.productName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text("Select Color",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          // Color options
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Select Size",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              TextButton(
                  onPressed: showSizeChart,
                  child: const Text("View Size Chart",
                      style: TextStyle(color: Colors.lightBlue)))
            ],
          ),
          const SizedBox(height: 10),
          // Size options
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
          ElevatedButton.icon(
            onPressed: pickDesign,
            icon: const Icon(Icons.upload),
            label: const Text("Upload Your Design"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Center(
                child: Text("Add to Cart",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white))),
          ),
        ]),
      ),
    );
  }
}
