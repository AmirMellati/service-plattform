import 'package:flutter/material.dart';
import 'my_messestaende_screen.dart';

class MeinsScreen extends StatelessWidget {
  const MeinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meins')),
      body: ListView(
        children:[
          ListTile(leading: Icon(Icons.person), title: Text('Profil')),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Meine Messestände'),

            // Opens the user's messestaende screen.
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyMessestaendeScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.assignment),
            title: Text('Meine Aufträge'),
          ),
          ListTile(leading: Icon(Icons.settings), title: Text('Einstellungen')),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.home),
            label: const Text('Home'),
          ),
        ),
      ),
    );
  }
}
