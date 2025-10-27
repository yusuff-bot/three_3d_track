import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:file_picker/file_picker.dart';
// platform-specific upload helper (conditional import)
import 'src/file_upload_helper_io.dart'
    if (dart.library.html) 'src/file_upload_helper_web.dart';

class AddProductScreen extends StatefulWidget {
  final String? categoryName;
  final String? categoryId;
  final String? subCategoryName;
  final String? subCategoryId;
  final String? productId;

  const AddProductScreen({
    super.key,
    this.categoryName,
    this.categoryId,
    this.subCategoryName,
    this.subCategoryId,
    this.productId,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _materialController = TextEditingController();
  final _colorController = TextEditingController();
  final _heightController = TextEditingController();
  final _widthController = TextEditingController();
  final _lengthController = TextEditingController();

  List<String> _uploadedPhotos = [];
  String? _photoUrl;
  String? _modelFileUrl; // supports .stl and .glb

  // Categories loaded from Firestore
  List<Map<String, String>> parentCategories = []; // {id, name}
  List<Map<String, String>> subCategories = []; // {id, name}

  String? selectedParentId;
  String? selectedParentName;
  String? selectedSubCategoryId;
  String? selectedSubCategoryName;

  // Upload state flags
  bool _isUploadingPhotos = false;
  bool _isUploadingModel = false;
  // Per-file upload progress (keyed by original file name)
  final Map<String, double> _uploadProgress = {};
  double? _modelUploadProgress;

  // (legacy dynamic category fields removed) - using typed maps above

  @override
  void initState() {
    super.initState();
    // Load categories then initialize selections if this screen was opened
    // with pre-filled category/subcategory from the caller.
    loadParentCategories().then((_) {
      if (widget.categoryId != null && widget.categoryId!.isNotEmpty) {
        selectedParentId = widget.categoryId;
        selectedParentName = widget.categoryName;
        // load subcategories and pick the passed subcategory if present
        loadSubCategories(widget.categoryId!).then((_) {
          if (widget.subCategoryId != null &&
              widget.subCategoryId!.isNotEmpty) {
            selectedSubCategoryId = widget.subCategoryId;
            selectedSubCategoryName = widget.subCategoryName;
          }
          // If editing an existing product, load its data after categories are ready
          if (widget.productId != null) {
            _loadProductForEdit(widget.productId!);
          }
          setState(() {});
        });
      }
    });
  }

  Future<void> _loadProductForEdit(String productId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();
      if (!doc.exists) return;
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return;

      // Populate fields
      _nameController.text = data['name']?.toString() ?? '';
      _priceController.text = data['price']?.toString() ?? '';
      _descriptionController.text = data['description']?.toString() ?? '';
      _materialController.text = data['material']?.toString() ?? '';
      _colorController.text = (data['colors'] is List)
          ? (data['colors'] as List).join(',')
          : (data['colors']?.toString() ?? '');

      final imgs = List<String>.from(data['imageUrls'] ?? []);
      setState(() {
        _uploadedPhotos = imgs;
        _photoUrl = imgs.isNotEmpty ? imgs.first : null;
        _modelFileUrl = data['modelUrl'] as String?;
        // If product has parent/sub ids stored, prefer them
        selectedParentId = data['parentCategoryId'] ?? selectedParentId;
        selectedParentName = data['parentCategory'] ?? selectedParentName;
        selectedSubCategoryId = data['categoryId'] ?? selectedSubCategoryId;
        selectedSubCategoryName = data['category'] ?? selectedSubCategoryName;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load product for edit: $e');
    }
  }

  // --- DEBUG HELPERS ---
  /// Performs a resumable POST-start request using the current user's ID token
  /// and shows the full response in a dialog and in the console.

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _materialController.dispose();
    _colorController.dispose();
    _heightController.dispose();
    _widthController.dispose();
    _lengthController.dispose();
    super.dispose();
  }

  // --- FIRESTORE FETCH METHODS ---
  // Load top-level categories from `categories` collection
  Future<void> loadParentCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .get();
      parentCategories = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        return {'id': doc.id, 'name': data?['name']?.toString() ?? 'Unnamed'};
      }).toList();
      setState(() {});
    } catch (e) {
      // ignore, keep list empty
    }
  }

  // Load subcategories from categories/{parentId}/subcategories
  Future<void> loadSubCategories(String parentId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .doc(parentId)
          .collection('subcategories')
          .get();
      subCategories = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        return {'id': doc.id, 'name': data?['name']?.toString() ?? 'Unnamed'};
      }).toList();
      setState(() {});
    } catch (e) {
      subCategories = [];
      setState(() {});
    }
  }

  // --- FILE PICKING ---
  Future<void> _pickPhoto() async {
    if (_isUploadingPhotos) return; // prevent duplicate taps
    // Require an authenticated user to perform uploads. If the app doesn't
    // sign users in at startup, prompt the developer/user to sign in.
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in before uploading files')),
      );
      return;
    }
    // Debug: print current auth and storage context to help diagnose permission issues
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      // ignore: avoid_print
      print('Upload debug: user.uid=$uid');
      // ignore: avoid_print
      print(
        'Upload debug: idToken (truncated)=${token != null ? token.substring(0, 60) : 'null'}...',
      );
      final storageBucket = Firebase.app().options.storageBucket;
      final projectId = Firebase.app().options.projectId;
      // ignore: avoid_print
      print(
        'Upload debug: app.projectId=$projectId, storageBucket=$storageBucket',
      );
    } catch (e) {
      // ignore: avoid_print
      print('Upload debug: failed to read Firebase app options: $e');
    }
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result == null) return;

    setState(() {
      _isUploadingPhotos = true;
    });

    List<String> uploadedUrls = [];
    for (final file in result.files) {
      final key = file.name;
      setState(() {
        _uploadProgress[key] = 0.0;
      });
      try {
        // generate a safer/unique filename to avoid collisions
        final uniqueName =
            '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        final ref = FirebaseStorage.instance.ref().child(
          'products/$uniqueName',
        );

        // Reject overly large files early on (client-side guard).
        // Allow up to 10 MB per file.
        const maxBytes = 10 * 1024 * 1024; // 10 MB
        if (file.size > maxBytes) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${file.name} is larger than 10 MB. Please choose a smaller image.',
              ),
            ),
          );
          setState(() {
            _uploadProgress.remove(key);
          });
          continue;
        }

        if (file.bytes == null) {
          // withData:true should provide bytes; if missing, show error and skip
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No bytes available for ${file.name}')),
          );
          setState(() {
            _uploadProgress.remove(key);
          });
          continue;
        }

        // Infer a basic content type from the file extension so Storage can
        // provide meaningful totalBytes and progress events on web and mobile.
        String contentType = 'application/octet-stream';
        final lower = file.extension?.toLowerCase() ?? file.name.toLowerCase();
        if (lower.endsWith('png') || lower.endsWith('.png')) {
          contentType = 'image/png';
        } else if (lower.endsWith('jpg') ||
            lower.endsWith('jpeg') ||
            lower.endsWith('.jpg') ||
            lower.endsWith('.jpeg')) {
          contentType = 'image/jpeg';
        }

        final metadata = SettableMetadata(contentType: contentType);

        // Use platform helper which will choose putFile when possible or putData.
        final uploadTask = uploadFileToStorage(ref, file, metadata);

        final sub = uploadTask.snapshotEvents.listen((snap) {
          double progress;
          if (snap.totalBytes > 0) {
            progress = snap.bytesTransferred / snap.totalBytes;
          } else if (snap.bytesTransferred > 0) {
            progress = 0.5;
          } else if (snap.state == TaskState.success) {
            progress = 1.0;
          } else {
            progress = 0.0;
          }

          // Debug logging (visible in flutter run -v)
          // ignore: avoid_print
          print(
            'Upload [$key] state=${snap.state} transferred=${snap.bytesTransferred} total=${snap.totalBytes} progress=$progress',
          );

          setState(() {
            _uploadProgress[key] = progress;
          });
        });

        await uploadTask.whenComplete(() {});
        await sub.cancel();

        final url = await ref.getDownloadURL();
        uploadedUrls.add(url);
      } catch (e, st) {
        // Surface the error so the developer knows what failed and why.
        // Show a SnackBar and an error dialog with details (truncated).
        // ignore: avoid_print
        print('Failed to upload ${file.name}: $e\n$st');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload ${file.name}: $e')),
        );
        // Show dialog with error details for easier debugging
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Upload failed'),
            content: SingleChildScrollView(
              child: Text(
                'Error uploading ${file.name}:\n$e\n\n${st.toString().split('\n').take(3).join('\n')}',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        // If this looks like an auth/permission error, provide actionable next steps
        if (e is FirebaseException &&
            (e.code == 'unauthorized' ||
                e.code == 'permission-denied' ||
                e.code == 'unauthenticated')) {
          showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Permission error'),
              content: const SingleChildScrollView(
                child: Text(
                  'This upload failed due to authorization. Possible causes:\n'
                  '1) You are not signed in. Sign in and try again.\n'
                  '2) Firebase Storage rules deny access; ensure rules allow authenticated writes.\n'
                  '3) App config may point to a different storage bucket/project. Verify `lib/firebase_options.dart` storageBucket matches your Firebase project.\n'
                  '4) Billing or bucket permissions may be blocking uploads. Check Firebase Console → Storage and try uploading a small file there.',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } finally {
        setState(() {
          _uploadProgress.remove(key);
        });
      }
    }

    setState(() {
      if (uploadedUrls.isNotEmpty) {
        _uploadedPhotos.addAll(uploadedUrls);
        _photoUrl = _uploadedPhotos.isNotEmpty ? _uploadedPhotos.first : null;
      }
      _isUploadingPhotos = false;
    });
  }

  Future<void> _pickSTLFile() async {
    if (_isUploadingModel) return; // prevent duplicate taps
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in before uploading files')),
      );
      return;
    }
    // FilePicker can throw PlatformException on some Android devices when
    // resolving content:// URIs. Wrap in try/catch and provide a fallback
    // attempt with a more permissive picker so we can still obtain bytes.
    dynamic result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['glb'],
        withData: true,
      );
    } catch (e, st) {
      // ignore: avoid_print
      print('FilePicker.pickFiles failed for .glb: $e\n$st');
      // Try a permissive fallback (any file) and filter by extension client-side.
      try {
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          withData: true,
        );
      } catch (e2, st2) {
        // Both attempts failed — surface to user with actionable steps.
        // ignore: avoid_print
        print('Fallback FilePicker.pickFiles also failed: $e2\n$st2');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to open file picker. Please check app storage permissions.',
            ),
          ),
        );
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('File picker error'),
            content: SingleChildScrollView(
              child: Text('Failed to open file picker:\n$e2'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        setState(() => _isUploadingModel = false);
        return;
      }
    }
    if (result == null) return;

    setState(() {
      _isUploadingModel = true;
      _modelUploadProgress = 0.0;
    });
    // Choose the best file to upload (prefer .glb); avoid firstWhere to
    // prevent predicate typing issues on some Android devices.
    PlatformFile pickedFile = result.files.first as PlatformFile;
    for (final dynamic f in result.files) {
      try {
        final PlatformFile pf = f as PlatformFile;
        final ext = (pf.extension ?? pf.name).toString().toLowerCase();
        if (ext.endsWith('glb')) {
          pickedFile = pf;
          break;
        }
      } catch (_) {
        continue;
      }
    }

    final file = pickedFile;
    try {
      // client-side guard for model size (allow up to 50 MB)
      const maxModelBytes = 50 * 1024 * 1024;
      if (file.size > maxModelBytes) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${file.name} is larger than 50 MB. Please choose a smaller model.',
            ),
          ),
        );
        setState(() => _isUploadingModel = false);
        return;
      }

      // use a unique filename to avoid collisions
      final uniqueName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final ref = FirebaseStorage.instance.ref().child(
        'products/models/$uniqueName',
      );

      if (file.bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to read model bytes for ${file.name}'),
          ),
        );
        setState(() => _isUploadingModel = false);
        return;
      }

      // Choose a reasonable content-type based on the picked file extension.
      final chosenExt = (file.extension ?? file.name).toString().toLowerCase();
      String contentType = 'application/octet-stream';
      if (chosenExt.endsWith('glb')) {
        contentType = 'model/gltf-binary';
      } else if (chosenExt.endsWith('stl')) {
        contentType = 'model/stl';
      } else if (chosenExt.endsWith('obj')) {
        contentType = 'application/octet-stream';
      }

      final metadata = SettableMetadata(contentType: contentType);

      // Use platform helper which will choose putData when possible or putFile.
      final uploadTask = uploadFileToStorage(ref, file, metadata);

      final sub = uploadTask.snapshotEvents.listen((snap) {
        double progress;
        if (snap.totalBytes > 0) {
          progress = snap.bytesTransferred / snap.totalBytes;
        } else if (snap.bytesTransferred > 0) {
          progress = 0.5;
        } else if (snap.state == TaskState.success) {
          progress = 1.0;
        } else {
          progress = 0.0;
        }

        // ignore: avoid_print
        print(
          'ModelUpload [${file.name}] state=${snap.state} transferred=${snap.bytesTransferred} total=${snap.totalBytes} progress=$progress',
        );

        setState(() {
          _modelUploadProgress = progress;
        });
      });

      await uploadTask.whenComplete(() {});
      await sub.cancel();

      final url = await ref.getDownloadURL();
      setState(() {
        _modelFileUrl = url;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Model uploaded successfully')),
      );
    } catch (e, st) {
      // ignore: avoid_print
      print('Failed to upload model ${file.name}: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload model file: $e')),
      );
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Model upload failed'),
          content: SingleChildScrollView(
            child: Text(
              'Error uploading model ${file.name}:\n$e\n\n${st.toString().split('\n').take(3).join('\n')}',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isUploadingModel = false;
        _modelUploadProgress = null;
      });
    }
  }

  // --- SAVE PRODUCT ---
  Future<void> _saveProduct() async {
    final name = _nameController.text.trim();
    final price = _priceController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty ||
        price.isEmpty ||
        _photoUrl == null ||
        _modelFileUrl == null ||
        selectedParentId == null ||
        selectedSubCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and upload files'),
        ),
      );
      return;
    }

    try {
      // Debug print values to help diagnose save issues
      // ignore: avoid_print
      print('Saving product: name=$name price=$price');
      // ignore: avoid_print
      print(
        'Selected parentId=$selectedParentId parentName=$selectedParentName',
      );
      // ignore: avoid_print
      print(
        'Selected subCategoryId=$selectedSubCategoryId subCategoryName=$selectedSubCategoryName',
      );
      // ignore: avoid_print
      print(
        'photoUrl=$_photoUrl modelUrl=$_modelFileUrl uploadedPhotosCount=${_uploadedPhotos.length}',
      );

      final data = {
        'name': name,
        'price': price,
        'description': description,
        'imageUrls': _uploadedPhotos.isNotEmpty ? _uploadedPhotos : [_photoUrl],
        'modelUrl': _modelFileUrl,
        'material': _materialController.text.trim(),
        'colors': _colorController.text.trim().split(','),
        'sizes': ['S', 'M', 'L'],
        'category': selectedSubCategoryName ?? '',
        'categoryId': selectedSubCategoryId ?? '',
        'parentCategory': selectedParentName ?? '',
        'parentCategoryId': selectedParentId ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      };

      // If the current user exists and has a profile document, attach owner
      // metadata so orders can surface owner contact details later.
      try {
        final currentUid = FirebaseAuth.instance.currentUser?.uid;
        if (currentUid != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUid)
              .get();
          if (userDoc.exists) {
            final ud = userDoc.data();
            if (ud is Map<String, dynamic>) {
              data['ownerId'] = currentUid;
              data['ownerName'] = ud['name']?.toString();
              data['ownerEmail'] = ud['email']?.toString();
              data['ownerPhone'] = ud['phone']?.toString();
            }
          }
        }
      } catch (_) {}

      // Use a batched write so the product is created both in the top-level
      // `products` collection and under the selected subcategory path.
      final batch = FirebaseFirestore.instance.batch();

      final productsRef = (widget.productId != null)
          ? FirebaseFirestore.instance
                .collection('products')
                .doc(widget.productId)
          : FirebaseFirestore.instance.collection('products').doc();
      batch.set(productsRef, data);

      // Also save under categories/{parentId}/subcategories/{subId}/products/{docId}
      if (selectedParentId != null && selectedSubCategoryId != null) {
        final subProductRef = FirebaseFirestore.instance
            .collection('categories')
            .doc(selectedParentId)
            .collection('subcategories')
            .doc(selectedSubCategoryId)
            .collection('products')
            .doc(productsRef.id);
        batch.set(subProductRef, data);
      }

      await batch.commit();

      // Read back the saved document to verify it was written correctly
      try {
        final savedSnapshot = await productsRef.get();
        // ignore: avoid_print
        print(
          'Saved product doc exists=${savedSnapshot.exists} id=${productsRef.id} data=${savedSnapshot.data()}',
        );
      } catch (readErr) {
        // ignore: avoid_print
        print('Warning: failed to read back saved product doc: $readErr');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      // Show detailed error dialog so you can copy the exact failure message.
      // ignore: avoid_print
      print('Failed to save product: $e');
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Failed to save product'),
          content: SingleChildScrollView(
            child: Text(
              'Error: $e\n\nPlease copy this message and paste it in the chat so I can diagnose further.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add product: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Price
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Material
            TextField(
              controller: _materialController,
              decoration: const InputDecoration(
                hintText: 'Material',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Colors
            TextField(
              controller: _colorController,
              decoration: const InputDecoration(
                hintText: 'Colors (comma separated, e.g., red,blue)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Parent Category Dropdown (loaded from `categories` collection)
            DropdownButtonFormField<String>(
              value: selectedParentId,
              hint: const Text('Select Parent Category'),
              items: parentCategories.map((parent) {
                return DropdownMenuItem<String>(
                  value: parent['id'],
                  child: Text(parent['name'] ?? 'Unnamed'),
                );
              }).toList(),
              onChanged: (value) {
                selectedParentId = value;
                selectedParentName = parentCategories.firstWhere(
                  (p) => p['id'] == value,
                )['name'];
                // Clear and load subcategories for selected parent
                selectedSubCategoryId = null;
                selectedSubCategoryName = null;
                if (value != null) loadSubCategories(value);
                setState(() {});
              },
            ),
            const SizedBox(height: 16),

            // Subcategory Dropdown (populated after parent selected)
            DropdownButtonFormField<String>(
              value: selectedSubCategoryId,
              hint: const Text('Select Subcategory'),
              items: subCategories.map((sub) {
                return DropdownMenuItem<String>(
                  value: sub['id'],
                  child: Text(sub['name'] ?? 'Unnamed'),
                );
              }).toList(),
              onChanged: (value) {
                selectedSubCategoryId = value;
                selectedSubCategoryName = subCategories.firstWhere(
                  (s) => s['id'] == value,
                )['name'];
                setState(() {});
              },
            ),
            const SizedBox(height: 16),

            // Uploaded photo thumbnails (tap to remove) + add more button
            if (_uploadedPhotos.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _uploadedPhotos.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      if (idx < _uploadedPhotos.length) {
                        final url = _uploadedPhotos[idx];
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                url,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 90,
                                  height: 90,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _uploadedPhotos.removeAt(idx);
                                    _photoUrl = _uploadedPhotos.isNotEmpty
                                        ? _uploadedPhotos.first
                                        : null;
                                  });
                                },
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.black54,
                                  child: Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      // Last item: small add-more button
                      return OutlinedButton.icon(
                        onPressed: _isUploadingPhotos ? null : _pickPhoto,
                        icon: _isUploadingPhotos
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.add),
                        label: const Text('Add'),
                      );
                    },
                  ),
                ),
              ),

            // Upload Photo (shows a tick when uploaded) and aggregate progress
            OutlinedButton(
              onPressed: _isUploadingPhotos ? null : _pickPhoto,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_uploadedPhotos.isNotEmpty)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else if (_isUploadingPhotos)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.upload_file),
                  const SizedBox(width: 8),
                  Text(
                    _uploadProgress.isNotEmpty
                        ? 'Uploading ${(_uploadProgress.values.reduce((a, b) => a + b) / _uploadProgress.length * 100).toStringAsFixed(0)}%'
                        : (_uploadedPhotos.isNotEmpty
                              ? 'Photo Uploaded'
                              : 'Upload Photo'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Upload Model file (.stl or .glb) with progress
            OutlinedButton(
              onPressed: _isUploadingModel ? null : _pickSTLFile,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_modelFileUrl != null)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else if (_modelUploadProgress != null)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.upload_file),
                  const SizedBox(width: 8),
                  Text(
                    _modelUploadProgress != null
                        ? 'Uploading ${(_modelUploadProgress! * 100).toStringAsFixed(0)}%'
                        : (_modelFileUrl != null
                              ? 'Model Uploaded'
                              : 'Upload Model (stl/glb)'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProduct,
                child: const Text('Save Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
