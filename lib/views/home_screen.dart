import 'package:flutter/material.dart';
import 'package:aura_app/views/art_creation_screen.dart';
import 'package:aura_app/views/chat_screen.dart';
import 'package:aura_app/views/journal_screen.dart';
// Assuming you have a reusable button widget
import 'package:aura_app/widgets/home_action_button.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "How would you like to express yourself?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            HomeActionButton(
              icon: Icons.palette_outlined,
              text: "Paint a Feeling",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ArtCreationScreen()));
              },
            ),
            const SizedBox(height: 20),
            HomeActionButton(
              icon: Icons.chat_bubble_outline,
              text: "Talk it Out",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
              },
            ),
            const SizedBox(height: 20),
            HomeActionButton(
              icon: Icons.book_outlined,
              text: "View Your Journal",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const JournalScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}