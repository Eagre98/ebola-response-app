import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload image file
  Future<String?> uploadImage(File file, String alertId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final ref = _storage.ref().child('alerts/$alertId/images/$fileName');

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        String downloadUrl = await ref.getDownloadURL();
        return downloadUrl;
      }
      return null;
    } catch (e) {
      print('Upload image error: $e');
      return null;
    }
  }

  // Upload video file
  Future<String?> uploadVideo(File file, String alertId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final ref = _storage.ref().child('alerts/$alertId/videos/$fileName');

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        String downloadUrl = await ref.getDownloadURL();
        return downloadUrl;
      }
      return null;
    } catch (e) {
      print('Upload video error: $e');
      return null;
    }
  }

  // Upload multiple images
  Future<List<String>> uploadMultipleImages(
      List<File> files, String alertId) async {
    List<String> uploadedUrls = [];

    for (File file in files) {
      String? url = await uploadImage(file, alertId);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }

    return uploadedUrls;
  }

  // Upload multiple videos
  Future<List<String>> uploadMultipleVideos(
      List<File> files, String alertId) async {
    List<String> uploadedUrls = [];

    for (File file in files) {
      String? url = await uploadVideo(file, alertId);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }

    return uploadedUrls;
  }

  // Delete file from storage
  Future<void> deleteFile(String downloadUrl) async {
    try {
      Reference ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      print('Delete file error: $e');
    }
  }

  // Get upload progress stream
  Stream<TaskSnapshot> getUploadProgress(UploadTask uploadTask) {
    return uploadTask.snapshotEvents;
  }
}
