import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class CreateMessestandScreen extends StatefulWidget {
  const CreateMessestandScreen({super.key});

  @override
  State<CreateMessestandScreen> createState() =>
      _CreateMessestandScreenState();
}

class _CreateMessestandScreenState extends State<CreateMessestandScreen> {
  // API endpoint for messestaende.
  static const String messestaendeUrl =
      'http://127.0.0.1:8000/api/messestaende';

  // API endpoint for skills.
  static const String skillsUrl =
      'http://127.0.0.1:8000/api/skills';

  // Form controllers.
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceFromController = TextEditingController();
  final priceToController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();

  // Secure storage for the authentication token.
  final storage = const FlutterSecureStorage();

  // Available skills loaded from the backend.
  List<dynamic> skills = [];

  // IDs of the skills selected by the user.
  List<int> selectedSkillIds = [];

  // Current text entered in the skill search field.
  String skillSearch = '';

  // Prevents multiple submissions while a request is running.
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    // Loads all available skills when the screen opens.
    getSkills();
  }

  // Loads all skills from the Laravel API.
  Future<void> getSkills() async {
    try {
      final response = await http.get(
        Uri.parse(skillsUrl),
        headers: {
          'Accept': 'application/json',
        },
      );

      print('Skills status: ${response.statusCode}');
      print('Skills response: ${response.body}');

      if (response.statusCode != 200) {
        showMessage('Skills konnten nicht geladen werden.');
        return;
      }

      final data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        skills = data;
      });
    } catch (e) {
      showMessage('Keine Verbindung zum Server.');
    }
  }

  // Creates a new messestand through the Laravel API.
  Future<void> createMessestand() async {
    // Prevents sending the same request multiple times.
    if (isSaving) return;

    // Simple frontend checks before sending data to Laravel.
    if (titleController.text.trim().isEmpty) {
      showMessage('Bitte einen Titel eingeben.');
      return;
    }

    if (cityController.text.trim().isEmpty) {
      showMessage('Bitte eine Stadt eingeben.');
      return;
    }

    if (districtController.text.trim().isEmpty) {
      showMessage('Bitte ein Anfahrtsgebiet eingeben.');
      return;
    }

    if (selectedSkillIds.isEmpty) {
      showMessage('Bitte mindestens einen Skill auswählen.');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // Reads the Sanctum authentication token.
      final token = await storage.read(key: 'auth_token');

      if (token == null) {
        showMessage('Du bist nicht angemeldet.');
        return;
      }

      // Sends the messestand data to Laravel.
      final response = await http.post(
        Uri.parse(messestaendeUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': titleController.text.trim(),
          'description': descriptionController.text.trim(),
          'price_from': priceFromController.text.trim(),
          'price_to': priceToController.text.trim(),

          // Selected skills are sent as IDs.
          'skill_ids': selectedSkillIds,

          // Service area of the handwerker.
          // This is not the private address of the user.
          'city': cityController.text.trim(),
          'district': districtController.text.trim(),
        }),
      );

      print('Create status: ${response.statusCode}');
      print('Create response: ${response.body}');

      // Messestand was successfully created.
      if (response.statusCode == 201) {
        if (!mounted) return;

        Navigator.pop(context, true);
        return;
      }

      // Laravel validation or invalid service area.
      if (response.statusCode == 422) {
        final data = jsonDecode(response.body);

        showMessage(
          data['message'] ?? 'Die Eingaben sind ungültig.',
        );

        return;
      }

      // Authentication error.
      if (response.statusCode == 401) {
        showMessage('Deine Anmeldung ist nicht mehr gültig.');
        return;
      }

      // Unexpected backend error.
      showMessage(
        'Serverfehler (${response.statusCode}). Bitte erneut versuchen.',
      );
    } catch (e) {
      // Handles network errors or invalid server responses.
      showMessage('Keine Verbindung zum Server.');
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // Shows a message inside the application.
  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  void dispose() {
    // Releases all TextEditingControllers.
    titleController.dispose();
    descriptionController.dispose();
    priceFromController.dispose();
    priceToController.dispose();
    cityController.dispose();
    districtController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filters the skill list using the current search text.
    final filteredSkills = skillSearch.trim().isEmpty
        ? <dynamic>[]
        : skills.where((skill) {
            final skillName =
                skill['name'].toString().toLowerCase();

            return skillName.contains(
              skillSearch.trim().toLowerCase(),
            );
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messestand erstellen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Messestand title.
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Titel',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Messestand description.
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Beschreibung',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Minimum price.
            TextField(
              controller: priceFromController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Preis von (€)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Maximum price.
            TextField(
              controller: priceToController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Preis bis (€)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Einsatzgebiet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // City in which the service is offered.
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: 'Stadt',
                hintText: 'z. B. Hamburg',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // District or local service area.
            TextField(
              controller: districtController,
              decoration: const InputDecoration(
                labelText: 'Anfahrtsgebiet / Stadtteil',
                hintText: 'z. B. Altona',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Skills',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Searches through the available skills.
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

            // Shows the skills matching the search text.
            ...filteredSkills.map((skill) {
              final skillId = skill['id'] as int;

              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(skill['name'].toString()),
                value: selectedSkillIds.contains(skillId),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      if (!selectedSkillIds.contains(skillId)) {
                        selectedSkillIds.add(skillId);
                      }
                    } else {
                      selectedSkillIds.remove(skillId);
                    }
                  });
                },
              );
            }),

            const SizedBox(height: 24),

            // Creates the messestand.
            ElevatedButton(
              onPressed: isSaving ? null : createMessestand,
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Messestand erstellen'),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}