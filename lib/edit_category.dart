// edit_category.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditCategoryScreen extends StatefulWidget {
  final String categoryId;
  final String currentName;
  final String? currentImageUrl;

  const EditCategoryScreen({
    super.key,
    required this.categoryId,
    required this.currentName,
    this.currentImageUrl,
  });

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  late TextEditingController _nameController;
  String? _imageUrl;
  String? _imageName;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _imageUrl = widget.currentImageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      final file = result.files.first;
      setState(() => _loading = true);
      final ref = FirebaseStorage.instance.ref().child('categories/${file.name}');
      await ref.putData(file.bytes!);
      final url = await ref.getDownloadURL();
      setState(() {
        _imageUrl = url;
        _imageName = file.name;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('categories').doc(widget.categoryId).update({
        'name': name,
        'imageUrl': _imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
      Navigator.pop(context);
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Category')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Category name')),
          const SizedBox(height: 12),
          _imageUrl != null
              ? Image.network(_imageUrl!, height: 120, fit: BoxFit.cover)
              : const SizedBox(height: 120, child: Center(child: Text('No image'))),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: _pickImage, child: Text(_imageName != null ? 'Change Image' : 'Upload Image')),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loading ? null : _save, child: _loading ? const CircularProgressIndicator() : const Text('Save Changes')),
        ]),
      ),
    );
  }
}
