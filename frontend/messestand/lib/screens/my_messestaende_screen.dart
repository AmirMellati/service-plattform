import 'package:flutter/material.dart';

class MyMessestaendeScreen extends StatelessWidget {
  const MyMessestaendeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Messestände'),
      ),

      // Button for creating a new messestand.
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // The create screen will be added later.
        },
        child: const Icon(Icons.add),
      ),

      body: const Center(
        child: Text('Meine Messestände'),
      ),
    );
  }
}