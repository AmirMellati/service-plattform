import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'create_messestand_screen.dart';
import 'edit_messestand_screen.dart';

class MyMessestaendeScreen extends StatefulWidget {
  const MyMessestaendeScreen({super.key});

  @override
  State<MyMessestaendeScreen> createState() => _MyMessestaendeScreenState();
}

class _MyMessestaendeScreenState extends State<MyMessestaendeScreen> {
  // Secure storage for reading the authentication token.
  final storage = const FlutterSecureStorage();

  // Stores the authenticated user's messestaende.
  List<dynamic> messestaende = [];

  // Tracks whether a messestand was created, edited,
  // deleted or marked as featured.
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();

    // Loads the user's messestaende when the screen opens.
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

      return;
    }

    if (!mounted) return;

    showMessage('Messestände konnten nicht geladen werden.');
  }

  // Opens the create screen.
  Future<void> openCreateMessestand() async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateMessestandScreen()),
    );

    // Reloads the list when a new messestand was created.
    if (created == true) {
      hasChanges = true;

      await getMyMessestaende();
    }
  }

  // Opens the edit screen for one messestand.
  Future<void> openEditMessestand(dynamic messestand) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMessestandScreen(
          messestand: Map<String, dynamic>.from(messestand),
        ),
      ),
    );

    // Reloads the list when the messestand was updated.
    if (updated == true) {
      hasChanges = true;

      await getMyMessestaende();
    }
  }

  // Activates featured status for one month.
  Future<void> activateFeatured(int messestandId) async {
    final token = await storage.read(key: 'auth_token');

    final response = await http.post(
      Uri.parse(
        'http://127.0.0.1:8000/api/messestaende/$messestandId/featured',
      ),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

 

    if (!mounted) return;

    // Handles successful featured activation.
    if (response.statusCode == 200) {
      hasChanges = true;

      showMessage('Featured wurde für einen Monat aktiviert.');

      await getMyMessestaende();

      return;
    }

    // Handles authorization errors.
    if (response.statusCode == 403) {
      final data = jsonDecode(response.body);

      showMessage(
        data['message'] ??
            'Du darfst diesen Messestand nicht als Featured aktivieren.',
      );

      return;
    }

    // Handles authentication errors.
    if (response.statusCode == 401) {
      showMessage('Deine Anmeldung ist nicht mehr gültig.');

      return;
    }

    // Handles all other unexpected errors.
    showMessage('Featured konnte nicht aktiviert werden.');
  }

  // Shows a confirmation dialog before activating Featured.
  Future<void> confirmFeatured(dynamic messestand) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Featured aktivieren'),
          content: Text(
            '"${messestand['title']}" wird für einen Monat '
            'als Featured angezeigt.\n\n'
            'Preis: 5,00 € (Simulation)',
          ),
          actions: [
            // Cancels the activation.
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Abbrechen'),
            ),

            // Confirms the activation.
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Aktivieren'),
            ),
          ],
        );
      },
    );

    // Activates Featured only after confirmation.
    if (confirmed == true) {
      await activateFeatured(messestand['id']);
    }
  }

  // Deletes one messestand through the protected Laravel API.
  Future<void> deleteMessestand(int messestandId) async {
    final token = await storage.read(key: 'auth_token');

    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/api/messestaende/$messestandId'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (!mounted) return;

    // Handles a successful delete.
    if (response.statusCode == 200) {
      hasChanges = true;

      showMessage('Messestand wurde gelöscht.');

      await getMyMessestaende();

      return;
    }

    // Handles authorization errors.
    if (response.statusCode == 403) {
      final data = jsonDecode(response.body);

      showMessage(
        data['message'] ?? 'Du darfst diesen Messestand nicht löschen.',
      );

      return;
    }

    // Handles authentication errors.
    if (response.statusCode == 401) {
      showMessage('Deine Anmeldung ist nicht mehr gültig.');

      return;
    }

    // Handles all other unexpected errors.
    showMessage('Messestand konnte nicht gelöscht werden.');
  }

  // Shows a confirmation dialog before deleting a messestand.
  Future<void> confirmDelete(dynamic messestand) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Messestand löschen'),
          content: Text(
            'Möchtest du "${messestand['title']}" wirklich löschen?',
          ),
          actions: [
            // Cancels the delete action.
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Abbrechen'),
            ),

            // Confirms the delete action.
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Löschen'),
            ),
          ],
        );
      },
    );

    // Deletes the messestand only after confirmation.
    if (confirmed == true) {
      await deleteMessestand(messestand['id']);
    }
  }

  // Shows feedback messages inside the app.
  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Messestände'),

        // Returns whether messestand data changed.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, hasChanges);
          },
        ),
      ),

      // Opens the screen for creating a new messestand.
      floatingActionButton: FloatingActionButton(
        onPressed: openCreateMessestand,
        child: const Icon(Icons.add),
      ),

      // Displays the user's messestaende.
      body: messestaende.isEmpty
          ? const Center(child: Text('Noch keine Messestände'))
          : ListView.builder(
              itemCount: messestaende.length,
              itemBuilder: (context, index) {
                final messestand = messestaende[index];

                final isFeatured = messestand['featured'] == 1;

                return ListTile(
                  leading: Icon(isFeatured ? Icons.star : Icons.store),

                  // Displays the messestand title.
                  title: Text(messestand['title']),

                  // Displays the description and Featured status.
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(messestand['description'] ?? 'Keine Beschreibung'),

                      if (isFeatured)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'Featured aktiv',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),

                  // Displays edit, featured and delete buttons.
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Opens the edit screen.
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          openEditMessestand(messestand);
                        },
                      ),

                      // Activates Featured for this messestand.
                      IconButton(
                        icon: Icon(isFeatured ? Icons.star : Icons.star_border),
                        onPressed: isFeatured
                            ? null
                            : () {
                                confirmFeatured(messestand);
                              },
                      ),

                      // Opens the delete confirmation dialog.
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          confirmDelete(messestand);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
