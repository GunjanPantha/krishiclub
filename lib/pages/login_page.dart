import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:krishiclub/components/my_button.dart';
import 'package:krishiclub/components/my_textfield.dart';
import 'package:krishiclub/helper/helper_function.dart';
import 'package:krishiclub/pages/home_page.dart';
import 'package:krishiclub/pages/forget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text editing controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  // Load saved credentials if "Remember Me" was checked
  void _loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      emailController.text = prefs.getString('email') ?? '';
      passwordController.text = prefs.getString('password') ?? '';
      rememberMe = prefs.getBool('rememberMe') ?? false;
    });
  }

  // Save credentials if "Remember Me" is checked
  void _saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('email', emailController.text);
      await prefs.setString('password', passwordController.text);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
    }
    await prefs.setBool('rememberMe', rememberMe);
  }

  // Login method
  void login() async {
    // Show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      // Save credentials if "Remember Me" is checked
      _saveCredentials();

      // Pop loading screen
      if (context.mounted) Navigator.pop(context);

      // Navigate to home
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Pop loading circle
      Navigator.pop(context);
      displayMessageToUser(e.code, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          height: screenHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                constraints: BoxConstraints(
                  maxHeight: screenHeight * 0.3, // 30% of screen height
                ),
                child: Image.asset(
                  'lib/assets/logo.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 25),

              // Email textfield
              MyTextfield(
                controller: emailController,
                hintText: "Email",
                obscureText: false,
              ),

              const SizedBox(height: 10),

              // Password textfield
              MyTextfield(
                controller: passwordController,
                hintText: "Password",
                obscureText: true,
                isPassword: true,
              ),

              const SizedBox(height: 10),

              // Remember Me checkbox
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    value: rememberMe,
                    onChanged: (bool? newValue) {
                      setState(() {
                        rememberMe = newValue ?? false;
                      });
                    },
                  ),
                  Text(
                    "Remember Me",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Forgot password link
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgetPasswordPage(),
                        ),
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Sign in button
              MyButton(
                text: "Login",
                onTap: login,
              ),

              const SizedBox(height: 25),

              // Not a member? Register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Not a member?",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      "Register now",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
