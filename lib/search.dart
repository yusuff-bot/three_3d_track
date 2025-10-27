import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customerhomepage.dart';
import 'searchresult.dart';

class SearchPage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const SearchPage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _filteredResults = [];
  final List<String> _recentSearches = ["Home Decor", "Miniatures", "Lamps"];

  /// Firestore search by name or category
  Future<void> _onSearchChanged(String value) async {
    if (value.isEmpty) {
      setState(() => _filteredResults.clear());
      return;
    }

    final firestore = FirebaseFirestore.instance.collection('products');

    // Search products by name
    final nameQuery = await firestore
        .where('name', isGreaterThanOrEqualTo: value)
        .where('name', isLessThanOrEqualTo: '$value\uf8ff')
        .get();

    // Search products by category
    final categoryQuery = await firestore
        .where('category', isGreaterThanOrEqualTo: value)
        .where('category', isLessThanOrEqualTo: '$value\uf8ff')
        .get();

    // Combine results (unique)
    final results = {...nameQuery.docs, ...categoryQuery.docs}.toList();

    setState(() {
      _filteredResults = results
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  void _onSuggestionTap(String query) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchResultsPage(searchQuery: query)),
    );
  }

  void _onProductTap(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsPage(searchQuery: product['name']),
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
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => CustomerHomePage(
                  userName: widget.userName,
                  userEmail: widget.userEmail,
                ),
              ),
            );
          },
        ),
        title: TextField(
          controller: _controller,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: "Search products or categories...",
            border: InputBorder.none,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _filteredResults.clear());
                    },
                  )
                : null,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _controller.text.isEmpty
            ? ListView(
                children: [
                  const Text(
                    "Recent Searches",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ..._recentSearches.map(
                    (term) => ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(term),
                      onTap: () => _onSuggestionTap(term),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                itemCount: _filteredResults.length,
                itemBuilder: (context, index) {
                  final product = _filteredResults[index];
                  return ListTile(
                    leading: (() {
                      // prefer imageUrls (array) -> imageUrl -> image
                      String? img;
                      if (product['imageUrls'] is List &&
                          (product['imageUrls'] as List).isNotEmpty) {
                        img = (product['imageUrls'] as List).first.toString();
                      } else if (product['imageUrl'] != null) {
                        img = product['imageUrl'].toString();
                      } else if (product['image'] != null) {
                        img = product['image'].toString();
                      }

                      if (img != null && img.isNotEmpty) {
                        return Image.network(
                          img,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        );
                      }
                      return const Icon(Icons.image, color: Colors.grey);
                    })(),
                    title: Text(product['name'] ?? 'Unknown Product'),
                    subtitle: Text(product['category'] ?? ''),
                    onTap: () => _onProductTap(product),
                  );
                },
              ),
      ),
    );
  }
}
