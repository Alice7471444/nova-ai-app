import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AIService {
  factory AIService() => _instance;
  static final AIService _instance = AIService._internal();
  AIService._internal();

  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4o';
  static const String _keyName = 'openai_api_key';

  Future<String> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName) ?? '';
  }

  Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, key);
  }

  Future<String> generateResponse(String message) async {
    final apiKey = await _getApiKey();
    
    // Fallback to demo responses if no API key
    if (apiKey.isEmpty) {
      return _getDemoResponse(message);
    }
    
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': 'You are NOVA AI, a futuristic AI assistant with a cyberpunk style. Keep responses helpful, conversational, and concise.'},
            {'role': 'user', 'content': message},
          ],
          'max_tokens': 256,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else if (response.statusCode == 429) {
        // Rate limit or no quota - use demo
        return _getDemoResponse(message);
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return _getDemoResponse(message);
    }
  }
  
  String _getDemoResponse(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('hello') || msg.contains('hi')) {
      return "Hey there! I'm NOVA AI. Ask me anything!";
    } else if (msg.contains('how are you')) {
      return "I'm functioning at 100%! Ready to assist you.";
    } else if (msg.contains('who are you')) {
      return "I'm NOVA AI - your futuristic AI assistant!";
    } else if (msg.contains('name')) {
      return "I'm NOVA AI, created with Flutter and OpenAI GPT-4o.";
    } else if (msg.contains('help')) {
      return "I can answer questions, help with tasks, or just chat!";
    } else if (msg.contains('time')) {
      return "I don't know the exact time, but I'm always here for you!";
    } else if (msg.contains('date')) {
      return "Today is a great day! What would you like to do?";
    } else if (msg.contains('weather')) {
      return "I can't check the weather, but I hope it's sunny where you are!";
    } else if (msg.contains('joke')) {
      return "Why do programmers prefer dark mode? Because light attracts bugs! 😄";
    }
    return "That's an interesting question! Configure your OpenAI API key in Settings to unlock full AI responses!";
  }
}