import 'package:flutter/material.dart';
import 'package:aura_app/providers/api_service.dart';
import 'package:aura_app/views/chat_screen.dart';
import 'package:aura_app/widgets/camera_panel.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MoodCheckScreen extends StatefulWidget {
  const MoodCheckScreen({super.key});

  @override
  State<MoodCheckScreen> createState() => _MoodCheckScreenState();
}

class _MoodCheckScreenState extends State<MoodCheckScreen> {
  int? _selectedMoodIndex;
  String? _reflection;
  bool _loadingReflection = false;
  
  bool _useCamera = false;
  bool _isAnalyzingFace = false;
  String? _cvMessage;

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😄', 'label': 'Joyful', 'color': const Color(0xFFFFD700), 'cvKeys': ['Happy', 'Joyful']},
    {'emoji': '😊', 'label': 'Calm', 'color': const Color(0xFF7BC67E), 'cvKeys': ['Calm', 'Neutral']},
    {'emoji': '😐', 'label': 'Neutral', 'color': const Color(0xFF9B89CC), 'cvKeys': ['Neutral']},
    {'emoji': '😔', 'label': 'Sad', 'color': const Color(0xFF5B8DD9), 'cvKeys': ['Sad', 'Sadness']},
    {'emoji': '😰', 'label': 'Anxious', 'color': const Color(0xFFFF9800), 'cvKeys': ['Anxious', 'Fear']},
    {'emoji': '😤', 'label': 'Frustrated', 'color': const Color(0xFFFF5252), 'cvKeys': ['Frustrated', 'Anger', 'Disgust']},
    {'emoji': '😴', 'label': 'Tired', 'color': const Color(0xFF78909C), 'cvKeys': ['Tired']},
    {'emoji': '🤩', 'label': 'Excited', 'color': const Color(0xFFFF4081), 'cvKeys': ['Excited', 'Surprise']},
  ];

  Future<void> _onMoodSelected(int index) async {
    setState(() {
      _selectedMoodIndex = index;
      _reflection = null;
      _loadingReflection = true;
    });

    try {
      final reflection = await ApiService.getMoodReflection(
          '${_moods[index]['label']} - ${_moods[index]['emoji']}');
      if (mounted) {
        setState(() {
          _reflection = reflection;
          _loadingReflection = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _reflection = 'Every feeling you have is valid and real.';
          _loadingReflection = false;
        });
      }
    }
  }

  // Called when a frame is captured from the camera panel
  Future<void> _handleFaceAnalysis(String base64Image) async {
    if (_isAnalyzingFace) return;
    
    setState(() {
      _isAnalyzingFace = true;
      _cvMessage = "Analyzing your expression...";
    });

    try {
      final result = await ApiService.analyzeCameraFrame(base64Image);
      final detectedEmotion = result['emotion'] as String? ?? 'Neutral';
      
      // Match detected emotion to our local list
      int matchedIndex = 2; // Default to neutral
      
      for (int i = 0; i < _moods.length; i++) {
        final keys = _moods[i]['cvKeys'] as List<String>;
        if (keys.any((key) => key.toLowerCase() == detectedEmotion.toLowerCase())) {
          matchedIndex = i;
          break;
        }
      }

      if (mounted) {
        setState(() {
          _selectedMoodIndex = matchedIndex;
          _isAnalyzingFace = false;
          _cvMessage = "Detected Expression: $detectedEmotion!";
        });
        
        // Load reflection for detected emotion
        _onMoodSelected(matchedIndex);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzingFace = false;
          _cvMessage = "Analysis failed. Server might be launching...";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Mood Check-In'),
        backgroundColor: const Color(0xFF0A0815),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0815), Color(0xFF130F23)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'AI Mood Scan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fade(duration: 500.ms),
                    
                    // Toggle camera mode
                    Switch.adaptive(
                      value: _useCamera,
                      activeColor: const Color(0xFF00E5FF),
                      onChanged: (val) {
                        setState(() {
                          _useCamera = val;
                          _cvMessage = null;
                        });
                      },
                    ),
                  ],
                ),
                
                Text(
                  _useCamera 
                    ? 'Aura uses computer vision to analyze your expression live' 
                    : 'Choose manually or switch the toggle for live camera analysis',
                  style: const TextStyle(color: Color(0xFF9B89CC), fontSize: 14),
                ).animate().fade(duration: 600.ms, delay: 100.ms),

                const SizedBox(height: 24),

                // Live Camera View
                if (_useCamera) ...[
                  SizedBox(
                    height: 220,
                    child: CameraPanel(
                      onFrameCaptured: _handleFaceAnalysis,
                      isAnalyzing: _isAnalyzingFace,
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                  
                  if (_cvMessage != null) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        _cvMessage!,
                        style: const TextStyle(
                          color: Color(0xFF00E5FF),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],

                // Mood Selection Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: _moods.length,
                  itemBuilder: (context, index) {
                    final mood = _moods[index];
                    final isSelected = _selectedMoodIndex == index;
                    final color = mood['color'] as Color;

                    return GestureDetector(
                      onTap: () => _onMoodSelected(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: isSelected
                              ? color.withOpacity(0.25)
                              : const Color(0xFF1A1535),
                          border: Border.all(
                            color: isSelected
                                ? color.withOpacity(0.8)
                                : Colors.white.withOpacity(0.07),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.3),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              mood['emoji'] as String,
                              style: TextStyle(
                                fontSize: isSelected ? 32 : 28,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              mood['label'] as String,
                              style: TextStyle(
                                color: isSelected ? color : const Color(0xFF9B89CC),
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ).animate().fade(duration: 500.ms, delay: 200.ms),

                const SizedBox(height: 28),

                // AI Reflection Results
                if (_selectedMoodIndex != null) ...[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          (_moods[_selectedMoodIndex!]['color'] as Color)
                              .withOpacity(0.12),
                          const Color(0xFF1A1535).withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: (_moods[_selectedMoodIndex!]['color'] as Color)
                            .withOpacity(0.25),
                      ),
                    ),
                    child: _loadingReflection
                        ? const Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Color(0xFF7B61FF),
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Aura is reflecting...',
                                style: TextStyle(
                                    color: Color(0xFF9B89CC), fontSize: 14),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('✨',
                                      style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Aura says',
                                    style: TextStyle(
                                      color: _moods[_selectedMoodIndex!]
                                          ['color'] as Color,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _reflection ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  height: 1.5,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                  ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final moodLabel = _moods[_selectedMoodIndex!]['label'];
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ChatScreen(initialMessage: "I'm feeling $moodLabel today"),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B61FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Talk to Aura about it →',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ).animate().fade(duration: 400.ms, delay: 200.ms),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
