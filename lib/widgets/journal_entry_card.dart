import 'package:flutter/material.dart';
import '../models/creation_model.dart';
import 'package:intl/intl.dart';
import '../views/creation_detail_screen.dart'; // Make sure this import is here

class JournalEntryCard extends StatelessWidget {
  final CreationModel creation;

  const JournalEntryCard({super.key, required this.creation});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMMM d, yyyy').format(creation.timestamp);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          creation.type == CreationType.art ? Icons.palette : Icons.edit,
        ),
        title: Text(
          creation.prompt,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(formattedDate),
        trailing: const Icon(Icons.arrow_forward_ios),
        // --- THIS IS THE UPDATED PART ---
        onTap: () {
          // Navigate to the detail screen and pass the specific creation data
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreationDetailScreen(creation: creation),
            ),
          );
        },
      ),
    );
  }
}