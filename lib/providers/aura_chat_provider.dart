import 'package:flutter/foundation.dart';
import '../views/chat_screen.dart';
import './api_service.dart'; // Make sure ApiService is imported

class AuraChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [
    ChatMessage(text: "Hello, I'm Aura. What's on your mind today?", isUser: false),
  ];

  List<ChatMessage> get messages => _messages;

  // --- THIS IS THE CORRECTED FUNCTION ---
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Add the user's message to the list immediately.
    _messages.add(ChatMessage(text: text, isUser: true));
    notifyListeners(); // Update the UI to show the user's message.

    // 2. Call the real API and handle the response or any errors.
    try {
      final aiResponse = await ApiService.sendChatMessage(text);
      _messages.add(ChatMessage(text: aiResponse, isUser: false));
    } catch (e) {
      // If an error occurs, add a graceful error message to the chat.
      _messages.add(ChatMessage(text: "Sorry, I'm having a little trouble connecting right now.", isUser: false));
    }
    
    // 3. Notify the UI again to show the AI's response or the error message.
    notifyListeners();
  }
}