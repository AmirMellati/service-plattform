import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CreateMessestandScreen extends StatefulWidget {
  const CreateMessestandScreen({super.key});

  @override
  State<CreateMessestandScreen> createState() =>
      _CreateMessestandScreenState();
}

class _CreateMessestandScreenState extends State<CreateMessestandScreen> {
  static const String messestaendeUrl =
      'http://127.0.0.1:8000/api/messestaende';

  static const String skillsUrl =
      'http://127.0.0.1:8000/api/skills';

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceFromController = TextEditingController();
  final priceToController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();

  final storage = const FlutterSecureStorage();
  final ImagePicker imagePicker = ImagePicker();

  List<dynamic> skills = [];
  List<int> selectedSkillIds = [];

  Uint8List? selectedImageBytes;
  String? selectedImageName;

  String skillSearch = '';
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    getSkills();
  }

  Future<void> getSkills() async {
    try {
      final response = await http.get(
        Uri.parse(skillsUrl),
        headers: {
          'Accept': 'application/json',
        },
      );

      debugPrint('Skills status: ${response.statusCode}');
      debugPrint('Skills response: ${response.body}');

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
      debugPrint('Get skills error: $e');
      showMessage('Keine Verbindung zum Server.');
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        selectedImageBytes = bytes;
        selectedImageName = image.name;
      });
    } catch (e) {
      debugPrint('Pick image error: $e');
      showMessage('Das Bild konnte nicht ausgewählt werden.');
    }
  }

  void removeSelectedImage() {
    setState(() {
      selectedImageBytes = null;
      selectedImageName = null;
    });
  }

  double? parseOptionalPrice(String text) {
    final normalized = text.trim().replaceAll(',', '.');

    if (normalized.isEmpty) {
      return null;
    }

    return double.tryParse(normalized);
  }

  String getValidationMessage(Map<String, dynamic> data) {
    final errors = data['errors'];

    if (errors is Map) {
      for (final error in errors.values) {
        if (error is List && error.isNotEmpty) {
          return error.first.toString();
        }

        if (error != null) {
          return error.toString();
        }
      }
    }

    return data['message']?.toString() ??
        'Die Eingaben sind ungültig.';
  }

  Future<void> uploadMessestandImage({
    required int messestandId,
    required String token,
  }) async {
    if (selectedImageBytes == null) return;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$messestaendeUrl/$messestandId/bilder'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.files.add(
      http.MultipartFile.fromBytes(
        'bild',
        selectedImageBytes!,
        filename: selectedImageName ?? 'messestand.jpg',
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint('Image upload status: ${response.statusCode}');
    debugPrint('Image upload response: ${response.body}');

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        'Bild-Upload fehlgeschlagen: ${response.statusCode}',
      );
    }
  }

  Future<void> createMessestand() async {
    if (isSaving) return;

    if (titleController.text.trim().isEmpty) {
      showMessage('Bitte einen Titel eingeben.');
      return;
    }

    final priceFromText = priceFromController.text.trim();
    final priceToText = priceToController.text.trim();

    final priceFrom = parseOptionalPrice(priceFromText);
    final priceTo = parseOptionalPrice(priceToText);

    if (priceFromText.isNotEmpty && priceFrom == null) {
      showMessage('Bitte einen gültigen Von-Preis eingeben.');
      return;
    }

    if (priceToText.isNotEmpty && priceTo == null) {
      showMessage('Bitte einen gültigen Bis-Preis eingeben.');
      return;
    }

    if (priceFrom != null && priceFrom < 0) {
      showMessage('Der Von-Preis darf nicht negativ sein.');
      return;
    }

    if (priceTo != null && priceTo < 0) {
      showMessage('Der Bis-Preis darf nicht negativ sein.');
      return;
    }

    if (priceFrom != null &&
        priceTo != null &&
        priceFrom > priceTo) {
      showMessage(
        'Der Bis-Preis muss größer oder gleich dem Von-Preis sein.',
      );
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
      final token = await storage.read(key: 'auth_token');

      if (token == null || token.isEmpty) {
        showMessage('Du bist nicht angemeldet.');
        return;
      }

      final response = await http.post(
        Uri.parse(messestaendeUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': titleController.text.trim(),
          'description':
              descriptionController.text.trim().isEmpty
                  ? null
                  : descriptionController.text.trim(),
          'price_from': priceFrom,
          'price_to': priceTo,
          'skill_ids': selectedSkillIds,
          'city': cityController.text.trim(),
          'district': districtController.text.trim(),
        }),
      );

      debugPrint('Create status: ${response.statusCode}');
      debugPrint('Create response: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        final int? messestandId =
            int.tryParse(data['id'].toString());

        if (messestandId == null) {
          showMessage(
            'Messestand wurde erstellt, aber die ID fehlt.',
          );
          return;
        }

        if (selectedImageBytes != null) {
          try {
            await uploadMessestandImage(
              messestandId: messestandId,
              token: token,
            );
          } catch (e) {
            debugPrint('Upload image error: $e');

            if (!mounted) return;

            await showDialog<void>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Bild-Upload fehlgeschlagen'),
                  content: const Text(
                    'Der Messestand wurde erstellt, '
                    'aber das Bild konnte nicht hochgeladen werden.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );

            if (!mounted) return;

            Navigator.pop(context, true);
            return;
          }
        }

        if (!mounted) return;

        Navigator.pop(context, true);
        return;
      }

      if (response.statusCode == 422) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          showMessage(getValidationMessage(data));
        } else {
          showMessage('Die Eingaben sind ungültig.');
        }

        return;
      }

      if (response.statusCode == 401) {
        showMessage('Deine Anmeldung ist nicht mehr gültig.');
        return;
      }

      if (response.statusCode == 403) {
        showMessage('Du hast keine Berechtigung für diese Aktion.');
        return;
      }

      showMessage(
        'Serverfehler (${response.statusCode}). '
        'Bitte erneut versuchen.',
      );
    } catch (e) {
      debugPrint('Create messestand error: $e');
      showMessage('Keine Verbindung zum Server.');
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
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
    final filteredSkills = skillSearch.trim().isEmpty
        ? <dynamic>[]
        : skills.where((skill) {
            final name =
                skill['name'].toString().toLowerCase();

            return name.contains(
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
            TextField(
              controller: titleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Titel',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Beschreibung',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: priceFromController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Preis von (€)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: priceToController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Preis bis (€)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Bild',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              height: 190,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade400,
                ),
              ),
              child: selectedImageBytes != null
                  ? Image.memory(
                      selectedImageBytes!,
                      fit: BoxFit.cover,
                    )
                  : const Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 56,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text('Noch kein Bild ausgewählt'),
                      ],
                    ),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: isSaving ? null : pickImage,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(
                selectedImageBytes == null
                    ? 'Bild auswählen'
                    : 'Anderes Bild auswählen',
              ),
            ),

            if (selectedImageBytes != null)
              TextButton.icon(
                onPressed:
                    isSaving ? null : removeSelectedImage,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Bild entfernen'),
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

            TextField(
              controller: cityController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Stadt',
                hintText: 'z. B. Hamburg',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

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

            ...filteredSkills.map((skill) {
              final int skillId =
                  int.parse(skill['id'].toString());

              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(skill['name'].toString()),
                value: selectedSkillIds.contains(skillId),
                onChanged: isSaving
                    ? null
                    : (selected) {
                        setState(() {
                          if (selected == true) {
                            if (!selectedSkillIds
                                .contains(skillId)) {
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

            ElevatedButton(
              onPressed:
                  isSaving ? null : createMessestand,
              child: isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
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