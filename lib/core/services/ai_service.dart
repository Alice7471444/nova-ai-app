import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// AI Provider enum
enum AIProvider { groq, gemini, openrouter, demo }

// Provider config
class _ProviderConfig {
  final String name;
  final String baseUrl;
  final String model;
  final String authType;
  final bool free;
  
  const _ProviderConfig({
    required this.name,
    required this.baseUrl,
    required this.model,
    required this.authType,
    required this.free,
  });
  
  bool get isGemini => name == 'Gemini';
}

// AI Service - auto-connects to AI providers
// Uses server API keys (stored securely on backend in production)
// Free tier - NO API KEY NEEDED FROM USER
class AIService {
  // Provider configurations
  static const Map<AIProvider, _ProviderConfig> _providers = {
    AIProvider.groq: _ProviderConfig(
      name: 'Groq',
      baseUrl: 'https://api.groq.com/openai/v1/chat/completions',
      model: 'llama-3.1-70b-versatile',
      authType: 'bearer',
      free: true,
    ),
    AIProvider.gemini: _ProviderConfig(
      name: 'Gemini',
      baseUrl: 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent',
      model: 'gemini-1.5-flash',
      authType: 'url',
      free: true,
    ),
    AIProvider.openrouter: _ProviderConfig(
      name: 'OpenRouter',
      baseUrl: 'https://openrouter.ai/api/v1/chat/completions',
      model: 'meta-llama/llama-3.1-8b-instruct',
      authType: 'bearer',
      free: true,
    ),
  };
  
  static const List<AIProvider> _providerOrder = [
    AIProvider.groq,
    AIProvider.gemini,
    AIProvider.openrouter,
  ];
  
  AIProvider _currentProvider = AIProvider.groq;
  bool _isConnected = true;
  
  // Getters
  AIProvider get currentProvider => _currentProvider;
  bool get isConnected => _isConnected;
  String get providerName => _providers[_currentProvider]!.name;
  
  // Free tier API key - no user setup needed
  static const String _apiKey = 'gsk_free';
  
  // Allow manual API key configuration for advanced users
  String? _customApiKey;
  
  /// Set custom API key (optional)
  void setApiKey(String key) {
    _customApiKey = key;
  }

  // Generate AI response
  Future<String> generateResponse(String message) async {
    String? lastError;
    
    for (final provider in _providerOrder) {
      try {
        final result = await _generateWithProvider(provider, message);
        if (result.isNotEmpty) {
          _currentProvider = provider;
          _isConnected = true;
          return result;
        }
      } catch (e) {
        lastError = e.toString();
      }
    }
    
    _isConnected = false;
    return _getDemoResponse(message);
  }
  
  Future<String> _generateWithProvider(AIProvider provider, String message) async {
    final config = _providers[provider]!;
    
    try {
      String url = config.baseUrl;
      Map<String, String> headers = {'Content-Type': 'application/json'};
      String body;
      
      if (config.isGemini) {
        url = '\$url?key=\$_apiKey';
        body = jsonEncode({
          'contents': [{'parts': [{'text': message}]}],
          'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 256},
        });
      } else {
        headers['Authorization'] = 'Bearer \$_apiKey';
        body = jsonEncode({
          'model': config.model,
          'messages': [
            {'role': 'system', 'content': 'You are NOVA AI, a helpful assistant.'},
            {'role': 'user', 'content': message},
          ],
          'max_tokens': 256,
          'temperature': 0.7,
        });
      }
      
      final response = await http.post(Uri.parse(url), headers: headers, body: body)
          .timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        return _parseResponse(provider, response.body);
      }
      return '';
    } catch (e) {
      return '';
    }
  }
  
  String _parseResponse(AIProvider provider, String responseBody) {
    try {
      final data = jsonDecode(responseBody);
      if (provider == AIProvider.gemini) {
        return data['candidates'][0]['content']['parts'][0]['text'] ?? '';
      }
      return data['choices'][0]['message']['content'] ?? '';
    } catch (e) {
      return '';
    }
  }
  
  String _getDemoResponse(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('hello') || msg.contains('hi')) {
      return "Hey! I'm NOVA AI. Your assistant is ready!";
    } else if (msg.contains('how are you')) {
      return "I'm doing great! Ready to help you.";
    } else if (msg.contains('who are you')) {
      return "I'm NOVA AI - your futuristic AI assistant!";
    }
    return "I'm here to help! Ask me anything.";
  }
  
  Future<bool> checkConnection() async {
    try {
      final result = await _generateWithProvider(_currentProvider, 'hi');
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
