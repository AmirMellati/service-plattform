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
  // Stores all messestaende returned by the API.
  List<dynamic> messestaende = [];

  // Stores the current search text for skills.
  String skillSearch = '';

  // Stores the current search text for the service area.
  String districtSearch = '';

  @override
  void initState() {
    super.initState();

    // Loads all messestaende when the screen opens.
    getMessestaende();
  }

  // Loads messestaende from the Laravel API.
  // The request can optionally be filtered by skill and district.
  Future<void> getMessestaende({
    String skill = '',
    String district = '',
  }) async {
    // Stores only the filters that actually contain a value.
    final queryParameters = <String, String>{};

    // Adds the skill filter to the URL when a skill was entered.
    if (skill.trim().isNotEmpty) {
      queryParameters['skill'] = skill.trim();
    }

    // Adds the district filter to the URL when a service area was entered.
    if (district.trim().isNotEmpty) {
      queryParameters['district'] = district.trim();
    }

    // Creates the final API URL with optional query parameters.
    final uri = Uri.parse(
      'http://127.0.0.1:8000/api/messestaende',
    ).replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    // Sends the GET request to Laravel.
    final response = await http.get(uri);

    // Continues only when the API request was successful.
    if (response.statusCode == 200) {
      // Converts the JSON response into a Dart object.
      final data = jsonDecode(response.body);

      // Prevents updating the state if the screen is no longer active.
      if (!mounted) return;

      // Updates the visible messestand list.
      setState(() {
        messestaende = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Displays the title of the home screen.
      appBar: AppBar(
        title: const Text('Messestand'),
      ),

      body: Column(
        children: [
          // Contains both search fields.
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search field for filtering messestaende by skill.
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Nach Skill suchen',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),

                  // Stores the entered skill and reloads the messestaende.
                  onChanged: (value) {
                    skillSearch = value;

                    getMessestaende(
                      skill: skillSearch,
                      district: districtSearch,
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Search field for filtering messestaende by service area.
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Nach Einsatzgebiet suchen',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(),
                  ),

                  // Stores the entered district and reloads the messestaende.
                  onChanged: (value) {
                    districtSearch = value;

                    getMessestaende(
                      skill: skillSearch,
                      district: districtSearch,
                    );
                  },
                ),
              ],
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

                        const SizedBox(height: 8),

                        // Displays all skills of the messestand.
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children:
                              ((messestand['skills'] ?? []) as List<dynamic>)
                                  .map<Widget>((skill) {
                                    return Chip(
                                      label: Text(skill['name']),
                                    );
                                  })
                                  .toList(),
                        ),

                        const SizedBox(height: 8),

                        // Displays the name of the handwerker.
                        Text(
                          'Handwerker: ${messestand['user']['name']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Displays the service area of the handwerker.
                        if (messestand['einsatzgebiet'] != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${messestand['einsatzgebiet']['city']} - '
                                '${messestand['einsatzgebiet']['district']}',
                              ),
                            ],
                          ),

                        // Displays a star if the messestand is featured.
                        if (messestand['featured'] == 1)
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Icon(
                              Icons.star,
                              size: 24,
                            ),
                          ),

                        const SizedBox(height: 8),

                        // Displays the messestand description.
                        Text(
                          messestand['description'] ??
                              'Keine Beschreibung',
                        ),

                        const SizedBox(height: 8),

                        // Displays the price range.
                        Text(
                          'Preis: '
                          '${messestand['price_from'] ?? '-'} € - '
                          '${messestand['price_to'] ?? '-'} €',
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

      // Displays the main navigation of the application.
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 18,
        selectedFontSize: 8,
        unselectedFontSize: 11,

        // Navigates to the selected section.
        onTap: (index) {
          // Opens the personal user area.
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MeinsScreen(),
              ),
            );
          }
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Nachrichten',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Meins',
          ),
        ],
      ),
    );
  }
}