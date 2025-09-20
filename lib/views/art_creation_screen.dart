import 'package:aura_app/models/creation_model.dart';
import 'package:aura_app/providers/api_service.dart'; // NEW import
import 'package:aura_app/providers/journal_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArtCreationScreen extends StatefulWidget {
  const ArtCreationScreen({super.key});

  @override
  State<ArtCreationScreen> createState() => _ArtCreationScreenState();
}

class _ArtCreationScreenState extends State<ArtCreationScreen> {
  final TextEditingController _promptController = TextEditingController();
  String? _imageUrl;
  bool _isLoading = false;

  void _saveCreation(String prompt, String imageUrl) {
    final newCreation = CreationModel(
      prompt: prompt,
      resultData: imageUrl,
      type: CreationType.art,
    );
    Provider.of<JournalProvider>(context, listen: false).addCreation(newCreation);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saved to Journal!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // --- THIS ENTIRE METHOD IS UPDATED ---
  void _generateImage() async {
    if (_promptController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _imageUrl = null;
    });

    try {
      // This is now a REAL API call to our service!
      final imageUrl = await ApiService.generateImage(_promptController.text);

      setState(() {
        _imageUrl = imageUrl;
        _isLoading = false;
      });

      // If successful, save the creation
      _saveCreation(_promptController.text, imageUrl);

    } catch (e) {
      // If an error occurs, stop loading and show an error message
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paint a Feeling")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                labelText: "Describe what's on your mind...",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateImage,
              child: const Text("Generate"),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : _imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.network(_imageUrl!),
                          )
                        : const Text("Your generated art will appear here."),
              ),
            ),
          ],
        ),
      ),
    );
  }
}