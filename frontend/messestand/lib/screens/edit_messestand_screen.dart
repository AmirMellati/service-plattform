import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class EditMessestandScreen extends StatefulWidget {
  final Map<String, dynamic> messestand;

  const EditMessestandScreen({
    super.key,
    required this.messestand,
  });

  @override
  State<EditMessestandScreen> createState() =>
      _EditMessestandScreenState();
}

class _EditMessestandScreenState extends State<EditMessestandScreen> {
  // Secure storage for reading the authentication token.
  final storage = const FlutterSecureStorage();

  // Controllers for the editable messestand fields.
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController priceFromController;
  late TextEditingController priceToController;
  late TextEditingController cityController;
  late TextEditingController districtController;

  // Stores all skills loaded from the API.
  List<dynamic> skills = [];

  // Stores the IDs of the currently selected skills.
  List<int> selectedSkillIds = [];

  // Stores the current skill search text.
  String skillSearch = '';

  // Prevents multiple update requests at the same time.
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    // Fills the edit form with the current messestand data.
    titleController = TextEditingController(
      text: widget.messestand['title'] ?? '',
    );

    descriptionController = TextEditingController(
      text: widget.messestand['description'] ?? '',
    );

    priceFromController = TextEditingController(
      text: widget.messestand['price_from']?.toString() ?? '',
    );

    priceToController = TextEditingController(
      text: widget.messestand['price_to']?.toString() ?? '',
    );

    cityController = TextEditingController(
      text: widget.messestand['einsatzgebiet']?['city'] ?? '',
    );

    districtController = TextEditingController(
      text: widget.messestand['einsatzgebiet']?['district'] ?? '',
    );

    // Reads the currently selected skill IDs from the messestand.
    selectedSkillIds =
        ((widget.messestand['skills'] ?? []) as List<dynamic>)
            .map<int>((skill) => skill['id'] as int)
            .toList();

