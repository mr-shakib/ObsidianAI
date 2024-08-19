import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  String _apiKey = '';

  void updateApiKey(String newApiKey) {
    _apiKey = newApiKey;
  }

  Future<String> getResponse(String prompt) async {
    if (_apiKey.isEmpty) {
      throw Exception('API Key is not set');
    }

    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_apiKey');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Failed to get response from Gemini API');
    }
  }
}