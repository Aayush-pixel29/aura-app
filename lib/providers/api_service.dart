import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // NOTE: The IP address is special. 10.0.2.2 is used by the Android emulator
  // to connect to the host machine's localhost (your computer). If you are
  // running on the web or desktop, you might use '127.0.0.1' instead.
  static const String _baseUrl = 'http://127.0.0.1:5000';

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