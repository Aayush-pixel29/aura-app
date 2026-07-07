import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Pointing to the new Firebase Cloud Functions backend!
  // Assuming default region 'us-central1'
  static const String _baseUrl = 'https://us-central1-aura-app-fe69f.cloudfunctions.net';

  // Method to generate an image by sending a prompt to the backend
  static Future<String> generateImage(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/generate-image'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'prompt': prompt,
        }),
      );

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON.
        final data = jsonDecode(response.body);
        return data['image_url'];
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception.
        throw Exception('Failed to generate image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occur during the request
      print('Error in generateImage: $e');
      throw Exception('Failed to connect to the server.');
    }
  }

  // --- THIS FUNCTION NEEDS TO BE INSIDE THE CLASS ---
  static Future<String> sendChatMessage(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'), // The new endpoint
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'prompt': prompt}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else {
        throw Exception('Failed to get chat response. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in sendChatMessage: $e');
      throw Exception('Failed to connect to the server for chat.');
    }
  }
  
} // <-- The class definition ends here