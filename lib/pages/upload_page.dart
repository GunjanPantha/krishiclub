import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import '../database/firestore.dart';
import '../components/districts.dart';

class UploadPage extends StatefulWidget {
  final void Function()? onTap;

  const UploadPage({Key? key, this.onTap}) : super(key: key);

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  String cropName = '';
  String quantity = '';
  String address = '';
  File? imageFile;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final int _maxFileSize = 10 * 1024 * 1024; // 10MB

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile =
        await _picker.pickImage(source: source, imageQuality: 50);

    if (pickedFile != null) {
      File selectedImage = File(pickedFile.path);

      int imageSize = await selectedImage.length();
      if (imageSize > _maxFileSize) {
        _showErrorDialog('Image size exceeds 10MB limit.');
        return;
      }

      setState(() {
        imageFile = selectedImage;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _upload() async {
    if (cropName.isEmpty ||
        quantity.isEmpty ||
        address.isEmpty ||
        imageFile == null) {
      _showErrorDialog('Please fill all fields and upload an image.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload the image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('crop_images/${imageFile!.path.split('/').last}');
      final uploadTask = storageRef.putFile(imageFile!);

      // Wait for the upload to complete
      await uploadTask.whenComplete(() => null);

      // Get the download URL of the uploaded image
      final downloadUrl = await storageRef.getDownloadURL();

      // Now add crop details to Firestore
      await FirestoreDatabase()
          .addCropDetailsWithImageUrl(cropName, quantity, address, downloadUrl);

      _showSuccessDialog('Crop details uploaded successfully.');

      // Clear the form after upload
      setState(() {
        cropName = '';
        quantity = '';
        address = '';
        imageFile = null;
      });

      widget.onTap?.call();
    } catch (e) {
      _showErrorDialog('Failed to upload crop details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Crop Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isLoading) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 20),
              ],
              TextFormField(
                decoration: const InputDecoration(labelText: 'Crop Name'),
                onChanged: (value) => setState(() => cropName = value),
                initialValue: cropName,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => setState(() => quantity = value),
                initialValue: quantity,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: 'Address of the Farmer'),
                items: districts
                    .map((district) => DropdownMenuItem<String>(
                          value: district,
                          child: Text(district),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => address = value ?? ''),
                value: address.isEmpty ? null : address,
                isExpanded: true,
              ),
              const SizedBox(height: 10),
              if (imageFile != null)
                Column(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          imageFile!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ElevatedButton(
                onPressed: imageFile == null
                    ? () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: const Text('Take a photo'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _pickImage(ImageSource.camera);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.photo_library),
                                    title: const Text('Choose from gallery'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _pickImage(ImageSource.gallery);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    : null, // Disable button if an image is already selected
                child: const Text('Upload Image'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _upload,
                child: const Text('Upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}