    // Loads all available skills from the backend.
    getSkills();
  }

  // Loads all available skills from the Laravel API.
  Future<void> getSkills() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://127.0.0.1:8000/api/skills',
        ),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          skills = data;
        });

        return;
      }

      showMessage(
        'Skills konnten nicht geladen werden.',
      );
    } catch (e) {
      showMessage(
        'Keine Verbindung zum Server.',
      );
    }
  }

  // Sends the updated messestand data to the Laravel API.
  Future<void> updateMessestand() async {
    // Prevents multiple requests.
    if (isSaving) return;

    // Checks the title.
    if (titleController.text.trim().isEmpty) {
      showMessage(
        'Bitte einen Titel eingeben.',
      );
      return;
    }

    // Checks the city.
    if (cityController.text.trim().isEmpty) {
      showMessage(
        'Bitte eine Stadt eingeben.',
      );
      return;
    }

    // Checks the service area.
    if (districtController.text.trim().isEmpty) {
      showMessage(
        'Bitte ein Anfahrtsgebiet eingeben.',
      );
      return;
    }

    // At least one skill must remain selected.
    if (selectedSkillIds.isEmpty) {
      showMessage(
        'Bitte mindestens einen Skill auswählen.',
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // Reads the Sanctum token of the logged-in user.
      final token = await storage.read(
        key: 'auth_token',
      );

      if (token == null) {
        showMessage(
          'Du bist nicht angemeldet.',
        );
        return;
      }

      final messestandId =
          widget.messestand['id'];

      // Sends the updated data to Laravel.
      final response = await http.put(
        Uri.parse(
          'http://127.0.0.1:8000/api/messestaende/$messestandId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title':
              titleController.text.trim(),

          'description':
              descriptionController.text.trim(),

          'price_from':
              priceFromController.text.trim(),

          'price_to':
              priceToController.text.trim(),

          'city':
              cityController.text.trim(),

          'district':
              districtController.text.trim(),

          'skill_ids':
              selectedSkillIds,
        }),
      );

      print(
        'Update status: ${response.statusCode}',
      );

      print(
        'Update response: ${response.body}',
      );

      // Successful update.
      if (response.statusCode == 200) {
        if (!mounted) return;

        Navigator.pop(
          context,
          true,
        );

        return;
      }

      // Laravel validation error.
      if (response.statusCode == 422) {
        final data =
            jsonDecode(response.body);

        showMessage(
          data['message'] ??
              'Die Eingaben sind ungültig.',
        );

        return;
      }

      // Authorization error.
      if (response.statusCode == 403) {
        final data =
            jsonDecode(response.body);

        showMessage(
          data['message'] ??
              'Du darfst diesen Messestand nicht bearbeiten.',
        );

        return;
      }

      // Authentication error.
      if (response.statusCode == 401) {
        showMessage(
          'Deine Anmeldung ist nicht mehr gültig.',
        );

        return;
      }

      // Unexpected backend error.
      showMessage(
        'Serverfehler (${response.statusCode}).',
      );
    } catch (e) {
      // Network error.
      showMessage(
        'Keine Verbindung zum Server.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // Shows messages inside the app.
  void showMessage(
    String message,
  ) {
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
    // Releases all controllers when the screen is closed.
    titleController.dispose();
    descriptionController.dispose();
    priceFromController.dispose();
    priceToController.dispose();
    cityController.dispose();
    districtController.dispose();

    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    // Filters the skills based on the search input.
    final filteredSkills =
        skillSearch.trim().isEmpty
            ? <dynamic>[]
            : skills.where((skill) {
                final skillName =
                    skill['name']
                        .toString()
                        .toLowerCase();

                final searchText =
                    skillSearch
                        .trim()
                        .toLowerCase();

                return skillName.contains(
                  searchText,
                );
              }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messestand bearbeiten',
        ),
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
              controller:
                  descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Beschreibung',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Minimum price.
            TextField(
              controller:
                  priceFromController,
              keyboardType:
                  TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Preis von (€)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Maximum price.
            TextField(
              controller:
                  priceToController,
              keyboardType:
                  TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Preis bis (€)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // Service area section.
            const Text(
              'Einsatzgebiet',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // City.
            TextField(
              controller:
                  cityController,
              decoration: const InputDecoration(
                labelText: 'Stadt',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // District or service area.
            TextField(
              controller:
                  districtController,
              decoration: const InputDecoration(
                labelText:
                    'Anfahrtsgebiet / Stadtteil',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // Skills section.
            const Text(
              'Skills',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Shows currently selected skills.
            // Each skill can be removed directly.
            if (selectedSkillIds.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: skills
                    .where(
                      (skill) =>
                          selectedSkillIds
                              .contains(
                                skill['id'],
                              ),
                    )
                    .map<Widget>(
                      (skill) {
                        final skillId =
                            skill['id'] as int;

                        return Chip(
                          label: Text(
                            skill['name']
                                .toString(),
                          ),

                          // Removes this selected skill.
                          onDeleted: () {
                            setState(() {
                              selectedSkillIds
                                  .remove(
                                    skillId,
                                  );
                            });
                          },
                        );
                      },
                    )
                    .toList(),
              ),

            const SizedBox(height: 12),

            // Skill search field.
            TextField(
              decoration: const InputDecoration(
                labelText:
                    'Skill suchen',
                prefixIcon:
                    Icon(Icons.search),
                border:
                    OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  skillSearch = value;
                });
              },
            ),

            const SizedBox(height: 12),

            // Shows matching skills after searching.
            if (skillSearch.trim().isNotEmpty)
              ...filteredSkills.map(
                (skill) {
                  final skillId =
                      skill['id'] as int;

                  return CheckboxListTile(
                    contentPadding:
                        EdgeInsets.zero,

                    title: Text(
                      skill['name']
                          .toString(),
                    ),

                    value:
                        selectedSkillIds
                            .contains(
                              skillId,
                            ),

                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          if (!selectedSkillIds
                              .contains(
                                skillId,
                              )) {
                            selectedSkillIds
                                .add(
                                  skillId,
                                );
                          }
                        } else {
                          selectedSkillIds
                              .remove(
                                skillId,
                              );
                        }
                      });
                    },
                  );
                },
              ),

            const SizedBox(height: 24),

            // Saves the updated messestand.
            ElevatedButton(
              onPressed:
                  isSaving
                      ? null
                      : updateMessestand,

              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Änderungen speichern',
                    ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}