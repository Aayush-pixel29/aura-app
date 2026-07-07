import 'package:flutter/material.dart';
import 'package:aura_app/views/art_creation_screen.dart';
import 'package:aura_app/views/chat_screen.dart';
import 'package:aura_app/views/journal_screen.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, MMMM d').format(DateTime.now());
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D0B14),
              Color(0xFF1A1433),
              Color(0xFF0D0B14),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  _getGreeting(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fade(duration: 500.ms).slideY(begin: -0.2, end: 0),
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ).animate().fade(duration: 600.ms, delay: 100.ms).slideY(begin: -0.2, end: 0),
                
                const SizedBox(height: 40),
                
                Text(
                  "How would you like to express yourself today?",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fade(duration: 700.ms, delay: 200.ms),
                
                const SizedBox(height: 30),
                
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.85,
                    children: [
                      _buildGlassCard(
                        context: context,
                        title: "Talk it\nOut",
                        icon: Icons.chat_bubble_outline,
                        color: const Color(0xFF7B61FF),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                      ).animate().fade(duration: 600.ms, delay: 300.ms).scale(begin: const Offset(0.9, 0.9)),
                      
                      _buildGlassCard(
                        context: context,
                        title: "Paint a\nFeeling",
                        icon: Icons.palette_outlined,
                        color: const Color(0xFF00E5FF),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArtCreationScreen())),
                      ).animate().fade(duration: 600.ms, delay: 400.ms).scale(begin: const Offset(0.9, 0.9)),
                      
                      _buildGlassCard(
                        context: context,
                        title: "Your\nJournal",
                        icon: Icons.book_outlined,
                        color: const Color(0xFFFF4081),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JournalScreen())),
                      ).animate().fade(duration: 600.ms, delay: 500.ms).scale(begin: const Offset(0.9, 0.9)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({
    required BuildContext context, 
    required String title, 
    required IconData icon, 
    required Color color, 
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 24,
        blur: 20,
        alignment: Alignment.bottomCenter,
        border: 1.5,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          stops: const [0.1, 1],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.5),
            color.withOpacity(0.1),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}