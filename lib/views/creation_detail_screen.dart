import 'package:flutter/material.dart';
import '../models/creation_model.dart';

class CreationDetailScreen extends StatelessWidget {
  final CreationModel creation;

  const CreationDetailScreen({super.key, required this.creation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(creation.type == CreationType.art ? 'Artwork' : 'Story'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the image if it's an art creation
            if (creation.type == CreationType.art)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  creation.resultData,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 300,
                ),
              ),
            
            const SizedBox(height: 24),

            // Display the original prompt
            Text(
              'Your Prompt:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              creation.prompt,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}