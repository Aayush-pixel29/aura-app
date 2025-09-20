import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/journal_provider.dart';
import '../widgets/journal_entry_card.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journal'),
      ),
      body: Consumer<JournalProvider>(
        builder: (context, journalProvider, child) {
          // If the list of creations is empty, show a message
          if (journalProvider.creations.isEmpty) {
            return const Center(
              child: Text(
                'Your journal is empty.\nStart by creating something!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // If there are creations, display them in a list
          return ListView.builder(
            itemCount: journalProvider.creations.length,
            itemBuilder: (context, index) {
              final creation = journalProvider.creations[index];
              return JournalEntryCard(creation: creation);
            },
          );
        },
      ),
    );
  }
}