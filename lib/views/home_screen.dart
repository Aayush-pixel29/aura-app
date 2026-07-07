import 'package:flutter/material.dart';
import 'package:aura_app/views/art_creation_screen.dart';
import 'package:aura_app/views/chat_screen.dart';
import 'package:aura_app/views/journal_screen.dart';
import 'package:aura_app/views/mood_check_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 5) return 'Still up?';
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  String _getEmoji() {
    var hour = DateTime.now().hour;
    if (hour < 5) return '🌙';
    if (hour < 12) return '☀️';
    if (hour < 17) return '🌤️';
    if (hour < 21) return '🌅';
    return '⭐';
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A0815),
              Color(0xFF130F23),
              Color(0xFF0D0B14),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()} ${_getEmoji()}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ).animate().fade(duration: 600.ms).slideY(begin: -0.3, end: 0),
                        Text(
                          formattedDate,
                          style: const TextStyle(color: Color(0xFF9B89CC), fontSize: 14),
                        ).animate().fade(duration: 700.ms, delay: 100.ms),
                      ],
                    ),
                    _buildAuraOrb(),
                  ],
                ),

                const SizedBox(height: 32),

                // How are you feeling banner
                _buildMoodCheckBanner(context)
                    .animate()
                    .fade(duration: 600.ms, delay: 200.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 28),

                // Section title
                const Text(
                  'How would you like to express yourself?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ).animate().fade(duration: 600.ms, delay: 300.ms),

                const SizedBox(height: 16),

                // Main feature cards
                _buildFeatureCard(
                  context: context,
                  emoji: '💬',
                  title: 'Talk it Out',
                  subtitle: 'Share what\'s on your mind with your AI companion',
                  gradientColors: [const Color(0xFF7B61FF), const Color(0xFF5844C4)],
                  glowColor: const Color(0xFF7B61FF),
                  onTap: () => Navigator.push(context, _buildRoute(const ChatScreen())),
                  delay: 400,
                ),

                const SizedBox(height: 14),

                _buildFeatureCard(
                  context: context,
                  emoji: '🎨',
                  title: 'Paint a Feeling',
                  subtitle: 'Visualize your emotions as beautiful AI art',
                  gradientColors: [const Color(0xFF00C4CC), const Color(0xFF0077B6)],
                  glowColor: const Color(0xFF00E5FF),
                  onTap: () => Navigator.push(context, _buildRoute(const ArtCreationScreen())),
                  delay: 500,
                ),

                const SizedBox(height: 14),

                _buildFeatureCard(
                  context: context,
                  emoji: '📔',
                  title: 'My Journal',
                  subtitle: 'Revisit your past reflections and creations',
                  gradientColors: [const Color(0xFFFF4081), const Color(0xFFB5255C)],
                  glowColor: const Color(0xFFFF4081),
                  onTap: () => Navigator.push(context, _buildRoute(const JournalScreen())),
                  delay: 600,
                ),

                const SizedBox(height: 28),

                // Breathing Exercise Banner
                _buildBreathingBanner(context)
                    .animate()
                    .fade(duration: 600.ms, delay: 700.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 24),

                // Daily affirmation
                _buildAffirmation()
                    .animate()
                    .fade(duration: 600.ms, delay: 800.ms),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuraOrb() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF7B61FF).withOpacity(0.8 + 0.2 * _pulseController.value),
                const Color(0xFF00E5FF).withOpacity(0.4),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7B61FF)
                    .withOpacity(0.3 + 0.2 * _pulseController.value),
                blurRadius: 16 + 8 * _pulseController.value,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
        );
      },
    ).animate().fade(duration: 800.ms, delay: 200.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildMoodCheckBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, _buildRoute(const MoodCheckScreen())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1A35), Color(0xFF161230)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: const Color(0xFF7B61FF).withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B61FF).withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF7B61FF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text('🌿', style: TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How are you feeling?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Check in with yourself today',
                    style: TextStyle(color: Color(0xFF9B89CC), fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFF7B61FF), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String emoji,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required Color glowColor,
    required VoidCallback onTap,
    required int delay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              gradientColors[0].withOpacity(0.25),
              gradientColors[1].withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: gradientColors[0].withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.08),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF9B89CC),
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: gradientColors[0].withOpacity(0.7),
              size: 16,
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 600.ms, delay: Duration(milliseconds: delay)).slideX(begin: 0.1, end: 0);
  }

  Widget _buildBreathingBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0D1F2D),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.05),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00E5FF)
                      .withOpacity(0.1 + 0.05 * _pulseController.value),
                  border: Border.all(
                    color: const Color(0xFF00E5FF)
                        .withOpacity(0.3 + 0.2 * _pulseController.value),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Text('🫁', style: TextStyle(fontSize: 26)),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Breathing Exercise',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '4-7-8 technique • 2 minutes',
                style: TextStyle(color: Color(0xFF5BC8D3), fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
            ),
            child: const Text(
              'Try it',
              style: TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAffirmation() {
    const affirmations = [
      "You are enough, exactly as you are right now.",
      "Every day is a new chance to grow and be kind to yourself.",
      "Your feelings are valid. Your journey is your own.",
      "Small steps still move you forward. Keep going.",
      "You deserve care, compassion, and peace.",
    ];
    final today = DateTime.now().day % affirmations.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7B61FF).withOpacity(0.08),
            const Color(0xFFFF4081).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('✨', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text(
                "Today's Affirmation",
                style: TextStyle(
                  color: Color(0xFF9B89CC),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '"${affirmations[today]}"',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Route _buildRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}