// IO implementation for native platforms (Android/iOS)
import 'dart:io' show File;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

UploadTask uploadFileToStorage(
  Reference ref,
  PlatformFile file,
  SettableMetadata metadata,
) {
  // Prefer putData when bytes are already provided by FilePicker. On Android
  // some URIs are content:// and cannot be directly opened via File(path).
  // Using putData when bytes are present avoids permission/path problems.
  if (file.bytes != null) {
    return ref.putData(file.bytes!, metadata);
  }

  // If no bytes are available but a local filesystem path exists, try putFile.
  if (file.path != null && file.path!.isNotEmpty) {
    try {
      final ioFile = File(file.path!);
      return ref.putFile(ioFile, metadata);
    } catch (e) {
      // If File(path) fails (e.g. content URI or permission issue),
      // surface a clearer error to the caller so they can fallback.
      throw Exception('Failed to use file.path for ${file.name}: $e');
    }
  }

  // As a last resort, throw so caller can handle it
  throw Exception(
    'No file bytes or usable file path available for ${file.name}',
  );
}

// IO helper: prefers putFile (native) and falls back to putData when needed.
