import 'package:flutter/material.dart';

class MessestandDetailScreen extends StatelessWidget {
  // Stores the messestand selected on the HomeScreen.
  final dynamic messestand;

  const MessestandDetailScreen({
    super.key,
    required this.messestand,
  });

  @override
  Widget build(BuildContext context) {
    // Gets all images of the selected messestand.
    final bilder = (messestand['bilder'] ?? []) as List<dynamic>;

    // Gets the first image if one exists.
    final firstBild = bilder.isNotEmpty ? bilder[0] : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(messestand['title']),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Displays the first messestand image.
            if (firstBild != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'http://127.0.0.1:8000/storage/${firstBild['bild']}',
                  width: double.infinity,
                  height: 230,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 20),

            // Displays the messestand title.
            Text(
              messestand['title'],
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Displays the handwerker name.
            Text(
              'Handwerker: ${messestand['user']['name']}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Displays all skills.
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: ((messestand['skills'] ?? []) as List<dynamic>)
                  .map<Widget>((skill) {
                return Chip(
                  label: Text(skill['name']),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Displays the description.
            const Text(
              'Beschreibung',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              messestand['description'] ?? 'Keine Beschreibung',
            ),

            const SizedBox(height: 20),

            // Displays the price range.
            Text(
              'Preis: '
              '${messestand['price_from'] ?? '-'} € - '
              '${messestand['price_to'] ?? '-'} €',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Displays the public service area.
            if (messestand['einsatzgebiet'] != null)
              Row(
                children: [
                  const Icon(Icons.location_on_outlined),
                  const SizedBox(width: 6),
                  Text(
                    '${messestand['einsatzgebiet']['city']} - '
                    '${messestand['einsatzgebiet']['district']}',
                  ),
                ],
              ),

            const SizedBox(height: 30),

            // Placeholder for the map that will be implemented later.
            Container(
              width: double.infinity,
              height: 180,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('für die Karte (Frag Max)'),
            ),

            const SizedBox(height: 20),

            // Placeholder for the future Anfrage workflow.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Anfrage functionality will be added later.
                },
                child: const Text('Anfrage senden'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}