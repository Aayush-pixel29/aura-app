import 'package:aura_app/providers/aura_chat_provider.dart'; // NEW
import 'package:aura_app/providers/journal_provider.dart';
import 'package:aura_app/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider(create: (_) => AuraChatProvider()), // NEW
      ],
      child: const AuraApp(),
    ),
  );
}

class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF121212),
        fontFamily: 'Nunito',
      ),
      home: const HomeScreen(),
    );
  }
}