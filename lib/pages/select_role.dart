import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../pages/login_page.dart';

class SelectRole extends StatefulWidget {
  final void Function()? onTap;
  final String username;
  final String email;
  final String password;

  const SelectRole({
    super.key,
    required this.onTap,
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  State<SelectRole> createState() => _SelectRoleState();
}

class _SelectRoleState extends State<SelectRole> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to register user
  Future<void> registerUser(String role) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );

      User? user = userCredential.user;

      // If user is created, set the username and role
      if (user != null) {
        await user.updateDisplayName(widget.username);
        await user.reload();
        user = _auth.currentUser;

        // Store user data in Firestore using email as the identifier
        await _firestore.collection('users').doc(widget.email).set({
          'username': widget.username,
          'email': widget.email,
          'role': role,
          'profileImageUrl': 'https://firebasestorage.googleapis.com/v0/b/krishi-club-4315b.appspot.com/o/profile_images%2Fgunjan.pantha%40gmail.com?alt=media&token=f4751482-0124-4580-b517-ab7cac55b55a',
        });

        print('User registered as $role');

        // Close loading dialog
        Navigator.of(context).pop();

        // Show success message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Created Account Successfully'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navigate to login page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(
                          onTap: widget.onTap, // Pass the onTap argument
                        ),
                      ),
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      print('Failed with error code: ${e.code}');
      print(e.message);

      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(e.message ?? 'An unknown error occurred.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Message, app slogan
              Text(
                "Please Choose Your Role:",
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              const SizedBox(height: 25),

              // Farmer Button
              ElevatedButton(
                onPressed: () async {
                  await registerUser('Farmer');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'lib/assets/farmer.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Farmer',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Buyer Button
              ElevatedButton(
                onPressed: () async {
                  await registerUser('Buyer');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'lib/assets/buyer.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Buyer',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
