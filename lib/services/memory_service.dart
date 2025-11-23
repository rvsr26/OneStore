import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryService {
  static const String _chatKey = 'chat_history';
  static const String _personaKey = 'user_persona';
  static const String _moodKey = 'user_mood';

  /// Save a chat message (role: "user" or "assistant")
  static Future<void> saveChat(String role, String text, DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_chatKey) ?? '[]';
    final List<dynamic> arr = jsonDecode(raw);
    arr.add({
      'role': role,
      'text': text,
      'time': time.toIso8601String(),
    });
    await prefs.setString(_chatKey, jsonEncode(arr));
  }

  static Future<List<Map<String, dynamic>>> loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_chatKey) ?? '[]';
    final List<dynamic> arr = jsonDecode(raw);
    return arr.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatKey);
  }

  static Future<void> savePersona(String persona) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_personaKey, persona);
  }

  static Future<String?> loadPersona() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_personaKey);
  }

  static Future<void> saveMood(String mood) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_moodKey, mood);
  }

  static Future<String?> loadMood() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_moodKey);
  }
}
