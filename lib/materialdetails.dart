import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Define the custom bright cyan color used in the Figma design buttons
const Color _brightCyan = Color(0xFF00C3F9);

// --- Inventory Detail Screen Widget ---

class MaterialDetails extends StatefulWidget {
  final String itemName;
  final int initialQuantity;
  final String unit;

  const MaterialDetails({
    super.key,
    this.itemName = 'Resin - Blue',
    this.initialQuantity = 1200,
    this.unit = 'grams',
  });

  @override
  State<MaterialDetails> createState() => _MaterialDetailsState();
}

class _MaterialDetailsState extends State<MaterialDetails> {
  // State variables
  late int _currentQuantity;
  int? _currentThreshold;
  String _refillInput = '';
  String _manualInput = '';

  // Note: Since this page is static, _selectedIndex is initialized to 2 (Inventory)
  int _selectedIndex = 2;

  // Controllers and Focus nodes
  final TextEditingController _thresholdController = TextEditingController();
  final TextEditingController _refillController = TextEditingController();
  final TextEditingController _manualController = TextEditingController();
  final FocusNode _refillFocusNode = FocusNode();
  final FocusNode _manualFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.initialQuantity;

    _refillController.addListener(() {
      setState(() { _refillInput = _refillController.text; });
    });
    _manualController.addListener(() {
      setState(() { _manualInput = _manualController.text; });
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

  // --- Core Logic Functions (remain the same) ---

  void _applyThreshold() {
    final text = _thresholdController.text.trim();
    final value = int.tryParse(text);

    if (value != null && value >= 0) {
      setState(() { _currentThreshold = value; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Threshold set to $value ${widget.unit}')),
      );
      _thresholdController.clear();
      FocusScope.of(context).unfocus();
    } else if (text.isEmpty) {
      setState(() { _currentThreshold = null; });
    } else {
      _showErrorSnackBar('Invalid number for Threshold.');
    }
  }

  void _refillStock() {
    final value = int.tryParse(_refillInput);

    if (value != null && value > 0) {
      setState(() { _currentQuantity += value; });
      _showSuccessSnackBar('$value ${widget.unit} added. New quantity: $_currentQuantity ${widget.unit}');
      _refillController.clear();
      _manualController.clear();
      FocusScope.of(context).unfocus();
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
          _currentQuantity = (_currentQuantity - value).clamp(0, _currentQuantity);
        }
      });

      final action = isAdd ? 'Added' : 'Used';
      _showSuccessSnackBar('$value ${widget.unit} $action. New quantity: $_currentQuantity ${widget.unit}');
      _manualController.clear();
      _refillController.clear();
      FocusScope.of(context).unfocus();
    } else {
      _showErrorSnackBar('Enter a quantity greater than zero to adjust.');
    }
  }

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Changes Saved! Quantity: $_currentQuantity ${widget.unit}, Threshold: ${_currentThreshold != null ? '$_currentThreshold ${widget.unit}' : 'None'}'),
        duration: const Duration(seconds: 2),
        backgroundColor: _brightCyan,
      ),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // In a real app, this would navigate to the respective main page.
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Page(index)));
  }

  // --- UI Helper Widgets (remain the same) ---
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
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    final bool canRefill = int.tryParse(_refillInput) != null && int.tryParse(_refillInput)! > 0;
    final bool canAdjust = int.tryParse(_manualInput) != null && int.tryParse(_manualInput)! > 0;
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
            const SizedBox(height: 12),

            // 1. Current Quantity Display
            const Text(
              'Current Quantity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _currentQuantity.toString(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: isBelowThreshold ? Colors.red.shade700 : Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.unit,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Threshold Section
            _buildSectionTitle('Threshold'),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                controller: _thresholdController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'Set low stock warning',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: InputBorder.none,
                  suffixText: _currentThreshold != null ? 'Current: $_currentThreshold ${widget.unit}' : null,
                  suffixStyle: TextStyle(color: Colors.grey[600]),
                ),
                onEditingComplete: _applyThreshold,
              ),
            ),

            // 3. Refills Section
            _buildSectionTitle('Refills'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: _refillController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'Quantity to add',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Refill Button
                ElevatedButton(
                  onPressed: canRefill ? _refillStock : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brightCyan,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                    minimumSize: const Size(0, 50),
                    elevation: 0,
                  ),
                  child: const Text('Refill', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            // 4. Add or Subtract Section
            _buildSectionTitle('Add or Subtract'),
            Row(
              children: [
                // Add Button (first position)
                Expanded(
                  child: ElevatedButton(
                    onPressed: canAdjust ? () => _adjustQuantity(true) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      minimumSize: const Size(0, 50),
                      elevation: 0,
                    ),
                    child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),

                // Input Field for manual adjustment (middle position)
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: _manualController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: const InputDecoration(
                        hintText: '0',
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Subtract Button (last position)
                Expanded(
                  child: ElevatedButton(
                    onPressed: canAdjust ? () => _adjustQuantity(false) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      minimumSize: const Size(0, 50),
                      elevation: 0,
                    ),
                    child: const Text('Subtract', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),

      // Fixed Bottom Save Changes Button AND Bottom Navigation
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Save Changes Button (Wrapped in Padding)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brightCyan,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 50),
                elevation: 0,
              ),
              child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          // 2. Bottom Navigation (Requested Structure)
          BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey,
            onTap: _onBottomNavTap,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
              BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Orders"),
              BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Inventory"),
              BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: "Expenses"),
            ],
          ),
        ],
      ),
    );
  }
}