import 'package:flutter/material.dart';
//dart convert to json
import 'dart:convert';
//http conection for flutter and laravel
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

// Function to register user
// Sends the registration data to the Laravel 
//API and receives the server response.
  Future<void> registerUser() async {
  final response = await http.post(
    Uri.parse('http://127.0.0.1:8000/api/register'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'name': nameController.text,
      'email': emailController.text,
      'password': passwordController.text,
    }),
  );

  print(response.statusCode);
  print(response.body);
}

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrieren'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 16),
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
              onPressed: () {
                print(nameController.text);
                print(emailController.text);
                print(passwordController.text);
              },
              child: const Text('Registrieren'),
            ),
          ],
        ),
      ),
    );
  }
}