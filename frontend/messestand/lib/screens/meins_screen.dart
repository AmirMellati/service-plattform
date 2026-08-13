import 'package:flutter/material.dart';

class MeinsScreen extends StatelessWidget {
  const MeinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meins'),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profil'),
          ),
          ListTile(
            leading: Icon(Icons.store),
            title: Text('Meine Messestände'),
          ),
          ListTile(
            leading: Icon(Icons.assignment),
            title: Text('Meine Aufträge'),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Einstellungen'),
          ),
        ],
      ),
    );
  }
}