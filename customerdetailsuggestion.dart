import 'package:flutter/material.dart';
// Add other imports like url_launcher if needed for button actions

class CustomerDetailSuggestion extends StatelessWidget {
  final Map<String, dynamic> suggestionData;

  const CustomerDetailSuggestion({
    super.key,
    required this.suggestionData,
  });

  // Helper widget for the generic placeholder box (used for main preview and thumbnail failure)
  Widget _buildImagePlaceholder({double? width, double? height, IconData icon = Icons.broken_image}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      // Icon size is relative to the box size
      child: Center(child: Icon(icon, color: Colors.grey, size: (width ?? 40) / 2)),
    );
  }

  // Helper function for the main File Preview widget logic
  Widget _buildFilePreviewWidget(String? localAsset, String? networkUrl) {
    if (localAsset != null && localAsset.isNotEmpty) {
      return Image.asset(
        localAsset,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 250,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(width: double.infinity, height: 250),
      );
    } else if (networkUrl != null && networkUrl.isNotEmpty) {
      return Image.network(
        networkUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 250,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(width: double.infinity, height: 250),
      );
    } else {
      return _buildImagePlaceholder(width: double.infinity, height: 250);
    }
  }

  // --- NEW/MODIFIED Helper function for 3D Model Thumbnail widget logic ---
  Widget _buildModelThumbnailWidget(String? localAsset, String? networkUrl) {
    const double thumbnailSize = 80;

    // 1. Check for local asset (this is where the fix is applied)
    if (localAsset != null && localAsset.isNotEmpty) {
      return Image.asset(
        localAsset,
        width: thumbnailSize,
        height: thumbnailSize,
        fit: BoxFit.cover,
        // Fallback to the generic 3D icon if the local asset is missing
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(width: thumbnailSize, height: thumbnailSize, icon: Icons.threed_rotation),
      );
    }

    // 2. Check for network URL
    else if (networkUrl != null && networkUrl.isNotEmpty) {
      return Image.network(
        networkUrl,
        width: thumbnailSize,
        height: thumbnailSize,
        fit: BoxFit.cover,
        // Fallback to the generic 3D icon if the network image fails
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(width: thumbnailSize, height: thumbnailSize, icon: Icons.threed_rotation),
      );
    }

    // 3. Final Fallback (No path provided)
    else {
      return _buildImagePlaceholder(width: thumbnailSize, height: thumbnailSize, icon: Icons.threed_rotation);
    }
  }
  // --- END NEW/MODIFIED Helper function ---


  @override
  Widget build(BuildContext context) {
    final String customerName = suggestionData['name'] ?? 'N/A';
    final String customerContact = suggestionData['contact'] ?? 'N/A';
    final String suggestionText = suggestionData['suggestion_text'] ?? 'No suggestion provided.';

    final String? localPreviewAsset = suggestionData['local_preview_asset'];
    final String? previewImageUrl = suggestionData['preview_image_url'];

    final String modelFileName = suggestionData['model_file_name'] ?? 'model.stl';
    final String modelFileSize = suggestionData['model_file_size'] ?? 'N/A';

    // NOTE: Your _allSuggestions uses "model_thumbnail_url" for local paths.
    // We will use 'model_thumbnail_url' as the local asset key for simplicity here.
    final String? modelThumbnailUrl = suggestionData['model_thumbnail_url'];


    final String initial = customerName.isNotEmpty ? customerName[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          customerName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Customer Details Section ---
              const Text(
                'Customer Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blueGrey,
                    child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(customerContact, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- Suggestion Section ---
              const Text(
                'Suggestion',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(suggestionText, style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.4)),
              const SizedBox(height: 24),

              // --- File Preview Section (Uses helper) ---
              const Text(
                'File Preview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildFilePreviewWidget(localPreviewAsset, previewImageUrl),
              ),
              const SizedBox(height: 24),

              // --- 3D Model Section (Uses new thumbnail helper) ---
              const Text(
                '3D Model',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(modelFileName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(modelFileSize, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () { print("Download button tapped for $modelFileName"); },
                          icon: const Icon(Icons.download_outlined, size: 20),
                          label: const Text('Download'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200], foregroundColor: Colors.black87, elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // --- MODIFIED HERE: Use the new thumbnail helper function ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildModelThumbnailWidget(modelThumbnailUrl, null), // We use modelThumbnailUrl as the local asset source
                  ),
                  // --- END MODIFIED THUMBNAIL ---
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),

      // --- Fixed Bottom Button ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () { print("Contact Customer button tapped!"); },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Contact Customer'),
        ),
      ),
    );
  }
}