import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class StorageService {
  static const String _historyKey = 'chat_history';

  Future<List<ChatMessage>> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      
      if (historyJson == null) return [];
      
      final List<dynamic> historyList = jsonDecode(historyJson);
      return historyList.map((json) => ChatMessage.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveHistory(List<ChatMessage> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(history.map((msg) => msg.toJson()).toList());
      await prefs.setString(_historyKey, historyJson);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      // Handle error silently
    }
  }
}