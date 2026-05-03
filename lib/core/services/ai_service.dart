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
    if (apiKey.isEmpty) {
      return "⚠️ API key not set. Go to Settings > AI Settings to enter your OpenAI API key.";
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
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return '❌ Connection error. Check internet.';
    }
  }
}