import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'meins_screen.dart';

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

  // Fetches messestaende from the API, optionally filtered by skill.
  Future<void> getMessestaende({String skill = ''}) async {
    final uri = Uri.parse(
      'http://127.0.0.1:8000/api/messestaende',
    ).replace(queryParameters: skill.isNotEmpty ? {'skill': skill} : null);

    final response = await http.get(uri);

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
      // Displays the title of the home screen.
      appBar: AppBar(title: const Text('Messestand')),

      body: Column(
        children: [
          // Search field for filtering messestaende by skill.
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Nach Skill suchen',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),

              // Sends the entered skill to the API.
              onChanged: (value) {
                getMessestaende(skill: value);
              },
            ),
          ),

          // Uses the remaining screen space for the messestand list.
          Expanded(
            child: ListView.builder(
              // Defines how many messestand cards are displayed.
              itemCount: messestaende.length,

              // Builds one card for each messestand.
              itemBuilder: (context, index) {
                final messestand = messestaende[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Displays the messestand title.
                        Text(
                          messestand['title'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // Displays all skills of the messestand.
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children:
                              ((messestand['skills'] ?? []) as List<dynamic>)
                                  .map<Widget>((skill) {
                                    return Chip(label: Text(skill['name']));
                                  })
                                  .toList(),
                        ),

                        const SizedBox(height: 8),

                        // Displays the name of the handwerker.
                        Text(
                          'Handwerker: ${messestand['user']['name']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        // Displays a star if the messestand is featured.
                        if (messestand['featured'] == 1)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Icon(Icons.star, size: 24),
                          ),

                        const SizedBox(height: 8),

                        // Displays the messestand description.
                        Text(messestand['description'] ?? 'Keine Beschreibung'),

                        const SizedBox(height: 8),

                        const SizedBox(height: 6),

                        // Displays the service area of the handwerker.
                        if (messestand['einsatzgebiet'] != null)
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${messestand['einsatzgebiet']['city']} - '
                                '${messestand['einsatzgebiet']['district']}',
                              ),
                            ],
                          ),

                        // Displays the price range.
                        Text(
                          'Preis: ${messestand['price_from'] ?? '-'} € - ${messestand['price_to'] ?? '-'} €',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 18,
        selectedFontSize: 8,
        unselectedFontSize: 11,
        // Navigates to the MeinsScreen when the third item is tapped.
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MeinsScreen()),
            );
          }
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Nachrichten',
          ),

          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'meins'),

          //home item
        ],
      ),
    );
  }
}
