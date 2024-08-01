import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:krishiclub/auth/login_or_register.dart';
import 'package:krishiclub/firebase_options.dart';
import 'package:krishiclub/pages/profile_page.dart';
import 'package:krishiclub/pages/users_page.dart';
import 'package:krishiclub/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginOrRegister(),
      theme: Provider.of<ThemeProvider>(context).themeData,
      routes: {
        '/login_register_page':(context) => const LoginOrRegister(),
        '/home_page':(context) =>  HomePage(),
        '/profile_page':(context) => ProfilePage(),
        '/users_page':(context) => const UsersPage(),
      },
    ); //MaterialApp
  }
}