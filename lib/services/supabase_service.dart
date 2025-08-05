import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://lohnajutfpglpdzywzuf.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxvaG5hanV0ZnBnbHBkenl3enVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIwNjI4NzMsImV4cCI6MjA2NzYzODg3M30.ykLn6DeXf2QKFlKx52henSLARoXEn7g1fHIC_S1WfGg';

  static SupabaseClient get client => Supabase.instance.client;

  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // Send message to Supabase chat function
  static Future<Map<String, dynamic>> sendMessage({
    required String message,
    String? sessionId,
  }) async {
    try {
      final response = await client.functions.invoke(
        'chat',
        body: {
          'message': message,
          'sessionId': sessionId,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to send message: ${response.status}');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  // Get messages for a session
  static Future<List<ChatMessage>> getMessages(String sessionId) async {
    try {
      final response = await client.functions.invoke(
        'get-messages',
        body: {
          'sessionId': sessionId,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to get messages: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      final messages = data['messages'] as List<dynamic>;

      return messages.map((msg) => ChatMessage.fromSupabaseJson(msg)).toList();
    } catch (e) {
      throw Exception('Error getting messages: $e');
    }
  }

  // Create a new chat session
  static Future<String> createChatSession() async {
    try {
      final response = await client
          .from('chat_sessions')
          .insert({})
          .select()
          .single();

      return response['id'] as String;
    } catch (e) {
      throw Exception('Error creating chat session: $e');
    }
  }

  // Get chat sessions
  static Future<List<Map<String, dynamic>>> getChatSessions() async {
    try {
      final response = await client
          .from('chat_sessions')
          .select('*, messages(*)')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error getting chat sessions: $e');
    }
  }

  // Delete a chat session
  static Future<void> deleteChatSession(String sessionId) async {
    try {
      await client
          .from('chat_sessions')
          .delete()
          .eq('id', sessionId);
    } catch (e) {
      throw Exception('Error deleting chat session: $e');
    }
  }
} 