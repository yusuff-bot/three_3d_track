import 'package:flutter/material.dart';

class FilterSortModal extends StatefulWidget {
  const FilterSortModal({super.key});

  @override
  State<FilterSortModal> createState() => _FilterSortModalState();
}

class _FilterSortModalState extends State<FilterSortModal> {
  String selectedSort = "Price: Low to High";
  String selectedAvailability = "In Stock";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sort By",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          _buildRadioOption("Price: Low to High", selectedSort, (val) {
            setState(() {
              selectedSort = val!;
            });
          }),
          _buildRadioOption("Price: High to Low", selectedSort, (val) {
            setState(() {
              selectedSort = val!;
            });
          }),
          _buildRadioOption("Popularity", selectedSort, (val) {
            setState(() {
              selectedSort = val!;
            });
          }),
          const SizedBox(height: 16),
          const Text(
            "Availability",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          _buildRadioOption("In Stock", selectedAvailability, (val) {
            setState(() {
              selectedAvailability = val!;
            });
          }),
          _buildRadioOption("Out of Stock", selectedAvailability, (val) {
            setState(() {
              selectedAvailability = val!;
            });
          }),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      selectedSort = "Price: Low to High";
                      selectedAvailability = "In Stock";
                    });
                  },
                  child: const Text("Clear Filters"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Return selected options
                    Navigator.pop(context, {
                      "sort": selectedSort,
                      "availability": selectedAvailability,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: const Text("Apply Filters"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(
      String title, String groupValue, ValueChanged<String?> onChanged) {
    return RadioListTile<String>(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: title,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: Colors.blueAccent,
    );
  }
}
