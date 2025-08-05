import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class ChatService {
  static const String baseUrl = 'https://api.openai.com/v1/chat/completions';

  // TODO: Replace with your actual OpenAI API key

  static const String apiKey = '';

  Future<String> sendMessage({
    required String message,
    String? context,
    bool isRagMode = false,
  }) async {
    try {
      final messages = <Map<String, dynamic>>[];

      if (isRagMode && context != null) {
        messages.add({
          'role': 'system',
          'content':
              'You are a helpful assistant. Answer questions based on the provided document context. If the answer is in the document, start your response with "According to the PDF:" and include relevant snippets.',
        });
        messages.add({
          'role': 'user',
          'content': 'Context from document: $context\n\nQuestion: $message',
        });
      } else {
        messages.add({
          'role': 'system',
          'content':
              'You are a helpful assistant. Answer questions naturally and conversationally.',
        });
        messages.add({'role': 'user', 'content': message});
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messages,
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }
}
