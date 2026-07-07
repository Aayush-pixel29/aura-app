import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Point to the local Python Flask backend
  static const String _baseUrl = 'http://localhost:5000';

  static Future<String> sendChatMessage(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': userMessage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? "I'm listening.";
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in sendChatMessage: $e');
      throw Exception('Failed to connect to local Aura backend.');
    }
  }

  static Future<String> generateMoodArt(String emotionPrompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/generate-image'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': emotionPrompt}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['image_url'] ?? 'https://loremflickr.com/800/600/peaceful,nature';
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in generateMoodArt: $e');
      throw Exception('Failed to generate art from local backend.');
    }
  }

  static Future<String> getMoodReflection(String mood) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reflection'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mood': mood}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'Every feeling you have is valid and real.';
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getMoodReflection: $e');
      return 'Every feeling you have is valid and real. 💜';
    }
  }

  static Future<Map<String, dynamic>> analyzeCameraFrame(String base64Image) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analyze-frame'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in analyzeCameraFrame: $e');
      throw Exception('Emotion analysis server is offline.');
    }
  }
}