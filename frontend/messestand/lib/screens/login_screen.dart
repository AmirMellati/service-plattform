import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for the login input fields.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Secure storage for the authentication token.
  final storage = FlutterSecureStorage();

  // Sends the login data to the Laravel API.
  Future<void> loginUser() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    // Check if the screen is still active before using context.
    if (!mounted) return;

    if (response.statusCode == 200) {
      // Decode the JSON response and read the authentication token.
      final data = jsonDecode(response.body);
      final token = data['token'];

      // Store the authentication token securely.
      await storage.write(
        key: 'auth_token',
        value: token,
      );

      // Check again because storage.write uses await.
      if (!mounted) return;

      // Replace the login screen with the home screen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else if (response.statusCode == 401) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-Mail oder Passwort ist falsch.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ein Fehler ist aufgetreten.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Release controllers when the screen is closed.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anmelden'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-Mail',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Passwort',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              // Calls the login API when the button is pressed.
              onPressed: loginUser,
              child: const Text('Anmelden'),
            ),
          ],
        ),
      ),
    );
  }
}