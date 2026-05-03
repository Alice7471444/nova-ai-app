import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Choose your AI: 'openai' or 'gemini'
enum AIProvider { openai, gemini }

class AIService {
  factory AIService() => _instance;
  static final AIService _instance = AIService._internal();
  AIService._internal();

  // OpenAI settings
  static const String _openAiUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _openAiModel = 'gpt-4o';
  
  // Gemini settings (free!)
  static const String _geminiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  static const String _geminiUrlWithKey = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=YOUR_GEMINI_KEY';
  
  static const String _keyName = 'openai_api_key';
  static const String _geminiKeyName = 'gemini_api_key';
  static const String _providerName = 'ai_provider';

  AIProvider _currentProvider = AIProvider.gemini; // Default to Gemini (free!)

  Future<String> _getApiKey(String keyName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyName) ?? '';
  }

  Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, key);
  }
  
  Future<void> setGeminiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_geminiKeyName, key);
  }
  
  Future<void> setProvider(AIProvider provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_providerName, provider.index);
    _currentProvider = provider;
  }

  Future<String> generateResponse(String message) async {
    if (_currentProvider == AIProvider.gemini) {
      return _generateGeminiResponse(message);
    } else {
      return _generateOpenAIResponse(message);
    }
  }
  
  Future<String> _generateGeminiResponse(String message) async {
    final apiKey = await _getApiKey(_geminiKeyName);
    if (apiKey.isEmpty) {
      return _getDemoResponse(message);
    }
    
    try {
      final response = await http.post(
        Uri.parse('$_geminiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': message}]}],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 256,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        return _getDemoResponse(message);
      }
    } catch (e) {
      return _getDemoResponse(message);
    }
  }

  Future<String> _generateOpenAIResponse(String message) async {
    final apiKey = await _getApiKey(_keyName);
    if (apiKey.isEmpty) {
      return _getDemoResponse(message);
    }
    
    try {
      final response = await http.post(
        Uri.parse(_openAiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _openAiModel,
          'messages': [
            {'role': 'system', 'content': 'You are NOVA AI, a futuristic AI assistant.'},
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
    } else if (msg.contains('joke')) {
      return "Why do programmers prefer dark mode? Because light attracts bugs! 😄";
    }
    return "Interesting question! Configure AI in Settings to get smart responses!";
  }
}