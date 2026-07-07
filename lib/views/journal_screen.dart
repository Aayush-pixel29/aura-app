import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../providers/journal_provider.dart';
import '../models/creation_model.dart';
// Note: We won't use the old journal_entry_card.dart as we're redesigning it inline here

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journal'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E1A29), Color(0xFF0D0B14)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D0B14), Color(0xFF120C1F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer<JournalProvider>(
          builder: (context, journalProvider, child) {
            if (journalProvider.creations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.book_outlined, size: 80, color: Colors.white.withOpacity(0.1)),
                    const SizedBox(height: 20),
                    const Text(
                      'Your journal is empty.\nStart by creating something!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.white54),
                    ),
                  ],
                ).animate().fade(duration: 500.ms).slideY(begin: 0.2, end: 0),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: journalProvider.creations.length,
              itemBuilder: (context, index) {
                final creation = journalProvider.creations[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: _buildJournalEntryCard(context, creation),
                ).animate().fade(delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.1, end: 0);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildJournalEntryCard(BuildContext context, CreationModel creation) {
    final bool isArt = creation.type == CreationType.art;
    
    return GlassmorphicContainer(
      width: double.infinity,
      height: isArt ? 350 : 120, // Taller if it has an image
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.center,
      border: 1.5,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          isArt ? const Color(0xFF00E5FF).withOpacity(0.3) : const Color(0xFFFF4081).withOpacity(0.3),
          Colors.white.withOpacity(0.0)
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isArt ? Icons.palette_outlined : Icons.chat_bubble_outline,
                  color: isArt ? const Color(0xFF00E5FF) : const Color(0xFFFF4081),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    creation.prompt,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatDate(creation.timestamp),
                  style: const TextStyle(color: Colors.white30, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isArt)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    creation.resultData,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white.withOpacity(0.05),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image_outlined, color: Colors.white24, size: 40),
                              SizedBox(height: 8),
                              Text('Image failed to load', style: TextStyle(color: Colors.white24, fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: Colors.white.withOpacity(0.02),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              Expanded(
                child: Text(
                  creation.resultData,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }
}