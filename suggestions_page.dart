import 'package:flutter/material.dart';
import 'customerdetailsuggestion.dart'; // Make sure this import is correct

// --- (You can likely remove SuggestionDetailsPlaceholder now) ---
// class SuggestionDetailsPlaceholder extends StatelessWidget {
//   final String customerName;
//   const SuggestionDetailsPlaceholder({super.key, required this.customerName});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(customerName)),
//       body: Center(child: Text('Details for $customerName')),
//     );
//   }
// }

// --- Customer Suggestions Page Widget ---
class CustomerSuggestionsPage extends StatefulWidget {
  const CustomerSuggestionsPage({super.key});

  @override
  State<CustomerSuggestionsPage> createState() => _CustomerSuggestionsPageState();
}

class _CustomerSuggestionsPageState extends State<CustomerSuggestionsPage> {
  // --- State Variables for Filters ---
  final List<String> _dateOptions = ['Date', 'Today', 'Last Week', 'Last Month', 'Last Year'];
  final List<String> _typeOptions = ['Type', 'Phone Case', 'Miniature', 'Model', 'Props', 'Jewelry', 'Art', 'Decor', 'Mechanical', 'Prototype', 'Holder'];
  final List<String> _customerOptions = ['Customer', 'Sam Miller', 'Jennifer Smith', 'Noah Evans', 'Sophia Bennett', 'Liam Davis', 'Isabella Foster', 'Ethan Parker', 'Mia Harper', 'Mason Cooper', 'Ava Hayes'];

  String _selectedDate = 'Date';
  String _selectedType = 'Type';
  String _selectedCustomer = 'Customer';

  // --- MODIFIED Sample data for the list ---
  // Added keys needed by CustomerDetailSuggestion
  // Using 'assets/avatar.png' for all avatars as requested
  final List<Map<String, String>> _allSuggestions = [
    {
      "name": "Sam Miller",
      "contact": "Email: sam.miller@example.com",
      "topic": "Board game miniatures",
      "type": "Miniature",
      "avatar_asset": "assets/avatar.png",
      "suggestion_text": "Need detailed miniatures for my board game. Prefer resin.",
      "preview_image_url": "", // Empty network URL
      "local_preview_asset": "assets/miniature.png", // <--- NEW LOCAL ASSET
      "model_file_name": "miniature_base.stl",
      "model_file_size": "850 KB",
      "model_thumbnail_url": "assets/miniature.png",
    },
    {
      "name": "Jennifer Smith",
      "contact": "Email: jennifer.smith@email.com",
      "topic": "Custom phone cases",
      "type": "Phone Case",
      "avatar_asset": "assets/avatar.png",
      "suggestion_text": "Looking for a custom-designed phone case that incorporates a unique geometric pattern with a matte finish. The case should be durable and provide excellent protection for my phone. I've attached some reference images for the pattern and finish I have in mind.",
      "preview_image_url": "", // Empty network URL
      "local_preview_asset": "assets/phone.png", // <--- NEW LOCAL ASSET
      "model_file_name": "Geometric Case.stl",
      "model_file_size": "1.2 MB",
      "model_thumbnail_url": "assets/phone.png",
    },
    {
      "name": "Noah Evans",
      "contact": "Email: noah.evans@example.com",
      "topic": "Architectural models",
      "type": "Model",
      "avatar_asset": "assets/avatar.png",
      "suggestion_text": "Requesting a scaled model of a building design.",
      "preview_image_url": "", // Empty network URL
      "local_preview_asset": "assets/other.png", // <--- NEW LOCAL ASSET
      "model_file_name": "building_v2.obj",
      "model_file_size": "5.5 MB",
      "model_thumbnail_url": "assets/other.png",
    },
    {
      "name": "Sophia Bennett",
      "contact": "Phone: +91 2345678910",
      "topic": "Cosplay props",
      "type": "Props",
      "avatar_asset": "assets/avatar.png",
      "suggestion_text": "Need a prop sword designed from concept art.",
      "preview_image_url": "", // Empty network URL
      "local_preview_asset": "assets/toy.png", // <--- Reusing asset
      "model_file_name": "prop_sword.fbx",
      "model_file_size": "2.1 MB",
      "model_thumbnail_url": "assets/toy.png",
    },
    {
      "name": "Liam Davis",
      "contact": "Email: liam.davis@example.com",
      "topic": "Jewelry designs",
      "type": "Jewelry",
      "avatar_asset": "assets/avatar.png",
      "suggestion_text": "Custom pendant design based on sketch.",
      "preview_image_url": "", // Empty network URL
      "local_preview_asset": "assets/jewellery.png", // <--- Reusing asset
      "model_file_name": "pendant.3dm",
      "model_file_size": "500 KB",
      "model_thumbnail_url": "assets/jewellery.png",
    },
    {
      "name": "Isabella Foster",
      "contact": "Phone: +91 7412583697",
      "topic": "Artistic sculptures",
      "type": "Art",
      "avatar_asset": "assets/avatar.png",
      "suggestion_text": "Abstract sculpture for office space.",
      "preview_image_url": "", // Empty network URL
      "local_preview_asset": "assets/vase3.png", // <--- Reusing asset
      "model_file_name": "abstract_form.stl",
      "model_file_size": "3.0 MB",
      "model_thumbnail_url": "assets/vase3.png",
    },
    {
      "name": "Ethan Parker",
      "contact": "Email: ethan.parker@example.com",
      "topic": "Educational models",
      "type": "Model",
      "avatar_asset": "assets/avatar.png",
      "suggestion_text": "Model of a human heart for teaching.",
      "preview_image_url": "", // Empty network URL
      "local_preview_asset": "assets/bookmarks.png", // <--- Reusing asset
      "model_file_name": "heart_anatomy.stl",
      "model_file_size": "4.2 MB",
      "model_thumbnail_url": "assets/bookmarks.png",
    },
    {
      "name": "Mia Harper",
      "contact": "Phone: +91 5649871285",
      "topic": "Home decor items",
      "type": "Decor",
      "avatar_asset": "assets/avatar.png",
      "suggestion_text": "Unique wall design.",
      "preview_image_url": "", // Empty network URL
      "local_preview_asset": "assets/wall.png", // <--- Reusing asset
      "model_file_name": "wall_clock.stl",
      "model_file_size": "1.8 MB",
      "model_thumbnail_url": "assets/wall.png",
    },
    {
      "name": "Mason Cooper",
      "contact": "Email: mason.cooper@example.com",
      "topic": "Holder parts",
      "type": "Holder",
      "avatar_asset": "assets/avatar.png",
      "suggestion_text": "Holder",
      "preview_image_url": "", // Empty network URL
      "local_preview_asset": "assets/holder.png", // <--- Reusing asset
      "model_file_name": "gear_part_v3.step",
      "model_file_size": "300 KB",
      "model_thumbnail_url": "assets/holder.png",
    },
    {
      "name": "Ava Hayes",
      "contact": "Phone: +91 7529513698",
      "topic": "Prototypes",
      "type": "Prototype",
      "avatar_asset": "assets/avatar.png",
      "suggestion_text": "Prototype enclosure for electronic device.",
      "preview_image_url": "", // Empty network URL
      "local_preview_asset": "assets/vase1.png", // <--- Reusing asset
      "model_file_name": "enclosure_rev2.stl",
      "model_file_size": "2.5 MB",
      "model_thumbnail_url": "assets/vase1.png",
    },
  ];
  // --- END MODIFICATION ---

