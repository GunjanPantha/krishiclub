import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirestoreDatabase {
  // Current logged-in user
  User? user = FirebaseAuth.instance.currentUser;

  // Collection reference for crops
  final CollectionReference crops =
      FirebaseFirestore.instance.collection("crops");

  // Firebase Storage instance
  final FirebaseStorage storage = FirebaseStorage.instance;

  // Upload crop details along with the picture
  Future<void> addCropDetails(
      String cropName, String quantity, String address, File imageFile) async {
    if (user == null) {
      throw Exception("No authenticated user found.");
    }

    try {
      // Upload image to Firebase Storage
      String fileName =
          'crops/${user!.uid}/${DateTime.now().millisecondsSinceEpoch}.png';
      Reference storageRef = storage.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Save crop details along with image URL to Firestore
      await crops.add({
        'userEmail': user!.email,
        'cropName': cropName,
        'quantity': quantity,
        'address': address,
        'imageUrl': downloadUrl,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Error uploading crop details: $e');
      throw e; // Rethrow the error for further handling
    }
  }

  // New method to add crop details using imageUrl
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addCropDetailsWithImageUrl(
      String cropName, String quantity, String address, String imageUrl) async {
    if (user == null) {
      throw Exception("No authenticated user found.");
    }
    await _db.collection('crops').add({
      'userEmail': user!.email,
      'cropName': cropName,
      'quantity': quantity,
      'address': address,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Read crops from database
  Stream<QuerySnapshot> getCropsStream() {
    return crops.orderBy('timestamp', descending: true).snapshots();
  }

  // Get user role
  Future<String> getUserRole() async {
    if (user != null) {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: user!.email).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs[0]['role'] ?? 'Buyer';
      }
    }
    return 'Buyer'; // Default role if not found
  }
}
