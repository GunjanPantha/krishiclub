import 'package:flutter/material.dart';
import 'package:krishiclub/components/my_drawer_tile.dart';
import '../pages/settings_page.dart';
import '../auth/login_or_register.dart'; // Import your LoginOrRegister page

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform logout operation, like clearing user data
                // Then navigate to the login_or_register screen
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginOrRegister(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // App logo
          Padding(
            padding: const EdgeInsets.only(top: 50.0, bottom: 10.0),
            child: Image.asset(
              'lib/assets/logo.png',
              width: 100,
              height: 100,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Divider(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          // Home list tile
          MyDrawerTile(
            text: "H O M E",
            icon: Icons.home,
            onTap: () {
              //pop drawer
              Navigator.pop(context);
            },
          ),

          // Profile
          MyDrawerTile(
            text: "P R O F I L E",
            icon: Icons.person,
            onTap: () {
              //pop drawer
              Navigator.pop(context);
              //navigate to profile page
              Navigator.pushNamed(context, '/profile_page');
            },
          ),

          // Farmers
          MyDrawerTile(
            text: "F A R M E R S",
            icon: Icons.group,
            onTap: () {
              //pop drawer
              Navigator.pop(context);
              //navigate to farmers page
              Navigator.pushNamed(context, '/users_page');
            },
          ),

          // Settings
          MyDrawerTile(
            text: "S E T T I N G S",
            icon: Icons.settings,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
          const Spacer(),
          // Logout list tile
          MyDrawerTile(
            text: "L O G O U T",
            icon: Icons.logout,
            onTap: _showLogoutDialog,
          ),
        ],
      ),
    );
  }
}
