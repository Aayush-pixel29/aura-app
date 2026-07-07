import 'package:flutter/foundation.dart';
import '../views/chat_screen.dart';
import './api_service.dart';

class AuraChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [
    ChatMessage(
        text: "Hi there 💜 I'm Aura, your mental wellness companion. How are you feeling today?",
        isUser: false),
  ];

  bool _isTyping = false;

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(text: text, isUser: true));
    _isTyping = true;
    notifyListeners();

    try {
      final aiResponse = await ApiService.sendChatMessage(text);
      _messages.add(ChatMessage(text: aiResponse, isUser: false));
    } catch (e) {
      _messages.add(ChatMessage(
          text: "I'm here with you 💜 Sometimes the connection gets a little tricky. Want to try again?",
          isUser: false));
    }

    _isTyping = false;
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    _messages.add(ChatMessage(
        text: "Hi again 💜 What's on your mind?", isUser: false));
    _isTyping = false;
    notifyListeners();
  }
}