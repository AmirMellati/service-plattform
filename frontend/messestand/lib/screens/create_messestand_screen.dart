import 'package:flutter/material.dart';
import 'dart:convert';

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
  // Stores all available skills from the API.
  List<dynamic> skills = [];

  // Stores the selected skill IDs.
  List<int> selectedSkillIds = [];

  // Loads all available skills from the API.
  Future<void> getSkills() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/skills'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (!mounted) return;
      // Updates the state with the loaded skills.
      setState(() {
        skills = data;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getSkills();
  }

  // Stores the current skill search text.
  String skillSearch = '';

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

            // Displays all skills and allows multiple selections.
            ...skills
                .where((skill) {
                  final name = skill['name'].toString().toLowerCase();
                  return name.contains(skillSearch.toLowerCase());
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
              onPressed: () {
                // The API request will be added next.
              },
              child: const Text('Messestand erstellen'),
            ),
          ],
        ),
      ),
    );
  }
}
