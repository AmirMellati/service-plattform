import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Willkommen bei Messestand',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Finden Sie passende Handwerker\n'
              'für Ihre Aufträge.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () {},
              child: const Text('Anmelden'),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () {},
              child: const Text('Registrieren'),
            ),
          ],
        ),
      ),
    );
  }
}