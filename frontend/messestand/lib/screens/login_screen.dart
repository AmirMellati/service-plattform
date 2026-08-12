import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for the login input fields.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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

  if (!mounted) return;

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anmeldung erfolgreich!'),
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