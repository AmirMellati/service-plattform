import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class CreateMessestandScreen extends StatefulWidget {
  const CreateMessestandScreen({super.key});

  @override
  State<CreateMessestandScreen> createState() => _CreateMessestandScreenState();
}

class _CreateMessestandScreenState extends State<CreateMessestandScreen> {
  // Controllers for the messestand form.
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceFromController = TextEditingController();
  final priceToController = TextEditingController();

  // Secure storage for reading the authentication token.
  final storage = FlutterSecureStorage();

  // Controllers for the messestand address.
  final streetController = TextEditingController();
  final houseNumberController = TextEditingController();
  final postalCodeController = TextEditingController();
  final cityController = TextEditingController();

  // Stores all available skills from the API.
  List<dynamic> skills = [];

  // Stores the selected skill IDs.
  List<int> selectedSkillIds = [];

  // Stores the current skill search text.
  String skillSearch = '';

  // Loads the available skills when the screen opens.
  @override
  void initState() {
    super.initState();
    getSkills();
  }

  // Loads all available skills from the API.
  Future<void> getSkills() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/skills'),
    );
    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        skills = data;
      });
    }
  }

  // Sends the new messestand data to the API.
  Future<void> createMessestand() async {
    final token = await storage.read(key: 'auth_token');

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/messestaende'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },

      body: jsonEncode({
        'title': titleController.text,
        'description': descriptionController.text,
        'price_from': priceFromController.text,
        'price_to': priceToController.text,
        'skill_ids': selectedSkillIds,
        'street': streetController.text,
        'house_number': houseNumberController.text,
        'postal_code': postalCodeController.text,
        'city': cityController.text,
      }),
    );
    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 201) {
      if (!mounted) return;

      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    // Releases the form controllers when the screen is closed.
    titleController.dispose();
    descriptionController.dispose();
    priceFromController.dispose();
    priceToController.dispose();
    super.dispose();

    streetController.dispose();
    houseNumberController.dispose();
    postalCodeController.dispose();
    cityController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messestand erstellen')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Input field for the messestand title.
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Titel',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Input field for the messestand description.
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Beschreibung',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Input field for the minimum price.
            TextField(
              controller: priceFromController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Preis von (€)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Input field for the maximum price.
            TextField(
              controller: priceToController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Preis bis (€)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Adresse',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const Text(
              'Einsatzgebiet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // Street
            TextField(
              controller: streetController,
              decoration: const InputDecoration(
                labelText: 'Straße',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // House number
            TextField(
              controller: houseNumberController,
              decoration: const InputDecoration(
                labelText: 'Hausnummer',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Postal code
            TextField(
              controller: postalCodeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'PLZ',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // City
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: 'Stadt',
                border: OutlineInputBorder(),
              ),
            ),

            const Text(
              'Skills',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Search field for filtering the skill list.
            TextField(
              decoration: const InputDecoration(
                labelText: 'Skill suchen',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  skillSearch = value;
                });
              },
            ),

            const SizedBox(height: 12),

            // Shows skills only when the user enters a search term.
            if (skillSearch.trim().isNotEmpty)
              ...skills
                  .where((skill) {
                    final name = skill['name'].toString().toLowerCase();

                    return name.contains(skillSearch.toLowerCase().trim());
                  })
                  .map((skill) {
                    final skillId = skill['id'] as int;

                    return CheckboxListTile(
                      title: Text(skill['name']),
                      value: selectedSkillIds.contains(skillId),
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            selectedSkillIds.add(skillId);
                          } else {
                            selectedSkillIds.remove(skillId);
                          }
                        });
                      },
                    );
                  }),

            const SizedBox(height: 20),

            ElevatedButton(
              // Creates the messestand with the entered data.
              onPressed: createMessestand,
              child: const Text('Messestand erstellen'),
            ),
          ],
        ),
      ),
    );
  }
}
