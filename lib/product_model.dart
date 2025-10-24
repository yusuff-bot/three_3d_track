import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String price;
  final String description;
  final List<String> imageUrls;
  final String? videoUrl;
  final String? modelUrl; // NEW .glb URL
  final String? material; // NEW material info
  final List<Color> availableColors;
  final List<String> availableSizes;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrls,
    this.videoUrl,
    this.modelUrl,
    this.material,
    required this.availableColors,
    required this.availableSizes,
  });

  // Factory constructor to create a Product from a Firestore map
  factory Product.fromMap(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId,
      name: data['name'] ?? 'Unknown Product',
      price: data['price']?.toString() ?? '0',
      description: data['description'] ?? 'No description available.',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      videoUrl: data['videoUrl'] ?? '',
      modelUrl: data['modelUrl'] ?? '',
      material: data['material'] ?? '',
      availableColors: (data['colors'] as List? ?? [])
          .map((colorString) => _stringToColor(colorString))
          .whereType<Color>()
          .toList(),
      availableSizes: List<String>.from(data['sizes'] ?? []),
    );
  }

  // --- THIS IS THE FIX ---
  // The 'toMap' method now lives INSIDE the Product class
  Map<String, dynamic> toMap() {
    return {
      'name': name, // NOW this has access to the 'name' field
      'price': price, // And the 'price' field
      'description': description, // And so on
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
      'modelUrl': modelUrl,
      'material': material,
      'colors': availableColors.map((c) => _colorToString(c)).toList(),
      'sizes': availableSizes,
    };
  }

  // --- HELPER FUNCTIONS ---
  // It's also good practice to make these private static helpers
  // inside the class if they are only used here.

  static const Map<String, Color> _colorMap = {
    'red': Colors.red,
    'green': Colors.green,
    'blue': Colors.blue,
    'yellow': Colors.yellow,
    'white': Colors.white,
    'gray': Colors.grey,
  };

  static Color _stringToColor(String colorString) {
    return _colorMap[colorString.toLowerCase()] ?? Colors.grey;
  }

  static String _colorToString(Color c) {
    if (c == Colors.red) return 'red';
    if (c == Colors.green) return 'green';
    if (c == Colors.blue) return 'blue';
    if (c == Colors.yellow) return 'yellow';
    if (c == Colors.white) return 'white';
    if (c == Colors.grey) return 'gray';
    return 'custom';
  }
} // <-- THIS IS THE FINAL CLOSING BRACE FOR THE CLASS