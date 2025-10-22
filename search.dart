import 'package:flutter/material.dart';
import 'searchresult.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _recentSearches = [
    "Home Decor",
    "Miniatures",
    "Lamps",
  ];
  final List<String> _allSuggestions = [
    "3D Printed Miniature",
    "3D Lamp",
    "3D Keychain",
    "3D Photo Frame",
    "Smart Bulb",
    "Custom Mug",
  ];

  List<String> _filteredSuggestions = [];

  void _onSearchChanged(String value) {
    setState(() {
      _filteredSuggestions = _allSuggestions
          .where((item) => item.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  void _onSuggestionTap(String query) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsPage(searchQuery: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _controller,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: "Search products...",
            border: InputBorder.none,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () {
                _controller.clear();
                _onSearchChanged('');
              },
            )
                : null,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (_controller.text.isEmpty) ...[
              const Text("Recent Searches",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ..._recentSearches.map((term) => ListTile(
                leading: const Icon(Icons.history),
                title: Text(term),
                onTap: () => _onSuggestionTap(term),
              )),
              const SizedBox(height: 16),
              const Text("Suggestions",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ..._allSuggestions.map((s) => ListTile(
                leading: const Icon(Icons.search),
                title: Text(s),
                onTap: () => _onSuggestionTap(s),
              )),
            ] else ...[
              ..._filteredSuggestions.map((s) => ListTile(
                leading: const Icon(Icons.search),
                title: Text(s),
                onTap: () => _onSuggestionTap(s),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
