import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const MessestandApp());
}

class MessestandApp extends StatelessWidget {
  const MessestandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messestand',
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
    );
  }
}