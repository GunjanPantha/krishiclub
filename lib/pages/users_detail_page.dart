import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // For date formatting
import 'package:krishiclub/components/my_list_tile.dart';

class UserDetailPage extends StatelessWidget {
  final String userId;
  final String email;

  const UserDetailPage({Key? key, required this.userId, required this.email}) : super(key: key);

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserDetails() async {
    return await FirebaseFirestore.instance.collection("users").doc(email).get();
  }

  Stream<QuerySnapshot> _getUserPostsStream() {
    return FirebaseFirestore.instance.collection('crops').where('userEmail', isEqualTo: email).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Details")),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            var user = snapshot.data!.data();
            if (user == null) return const Center(child: Text("No data available."));

            String userRole = user['role'];
            String username = user['username'];
            String profileImageUrl = user['profileImageUrl'] ?? '';

            return Column(
              children: [
                if (profileImageUrl.isNotEmpty)
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(profileImageUrl),
                  ),
                Text(username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(email),
                Text(userRole),

                const SizedBox(height: 20),

                if (userRole == 'Farmer') ...[
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Posts", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _getUserPostsStream(),
                      builder: (context, postSnapshot) {
                        if (postSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        var userPosts = postSnapshot.data?.docs ?? [];
                        if (userPosts.isEmpty) {
                          return const Center(child: Text("No Posts."));
                        }

                        return ListView.builder(
                          itemCount: userPosts.length,
                          itemBuilder: (context, index) {
                            var post = userPosts[index];
                            String cropName = post['cropName'] ?? 'No Crop Name';
                            String quantity = post['quantity'] ?? 'No Quantity';
                            String address = post['address'] ?? 'No Address';
                            String imageUrl = post['imageUrl'] ?? '';
                            String userEmail = post['userEmail'] ?? 'No Email';
                            Timestamp timestamp = post['timestamp'] ?? Timestamp.now();
                            String formattedTimestamp = DateFormat('yyyy-MM-dd – kk:mm').format(timestamp.toDate());

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
                                                      backgroundColor: Colors.transparent,
                                                      child: Stack(
                                                        children: [
                                                          Positioned.fill(
                                                            child: Image.network(imageUrl, fit: BoxFit.contain),
                                                          ),
                                                          Positioned(
                                                            top: 16,
                                                            right: 16,
                                                            child: IconButton(
                                                              icon: Icon(Icons.close, color: Colors.white),
                                                              onPressed: () {
                                                                Navigator.of(context).pop();
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
                                                child: Image.network(imageUrl, fit: BoxFit.cover),
                                              ),
                                            ),
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(cropName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                                SizedBox(height: 10),
                                                Text('Quantity: $quantity', style: TextStyle(fontSize: 18)),
                                                SizedBox(height: 10),
                                                Text('Address: $address', style: TextStyle(fontSize: 18)),
                                                SizedBox(height: 10),
                                                Text('Posted by: $userEmail', style: TextStyle(fontSize: 18)),
                                                SizedBox(height: 10),
                                                Text('Posted on: $formattedTimestamp', style: TextStyle(fontSize: 18)),
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
                                      ],
                                    );
                                  },
                                );
                              },
                              child: MyListTile(
                                title: '$cropName - $quantity',
                                subTitle: 'By $userEmail\nAt $address\nOn $formattedTimestamp',
                                imageUrl: imageUrl,
                              ),
                            );
                          },
                        );
                      },
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
