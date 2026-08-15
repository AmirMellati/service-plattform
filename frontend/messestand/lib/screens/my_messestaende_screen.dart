import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'create_messestand_screen.dart';

class MyMessestaendeScreen extends StatefulWidget {
  const MyMessestaendeScreen({super.key});

  @override
  State<MyMessestaendeScreen> createState() => _MyMessestaendeScreenState();
}

class _MyMessestaendeScreenState extends State<MyMessestaendeScreen> {
  // Secure storage for reading the authentication token.
  final storage = FlutterSecureStorage();

  // Stores the authenticated user's messestaende.
  List<dynamic> messestaende = [];

  // Loads the user's messestaende when the screen opens.
  @override
  void initState() {
    super.initState();
    getMyMessestaende();
  }

  // Loads the messestaende of the authenticated user from the API.
  Future<void> getMyMessestaende() async {
    final token = await storage.read(key: 'auth_token');

    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/me/messestaende'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        messestaende = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meine Messestände')),

      // Button for creating a new messestand.
      floatingActionButton: FloatingActionButton(
        // Opens the screen for creating a new messestand.
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateMessestandScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      // Displays the user's messestaende or a message if there are none.
      body: messestaende.isEmpty
          ? const Center(child: Text('Noch keine Messestände'))
          : ListView.builder(
              itemCount: messestaende.length,
              itemBuilder: (context, index) {
                final messestand = messestaende[index];

                return ListTile(
                  leading: const Icon(Icons.store),
                  title: Text(messestand['title']),
                  subtitle: Text(
                    messestand['description'] ?? 'Keine Beschreibung',
                  ),
                );
              },
            ),
    );
  }
}
