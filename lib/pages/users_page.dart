import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:krishiclub/components/my_back_button.dart';
import 'package:krishiclub/components/my_list_tile.dart';
import 'package:krishiclub/helper/helper_function.dart';
import 'package:krishiclub/pages/users_detail_page.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .where("role", isEqualTo: "Farmer")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            displayMessageToUser("Something went wrong", context);
            return const Text("Error occurred");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Farmers Found"));
          }

          final farmers = snapshot.data!.docs;

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 50.0, left: 25),
                child: Row(children: [MyBackButton()]),
              ),
              const SizedBox(height: 25),
              Expanded(
                child: ListView.builder(
                  itemCount: farmers.length,
                  itemBuilder: (context, index) {
                    final farmer = farmers[index];
                    String userId = farmer.id;
                    String username = farmer['username'];
                    String email = farmer['email'];

                    return MyListTile(
                      title: username,
                      subTitle: email,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetailPage(
                              userId: userId,
                              email: email,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
