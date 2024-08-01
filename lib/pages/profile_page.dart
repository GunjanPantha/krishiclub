import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:krishiclub/components/my_back_button.dart';
import 'package:krishiclub/components/my_list_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserProfileImage();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser!.email)
        .get();
  }

  Future<void> _fetchUserProfileImage() async {
    var userDoc = await _getUserDetails();
    setState(() {
      profileImageUrl = userDoc.data()?['profileImageUrl'];
    });
  }

  Future<void> _uploadImageFile(File imageFile) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_images/${currentUser!.email}');
    await storageRef.putFile(imageFile);
    String downloadUrl = await storageRef.getDownloadURL();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser!.email)
        .update({'profileImageUrl': downloadUrl});

    setState(() {
      profileImageUrl = downloadUrl;
    });
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.black),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    await _uploadImageFile(File(pickedFile.path));
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.black),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    await _uploadImageFile(File(pickedFile.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Stream<QuerySnapshot> _getUserPostsStream() {
    return FirebaseFirestore.instance
        .collection('crops')
        .where('userEmail', isEqualTo: currentUser!.email)
        .snapshots();
  }

  Future<void> _deletePost(String postId) async {
    await FirebaseFirestore.instance.collection('crops').doc(postId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            var user = snapshot.data!.data();
            if (user == null)
              return const Center(child: Text("No data available."));

            String userRole = user['role'];
            String username = user['username'];
            String email = user['email'];

            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 50.0, left: 25),
                  child: Row(children: [MyBackButton()]),
                ),
                const SizedBox(height: 25),
                Stack(
                  children: [
                    Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(64),
                        image: profileImageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(profileImageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: profileImageUrl == null
                          ? const Icon(Icons.person, size: 64)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _showImageSourceOptions,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Text(
                  username,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  email,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 118, 118, 118)),
                ),
                const SizedBox(height: 10),
                Text(
                  userRole,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 118, 118, 118)),
                ),
                const SizedBox(height: 20),
                if (userRole == 'Farmer') ...[
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "My Posts",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _getUserPostsStream(),
                      builder: (context, postSnapshot) {
                        if (postSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        var userPosts = postSnapshot.data?.docs ?? [];

                        if (userPosts.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(25),
                              child: Text("No Posts."),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: userPosts.length,
                          itemBuilder: (context, index) {
                            var post = userPosts[index];
                            String postId = post.id;
                            String cropName =
                                post['cropName'] ?? 'No Crop Name';
                            String quantity = post['quantity'] ?? 'No Quantity';
                            String address = post['address'] ?? 'No Address';
                            String imageUrl = post['imageUrl'] ?? '';
                            String userEmail = post['userEmail'] ?? 'No Email';
                            Timestamp timestamp =
                                post['timestamp'] ?? Timestamp.now();
                            String formattedTimestamp =
                                DateFormat('yyyy-MM-dd – kk:mm')
                                    .format(timestamp.toDate());

                            return InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      contentPadding: EdgeInsets.zero,
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (imageUrl.isNotEmpty)
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return Dialog(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      child: Stack(
                                                        children: [
                                                          Positioned.fill(
                                                            child:
                                                                Image.network(
                                                              imageUrl,
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                          ),
                                                          Positioned(
                                                            top: 16,
                                                            right: 16,
                                                            child: IconButton(
                                                              icon: Icon(
                                                                  Icons.close,
                                                                  color: Colors
                                                                      .white),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                height: 200,
                                                child: Image.network(imageUrl,
                                                    fit: BoxFit.cover),
                                              ),
                                            ),
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  cropName,
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  'Quantity: $quantity',
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  'Address: $address',
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  'Posted by: $userEmail',
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  'Posted on: $formattedTimestamp',
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Close'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _deletePost(postId);
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: MyListTile(
                                title: '$cropName - $quantity',
                                subTitle:
                                    'By $userEmail\nAt $address\nOn $formattedTimestamp',
                                imageUrl: imageUrl,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ] else ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Text("No additional information available."),
                    ),
                  ),
                ],
              ],
            );
          } else {
            return const Center(child: Text("No data available."));
          }
        },
      ),
    );
  }
}
