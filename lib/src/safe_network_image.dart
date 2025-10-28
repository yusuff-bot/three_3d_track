import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Widget that takes an image identifier (http(s) URL, gs:// Storage URL, or empty)
/// and displays a network image while resolving gs:// URLs to download URLs.
class SafeNetworkImage extends StatelessWidget {
  final String? image;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? placeholderUrl;

  const SafeNetworkImage({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderUrl,
  });

  /// Resolve the provided image identifier to an HTTP URL. Returns null when
  /// no network image should be attempted (use local fallback).
  Future<String?> _resolve(String? img) async {
    if (img == null || img.trim().isEmpty) return null;
    final s = img.trim();
    if (s.toLowerCase().startsWith('http')) return s;
    if (s.toLowerCase().startsWith('gs://')) {
      try {
        // Convert gs:// path to an https download URL
        final url = await FirebaseStorage.instance
            .refFromURL(s)
            .getDownloadURL();
        return url;
      } catch (e) {
        // ignore: avoid_print
        print('SafeNetworkImage: failed to resolve gs:// URL $s -> $e');
        return null;
      }
    }
    // Unknown scheme: do not attempt network load
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _resolve(image),
      builder: (context, snap) {
        final String? url = snap.data;
        if (snap.connectionState == ConnectionState.waiting) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        // If we couldn't resolve a network URL, show a local fallback
        if (url == null) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                color: Colors.grey,
                size: 32,
              ),
            ),
          );
        }

        return Image.network(
          url,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            // ignore: avoid_print
            print('SafeNetworkImage: image load failed for $url -> $error');
            return Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey, size: 32),
              ),
            );
          },
        );
      },
    );
  }
}
