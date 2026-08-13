import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Define a list to hold the messestaende from the API.
  List<dynamic> messestaende = [];

  @override
  void initState() {
    super.initState();
    getMessestaende();
  }

  // Fetches the messestaende from the Laravel API and updates the state.
  Future<void> getMessestaende() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/messestaende'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Check if the screen is still active before updating the state.
      if (!mounted) return;

      setState(() {
        messestaende = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messestand')),
      body: ListView.builder(
        itemCount: messestaende.length,
        itemBuilder: (context, index) {
          final messestand = messestaende[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    messestand['title'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(messestand['description'] ?? 'Keine Beschreibung'),
                  const SizedBox(height: 8),
                  Text(
                    'Preis: ${messestand['price_from'] ?? '-'} € - ${messestand['price_to'] ?? '-'} €',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
