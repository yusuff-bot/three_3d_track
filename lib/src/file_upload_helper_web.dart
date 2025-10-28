// Web implementation for browser platforms
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

UploadTask uploadFileToStorage(
  Reference ref,
  PlatformFile file,
  SettableMetadata metadata,
) {
  // On web we only have bytes available from FilePicker when withData:true.
  if (file.bytes != null) {
    return ref.putData(file.bytes!, metadata);
  }

  throw Exception('No bytes available for ${file.name} on web');
}

// Web helper: uses putData(bytes) which requires FilePicker.withData:true.
