import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String price;
  final String description;
  final List<String> imageUrls;
  final String? videoUrl;
  final String? modelUrl; // 3D model URL
  final String? material; // Material info
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

  // Create Product object from Firestore map
  factory Product.fromMap(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId,
      name: data['name'] ?? 'Unknown Product',
      price: data['price']?.toString() ?? '0',
      description: data['description'] ?? 'No description available.',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      videoUrl: data['videoUrl'],
      modelUrl: data['modelUrl'],
      material: data['material'],
      availableColors: (data['colors'] as List? ?? [])
          .map((colorString) => _stringToColor(colorString))
          .whereType<Color>()
          .toList(),
      availableSizes: List<String>.from(data['sizes'] ?? []),
    );
  }

  // Convert Product object to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
      'modelUrl': modelUrl,
      'material': material,
      'colors': availableColors.map((c) => _colorToString(c)).toList(),
      'sizes': availableSizes,
    };
  }

  // --- Private helpers for color conversion ---
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

  // Public helper so other files can convert string names to Color.
  static Color parseColor(String colorString) => _stringToColor(colorString);

  static String _colorToString(Color c) {
    if (c == Colors.red) return 'red';
    if (c == Colors.green) return 'green';
    if (c == Colors.blue) return 'blue';
    if (c == Colors.yellow) return 'yellow';
    if (c == Colors.white) return 'white';
    if (c == Colors.grey) return 'gray';
    return 'custom';
  }
}
