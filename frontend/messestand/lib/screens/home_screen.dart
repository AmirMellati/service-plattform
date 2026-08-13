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

          return ListTile(title: Text(messestand['titel']));
        },
      ),
    );
  }
}
