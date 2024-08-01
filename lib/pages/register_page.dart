import 'package:flutter/material.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../helper/helper_function.dart';
import '../pages/select_role.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({
    super.key,
    required this.onTap,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text editing controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();

  // Method to check if the email is valid
  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  // Method to check the inputs
  void check() {
    // Show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Ensure passwords match
    if (passwordController.text != confirmpasswordController.text) {
      // Pop loading circle
      Navigator.pop(context);
      // Show error
      displayMessageToUser("Passwords don't match", context);
      return;
    }

    // Ensure password is at least 6 characters
    if (passwordController.text.length < 6) {
      // Pop loading circle
      Navigator.pop(context);
      // Show error
      displayMessageToUser("Password must be at least 6 characters", context);
      return;
    }

    // Ensure email is valid
    if (!isValidEmail(emailController.text)) {
      // Pop loading circle
      Navigator.pop(context);
      // Show error
      displayMessageToUser("Invalid email address", context);
      return;
    }

    // If inputs are valid, navigate to SelectRole page
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectRole(
          onTap: widget.onTap,
          username: usernameController.text,
          email: emailController.text,
          password: passwordController.text,
        ),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    body: Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Padding(
              padding: const EdgeInsets.only(top: 50.0, bottom: 10.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.5, // Adjust the width to be 50% of the screen width
                      maxHeight: constraints.maxHeight * 0.5, // Adjust the height to be 50% of the screen height
                    ),
                    child: Image.asset(
                      'lib/assets/logo.png',
                      fit: BoxFit.contain, // Ensures the logo fits within the constraints
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 25),
            // Message, app slogan
            Text(
              "Sign Up",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            const SizedBox(height: 25),
            // Username textfield
            MyTextfield(
              controller: usernameController,
              hintText: "Username",
              obscureText: false,
            ),
            const SizedBox(height: 10),
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
            // Confirm password textfield
            MyTextfield(
              controller: confirmpasswordController,
              hintText: "Confirm Password",
              obscureText: true,
              isPassword: true,
            ),
            const SizedBox(height: 25),
            // Sign up button
            MyButton(
              text: "Next",
              onTap: check,
            ),
            const SizedBox(height: 25),
            // Already have an account? Login here
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already Have an Account?",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text(
                    "Login now",
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
