import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String apiKey = 'AIzaSyAXT0R6A3_fOr8V7IMiCF3JyZPFAVRJIsg';

  Future<String> getResponse(String prompt) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey');

    try {
      final response = await http
          .post(
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
          )
          .timeout(Duration(seconds: 10)); // Add a timeout

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception(
            'Failed to get response from Gemini API: ${response.statusCode} - ${response.body}');
      }
    } on SocketException catch (e) {
      throw Exception('Network error: Please check your internet connection');
    } on HttpException catch (e) {
      throw Exception('HTTP error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Data format error: ${e.message}');
    } on TimeoutException catch (e) {
      throw Exception('Request timed out: Please try again');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }
}
