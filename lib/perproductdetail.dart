import 'package:flutter/material.dart';
// NOTE: The standard Flutter library 'package:flutter/services.dart' is now
// omitted, and input formatting is handled via the onChanged callback.

// --- Inventory Detail Screen Widget ---

class InventoryDetailScreen extends StatefulWidget {
  final String itemName;
  final int initialQuantity;

  const InventoryDetailScreen({
    super.key,
    this.itemName = 'Product Item Name',
    this.initialQuantity = 120, // Default value from the screenshot
  });

  @override
  State<InventoryDetailScreen> createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends State<InventoryDetailScreen> {
  // State variables
  late int _currentQuantity;
  int? _currentThreshold; // Nullable if no threshold is set
  String _refillInput = ''; // Holds the text input for Refills
  String _manualInput = ''; // Holds the text input for Add or Subtract

  // Controllers for text fields
  final TextEditingController _thresholdController = TextEditingController();
  final TextEditingController _refillController = TextEditingController();
  final TextEditingController _manualController = TextEditingController();

  // Focus nodes to manage keyboard focus
  final FocusNode _refillFocusNode = FocusNode();
  final FocusNode _manualFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.initialQuantity;

    // Listen to changes in the refill and manual input fields
    _refillController.addListener(() {
      setState(() {
        _refillInput = _refillController.text;
      });
    });
    _manualController.addListener(() {
      setState(() {
        _manualInput = _manualController.text;
      });
    });
  }

  @override
  void dispose() {
    _thresholdController.dispose();
    _refillController.dispose();
    _manualController.dispose();
    _refillFocusNode.dispose();
    _manualFocusNode.dispose();
    super.dispose();
  }

  // --- Core Logic Functions ---

  // Custom function to ensure only digits are processed
  String _filterDigits(String text) {
    // Regex to remove anything that is not a digit
    return text.replaceAll(RegExp(r'[^0-9]'), '');
  }

  void _applyThreshold() {
    final text = _thresholdController.text.trim();
    final value = int.tryParse(text);

    if (value != null && value >= 0) {
      setState(() {
        _currentThreshold = value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Threshold set to $value')),
      );
      _thresholdController.clear();
      FocusScope.of(context).unfocus(); // Dismiss keyboard
    } else if (text.isEmpty) {
      setState(() {
        _currentThreshold = null; // Clear threshold if input is empty
      });
    } else {
      _showErrorSnackBar('Invalid number for Threshold.');
    }
  }

  void _refillStock() {
    final value = int.tryParse(_refillInput);

    if (value != null && value > 0) {
      setState(() {
        _currentQuantity += value;
      });
      _showSuccessSnackBar('$value added. New quantity: $_currentQuantity');
      _refillController.clear();
      _manualController.clear();
      _manualFocusNode.unfocus();
      _refillFocusNode.unfocus();
    } else {
      _showErrorSnackBar('Enter a quantity greater than zero to refill.');
    }
  }

  void _adjustQuantity(bool isAdd) {
    final value = int.tryParse(_manualInput);

    if (value != null && value > 0) {
      setState(() {
        if (isAdd) {
          _currentQuantity += value;
        } else {
          // Prevent subtracting more than available
          _currentQuantity = (_currentQuantity - value).clamp(0, _currentQuantity);
        }
      });

      final action = isAdd ? 'Added' : 'Subtracted';
      _showSuccessSnackBar('$value $action. New quantity: $_currentQuantity');
      _manualController.clear();
      _refillController.clear(); // Clear other field
      _manualFocusNode.unfocus();
      _refillFocusNode.unfocus();
    } else {
      _showErrorSnackBar('Enter a quantity greater than zero to adjust.');
    }
  }

  void _saveChanges() {
    // In a real app, this is where you'd call an API service.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Changes Saved! Quantity: $_currentQuantity, Threshold: ${_currentThreshold ?? 'None'}'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.lightBlue,
      ),
    );
  }

  // --- UI Helper Widgets ---

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildQuantityText(String label, int value, {Color color = Colors.black}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    // Check if any refill/manual input has a valid number > 0 for button enablement
    final bool canRefill = int.tryParse(_refillInput) != null && int.tryParse(_refillInput)! > 0;
    final bool canAdjust = int.tryParse(_manualInput) != null && int.tryParse(_manualInput)! > 0;

    // Check if the current stock is below the threshold for color indication
    final bool isBelowThreshold = _currentThreshold != null && _currentQuantity < _currentThreshold!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.itemName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      // Body Content
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // 1. Current Quantity Display
            _buildQuantityText(
              'Current Quantity',
              _currentQuantity,
              color: isBelowThreshold ? Colors.red.shade700 : Colors.black,
            ),
            const SizedBox(height: 16),

            // 2. Threshold Section
            _buildSectionTitle('Threshold'),
            TextFormField(
              controller: _thresholdController,
              keyboardType: TextInputType.number,
              // REMOVED inputFormatters
              onChanged: (value) {
                // Manual filtering for digits
                final filtered = _filterDigits(value);
                if (value != filtered) {
                  _thresholdController.value = _thresholdController.value.copyWith(
                    text: filtered,
                    selection: TextSelection.collapsed(offset: filtered.length),
                  );
                }
              },
              decoration: InputDecoration(
                hintText: _currentThreshold == null
                    ? 'Set low stock warning (optional)'
                    : 'Current: ${_currentThreshold!}',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check, color: Colors.blueAccent),
                  onPressed: _applyThreshold,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onEditingComplete: _applyThreshold,
            ),

            // 3. Refills Section
            _buildSectionTitle('Refills'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _refillController,
                    focusNode: _refillFocusNode,
                    keyboardType: TextInputType.number,
                    // REMOVED inputFormatters
                    onChanged: (value) {
                      final filtered = _filterDigits(value);
                      if (value != filtered) {
                        _refillController.value = _refillController.value.copyWith(
                          text: filtered,
                          selection: TextSelection.collapsed(offset: filtered.length),
                        );
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Quantity to add',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: canRefill ? _refillStock : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    minimumSize: const Size(0, 50), // Match height of text field
                  ),
                  child: const Text('Refill', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            // 4. Add or Subtract Section
            _buildSectionTitle('Add or Subtract'),
            Row(
              children: [
                // Input Field for manual adjustment
                Expanded(
                  child: TextFormField(
                    controller: _manualController,
                    focusNode: _manualFocusNode,
                    keyboardType: TextInputType.number,
                    // REMOVED inputFormatters
                    onChanged: (value) {
                      final filtered = _filterDigits(value);
                      if (value != filtered) {
                        _manualController.value = _manualController.value.copyWith(
                          text: filtered,
                          selection: TextSelection.collapsed(offset: filtered.length),
                        );
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter quantity',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Add Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: canAdjust ? () => _adjustQuantity(true) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(0, 50),
                    ),
                    child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),

                // Subtract Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: canAdjust ? () => _adjustQuantity(false) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(0, 50),
                    ),
                    child: const Text('Subtract', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80), // Padding before final button
          ],
        ),
      ),

      // Bottom Navigation Bar and Save Button
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 5. Save Changes Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          // 6. Bottom Menu
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            currentIndex: 2, // 'Inventory' is the third item (index 2)
            onTap: (index) {
              debugPrint('Tapped on index $index');
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Dashboard'),
              BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Orders'),
              BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Inventory'),
              BottomNavigationBarItem(icon: Icon(Icons.money_off), label: 'Expenses'),
            ],
          ),

        ],
      ),
    );
  }
}