  // --- Filtered List ---
  List<Map<String, String>> get _filteredSuggestions {
    List<Map<String, String>> filtered = List.from(_allSuggestions);

    // NOTE: Date filtering is complex and not fully implemented with the current data.
    // The print statement acts as a placeholder for future implementation.
    if (_selectedDate != 'Date') {
      debugPrint("Date filter selected: $_selectedDate (Actual date filtering logic is placeholder)");
      // Example: filter based on a 'date_added' key if it existed
    }

    if (_selectedType != 'Type') {
      filtered = filtered.where((s) => s['type'] == _selectedType).toList();
    }

    if (_selectedCustomer != 'Customer') {
      filtered = filtered.where((s) => s['name'] == _selectedCustomer).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> displayList = _filteredSuggestions;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Customer Suggestions',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- Filter Dropdowns Row ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    options: _dateOptions,
                    currentValue: _selectedDate,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() => _selectedDate = newValue);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterDropdown(
                    options: _typeOptions,
                    currentValue: _selectedType,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() => _selectedType = newValue);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterDropdown(
                    options: _customerOptions,
                    currentValue: _selectedCustomer,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() => _selectedCustomer = newValue);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // --- Suggestions List ---
          Expanded(
            child: ListView.builder(
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final suggestion = displayList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      _buildSuggestionTile(
                        name: suggestion['name']!,
                        contact: suggestion['contact']!,
                        topic: suggestion['topic']!,
                        onTap: () {
                          // Navigate to the actual detail page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerDetailSuggestion(
                                suggestionData: suggestion, // Pass the whole map
                              ),
                            ),
                          );
                          debugPrint('Tapped on ${suggestion['name']}');
                        },
                      ),
                      if (index < displayList.length - 1)
                        const Divider(height: 1, thickness: 1),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // --- Helper Widget Implementations (Fixes the error) ---
  // -------------------------------------------------------------------

  // --- Helper Widget for Filter Dropdowns ---
  Widget _buildFilterDropdown({
    required List<String> options,
    required String currentValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          style: TextStyle(color: Colors.grey[700], fontSize: 14),
          onChanged: onChanged,
          items: options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  // --- Helper Widget for Suggestion List Item ---
  Widget _buildSuggestionTile({
    required String name,
    required String contact,
    required String topic,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Placeholder (replace with actual Asset or NetworkImage later)
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blueGrey,
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    topic,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    contact,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Right-side indicator
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
} // End of _CustomerSuggestionsPageState class