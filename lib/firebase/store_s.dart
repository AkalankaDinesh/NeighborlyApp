import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StoreS {
  final FirebaseStorage _storage;

  StoreS({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  // Function to upload an image to Firebase Storage and get the image URL
  Future<Map<String, String>> uploadImage(
    File imageFile,
    Function(double) progressCallback,
  ) async {
    try {
      final imgRename = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = _storage.ref().child('Images/$imgRename.jpg');

      UploadTask uploadTask = storageRef.putFile(imageFile);

      // Listen to the upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.state == TaskState.running) {
          double progress = (snapshot.bytesTransferred / snapshot.totalBytes);
          progressCallback(progress);
        }
      });

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return {"url": downloadUrl, "name": imgRename};
    } catch (e) {
      print("Error uploading image: $e");
      rethrow;
    }
  }
}
