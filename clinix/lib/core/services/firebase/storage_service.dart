import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Storage wrapper for user-owned files (profile photos, etc.).
///
/// NOTE: medicine scanner images are sent to the FastAPI backend directly for
/// AI processing and are NOT uploaded to Storage in the current contract.
class StorageService {
  StorageService({FirebaseStorage? instance})
      : _storage = instance ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadUserFile({
    required String userId,
    required String folder,
    required File file,
    String? filename,
  }) async {
    final name = filename ?? file.uri.pathSegments.last;
    final ref = _storage.ref().child(folder).child(userId).child(name);
    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }

  Future<void> deleteByUrl(String url) =>
      _storage.refFromURL(url).delete();
}
