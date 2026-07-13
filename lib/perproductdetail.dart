import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Define the custom bright cyan color used in the Figma design buttons
const Color _brightCyan = Color(0xFF00C3F9);

class InventoryDetailScreen extends StatefulWidget {
  final String itemName;
  final String collectionName;

  const InventoryDetailScreen({
    super.key,
    required this.itemName,
    required this.collectionName,
  });

  @override
  State<InventoryDetailScreen> createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends State<InventoryDetailScreen> {
  // State variables for inputs
  String _refillInput = '';
  String _manualInput = '';

  // Controllers for text fields
  final TextEditingController _thresholdController = TextEditingController();
  final TextEditingController _refillController = TextEditingController();
  final TextEditingController _manualController = TextEditingController();

  // Focus nodes to manage keyboard focus
  final FocusNode _refillFocusNode = FocusNode();
  final FocusNode _manualFocusNode = FocusNode();

  // State for Bottom Navigation Bar
  int _selectedIndex = 2; // Default to 'Inventory'

  @override
  void initState() {
    super.initState();

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

  String _filterDigits(String text) {
    return text.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<void> _applyThreshold(int? currentThreshold) async {
    final text = _thresholdController.text.trim();
    final value = int.tryParse(text);

    final docRef = FirebaseFirestore.instance
        .collection(widget.collectionName)
        .doc(widget.itemName);

    if (value != null && value >= 0) {
      try {
        await docRef.update({'threshold': value});
        _showSuccessSnackBar('Threshold set to $value');
        _thresholdController.clear();
        FocusScope.of(context).unfocus();
      } catch (e) {
        _showErrorSnackBar('Failed to update threshold: $e');
      }
    } else if (text.isEmpty) {
      try {
        await docRef.update({'threshold': FieldValue.delete()});
        _showSuccessSnackBar('Threshold cleared');
        FocusScope.of(context).unfocus();
      } catch (e) {
        _showErrorSnackBar('Failed to clear threshold: $e');
      }
    } else {
      _showErrorSnackBar('Invalid number for Threshold.');
    }
  }

  Future<void> _refillStock(int currentQuantity) async {
    final value = int.tryParse(_refillInput);

    if (value != null && value > 0) {
      final docRef = FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(widget.itemName);

      try {
        final newQty = currentQuantity + value;
        await docRef.update({'quantity': newQty});
        _showSuccessSnackBar('$value added. New quantity: $newQty');
        _refillController.clear();
        _manualController.clear();
        _manualFocusNode.unfocus();
        _refillFocusNode.unfocus();
      } catch (e) {
        _showErrorSnackBar('Failed to refill stock: $e');
      }
    } else {
      _showErrorSnackBar('Enter a quantity greater than zero to refill.');
    }
  }

  Future<void> _adjustQuantity(int currentQuantity, bool isAdd) async {
    final value = int.tryParse(_manualInput);

    if (value != null && value > 0) {
      final docRef = FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(widget.itemName);

      try {
        final newQty = isAdd
            ? currentQuantity + value
            : (currentQuantity - value).clamp(0, currentQuantity);
        await docRef.update({'quantity': newQty});

        final action = isAdd ? 'Added' : 'Subtracted';
        _showSuccessSnackBar('$value $action. New quantity: $newQty');
        _manualController.clear();
        _refillController.clear();
        _manualFocusNode.unfocus();
        _refillFocusNode.unfocus();
      } catch (e) {
        _showErrorSnackBar('Failed to adjust quantity: $e');
      }
    } else {
      _showErrorSnackBar('Enter a quantity greater than zero to adjust.');
    }
  }

  void _saveChanges(int currentQty, int? currentThreshold) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Changes Saved! Quantity: $currentQty, Threshold: ${currentThreshold ?? 'None'}'),
        duration: const Duration(seconds: 2),
        backgroundColor: _brightCyan,
      ),
    );
    Navigator.of(context).pop();
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    debugPrint('Tapped on index $index');
  }

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

  Widget _buildQuantityText(String label, int value,
      {Color color = Colors.black}) {
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

  @override
  Widget build(BuildContext context) {
    final bool canRefill =
        int.tryParse(_refillInput) != null && int.tryParse(_refillInput)! > 0;
    final bool canAdjust =
        int.tryParse(_manualInput) != null && int.tryParse(_manualInput)! > 0;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(widget.itemName)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.itemName)),
            body: const Center(child: Text("Item not found.")),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final currentQuantity = data['quantity'] ?? 0;
        final currentThreshold = data['threshold'] as int?;
        final bool isBelowThreshold =
            currentThreshold != null && currentQuantity < currentThreshold;

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
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // 1. Current Quantity Display
                _buildQuantityText(
                  'Current Quantity',
                  currentQuantity,
                  color: isBelowThreshold ? Colors.red.shade700 : Colors.black,
                ),
                const SizedBox(height: 16),

                // 2. Threshold Section
                _buildSectionTitle('Threshold'),
                TextFormField(
                  controller: _thresholdController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final filtered = _filterDigits(value);
                    if (value != filtered) {
                      _thresholdController.value =
                          _thresholdController.value.copyWith(
                        text: filtered,
                        selection:
                            TextSelection.collapsed(offset: filtered.length),
                      );
                    }
                  },
                  decoration: InputDecoration(
                    hintText: currentThreshold == null
                        ? 'Set low stock warning (optional)'
                        : 'Current: $currentThreshold',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check, color: Colors.blueAccent),
                      onPressed: () => _applyThreshold(currentThreshold),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onEditingComplete: () => _applyThreshold(currentThreshold),
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
                        onChanged: (value) {
                          final filtered = _filterDigits(value);
                          if (value != filtered) {
                            _refillController.value =
                                _refillController.value.copyWith(
                              text: filtered,
                              selection: TextSelection.collapsed(
                                  offset: filtered.length),
                            );
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Quantity to add',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
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
                      onPressed: canRefill
                          ? () => _refillStock(currentQuantity)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brightCyan,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        minimumSize: const Size(0, 50),
                      ),
                      child: const Text('Refill',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),

                // 4. Add or Subtract Section
                _buildSectionTitle('Add or Subtract'),
                Row(
                  children: [
                    // Add Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: canAdjust
                            ? () => _adjustQuantity(currentQuantity, true)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(0, 50),
                        ),
                        child: const Text('Add',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Input Field
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFormField(
                          controller: _manualController,
                          focusNode: _manualFocusNode,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final filtered = _filterDigits(value);
                            if (value != filtered) {
                              _manualController.value =
                                  _manualController.value.copyWith(
                                text: filtered,
                                selection: TextSelection.collapsed(
                                    offset: filtered.length),
                              );
                            }
                          },
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: const InputDecoration(
                            hintText: 'Enter quantity',
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Subtract Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: canAdjust
                            ? () => _adjustQuantity(currentQuantity, false)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(0, 50),
                        ),
                        child: const Text('Subtract',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Save Changes Button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: ElevatedButton(
                  onPressed: () =>
                      _saveChanges(currentQuantity, currentThreshold),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brightCyan,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Save Changes',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.blueAccent,
                unselectedItemColor: Colors.grey,
                currentIndex: _selectedIndex,
                onTap: _onBottomNavTap,
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.dashboard), label: "Dashboard"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.list_alt), label: "Orders"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.inventory), label: "Inventory"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.attach_money), label: "Expenses"),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}