import 'package:aura_app/models/creation_model.dart';
import 'package:aura_app/providers/api_service.dart';
import 'package:aura_app/providers/journal_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';

class ArtCreationScreen extends StatefulWidget {
  const ArtCreationScreen({super.key});

  @override
  State<ArtCreationScreen> createState() => _ArtCreationScreenState();
}

class _ArtCreationScreenState extends State<ArtCreationScreen> {
  final TextEditingController _promptController = TextEditingController();
  String? _imageUrl;
  bool _isLoading = false;

  final List<String> _inspirationPrompts = [
    "A peaceful forest at twilight",
    "A chaotic burst of neon colors",
    "A calm ocean under a starry sky",
    "A cozy rainy day in the city"
  ];

  void _saveCreation(String prompt, String imageUrl) {
    final newCreation = CreationModel(
      prompt: prompt,
      resultData: imageUrl,
      type: CreationType.art,
    );
    Provider.of<JournalProvider>(context, listen: false).addCreation(newCreation);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Masterpiece saved to Journal!'),
        backgroundColor: Color(0xFF7B61FF),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _generateImage() async {
    if (_promptController.text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _imageUrl = null;
    });

    try {
      final imageUrl = await ApiService.generateMoodArt(_promptController.text);
      setState(() {
        _imageUrl = imageUrl;
        _isLoading = false;
      });
      _saveCreation(_promptController.text, imageUrl);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paint a Feeling"),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1A29),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: TextField(
                  controller: _promptController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Describe what's on your mind...",
                    labelStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                  maxLines: 3,
                ),
              ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 16),
              
              const Text(
                "Need inspiration?",
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ).animate().fade(delay: 200.ms),
              const SizedBox(height: 8),
              
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _inspirationPrompts.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _promptController.text = _inspirationPrompts[index];
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7B61FF).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF7B61FF).withOpacity(0.5)),
                        ),
                        child: Center(
                          child: Text(
                            _inspirationPrompts[index],
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ).animate().fade(delay: Duration(milliseconds: 300 + (index * 100))).slideX(begin: 0.2, end: 0);
                  },
                ),
              ),

              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _generateImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7B61FF), Color(0xFF00E5FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Generate Art", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ).animate().fade(delay: 500.ms),

              const SizedBox(height: 30),
              
              Expanded(
                child: Center(
                  child: _isLoading
                      ? _buildLoadingState()
                      : _imageUrl != null
                          ? _buildImageResult()
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_outlined, size: 64, color: Colors.white.withOpacity(0.1)),
                                const SizedBox(height: 16),
                                const Text("Your masterpiece will appear here", style: TextStyle(color: Colors.white30)),
                              ],
                            ).animate().fade(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 300,
      borderRadius: 16,
      blur: 20,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7B61FF).withOpacity(0.5), Color(0xFF00E5FF).withOpacity(0.5)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFF00E5FF), size: 40)
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1000.ms, color: const Color(0xFF7B61FF))
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1000.ms, curve: Curves.easeInOutSine)
              .then()
              .scale(begin: const Offset(1.1, 1.1), end: const Offset(0.9, 0.9), duration: 1000.ms, curve: Curves.easeInOutSine),
          const SizedBox(height: 16),
          const Text("Visualizing your feeling...", style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildImageResult() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          _imageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack).fade();
  }
}