import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:krishiclub/components/my_list_tile.dart';
import 'package:krishiclub/database/firestore.dart';
import '../components/my_drawer.dart';
import '../pages/upload_page.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final FirestoreDatabase database = FirestoreDatabase();

  // Check if the user is a farmer
  Future<bool> isFarmer() async {
    String role = await database.getUserRole();
    return role == 'Farmer';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          // Crops
          Expanded(
            child: StreamBuilder(
              stream: database.getCropsStream(),
              builder: (context, snapshot) {
                // Show loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Get all crops
                final crops = snapshot.data?.docs ?? [];

                // No data
                if (crops.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Text("No Crops.."),
                    ),
                  );
                }

                // Return as a list
                return ListView.builder(
                  itemCount: crops.length,
                  itemBuilder: (context, index) {
                    // Get each individual crop
                    final crop = crops[index];

                    // Get data from each crop
                    String cropName = crop['cropName'] ?? 'No Crop Name';
                    String quantity = crop['quantity'] ?? 'No Quantity';
                    String address = crop['address'] ?? 'No Address';
                    String imageUrl = crop['imageUrl'] ?? '';
                    String userEmail = crop['userEmail'] ?? 'No Email';
                    Timestamp timestamp = crop['timestamp'] ?? Timestamp.now();
                    String formattedTimestamp = DateFormat('yyyy-MM-dd – kk:mm').format(timestamp.toDate());

                    // Return as a list tile
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
                                                    child: Image.network(
                                                      imageUrl,
                                                      fit: BoxFit.contain,
                                                    ),
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
                                        width: double.infinity, // Full width
                                        height: 200, // Fixed height
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover, // Fit image within container
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'Address: $address',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'Posted by: $userEmail',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'Posted on: $formattedTimestamp',
                                          style: TextStyle(fontSize: 18),
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
      ),
      floatingActionButton: FutureBuilder<bool>(
        future: isFarmer(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }
          if (snapshot.data == true) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadPage(
                      onTap: () {
                        // Define any action to take after uploading
                      },
                    ),
                  ),
                );
              },
              child: Icon(Icons.add),
            );
          }
          return Container(); // No FAB for non-farmers
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
