import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// AI Provider enum with priority
enum AIProvider { groq, gemini, openrouter, demo }

class AIService {
  factory AIService() => _instance;
  static final AIService _instance = AIService._internal();
  AIService._internal();

  // Storage keys
  static const String _apiKeyKey = 'ai_api_key';
  static const String _providerKey = 'ai_provider';
  static const String _providerOrderKey = 'provider_order';
  
  // Provider configurations (all FREE)
  static const Map<AIProvider, _ProviderConfig> _providers = {
    AIProvider.groq: _ProviderConfig(
      name: 'Groq',
      url: 'https://api.groq.com/openai/v1/chat/completions',
      model: 'llama-3.1-70b-versatile',
      authHeader: 'Authorization',
      authPrefix: 'Bearer ',
      free: true,
      speed: 'Very Fast',
    ),
    AIProvider.gemini: _ProviderConfig(
      name: 'Gemini',
      url: 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent',
      model: 'gemini-1.5-flash',
      authHeader: '',
      authPrefix: '?key=',
      free: true,
      speed: 'Fast',
    ),
    AIProvider.openrouter: _ProviderConfig(
      name: 'OpenRouter',
      url: 'https://openrouter.ai/api/v1/chat/completions',
      model: 'meta-llama/llama-3.1-8b-instruct',
      authHeader: 'Authorization',
      authPrefix: 'Bearer ',
      free: true,
      speed: 'Fast',
    ),
  };
  
  static const List<AIProvider> _defaultOrder = [
    AIProvider.groq,
    AIProvider.gemini,
    AIProvider.openrouter,
  ];

  AIProvider _currentProvider = AIProvider.groq;
  bool _providerAvailable = true;

  // Get/set current provider
  AIProvider get currentProvider => _currentProvider;
  
  Future<void> setProvider(AIProvider provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_providerKey, provider.index);
    _currentProvider = provider;
  }

  Future<void> setProviderOrder(List<AIProvider> order) async {
    final prefs = await SharedPreferences.getInstance();
    final orderStr = order.map((p) => p.index.toString()).join(',');
    await prefs.setString(_providerOrderKey, orderStr);
  }

  // API key management
  String _apiKey = '';
  
  Future<String> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_apiKeyKey) ?? '';
    return _apiKey;
  }

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, key);
    _apiKey = key;
  }

  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyKey);
    _apiKey = '';
  }

  // Check if provider is available
  Future<bool> checkProviderStatus(AIProvider provider) async {
    final config = _providers[provider]!;
    if (config.isGemini) {
      // Gemini uses key in URL
      final key = await _getApiKey();
      return key.isNotEmpty;
    }
    
    try {
      final response = await http.post(
        Uri.parse(config.url),
        headers: _buildHeaders(provider, ''),
        body: _buildBody(provider, 'test'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Main response generation with automatic fallback
  Future<String> generateResponse(String message) async {
    final apiKey = await _getApiKey();
    if (apiKey.isEmpty) {
      return _getDemoResponse(message);
    }

    // Try providers in order
    List<AIProvider> order = _defaultOrder;
    String? lastError;
    
    for (final provider in order) {
      try {
        final result = await _generateWithProvider(provider, message, apiKey);
        if (result.isNotEmpty && !result.startsWith('❌')) {
          _currentProvider = provider;
          _providerAvailable = true;
          return result;
        }
        lastError = result;
      } catch (e) {
        lastError = e.toString();
      }
    }
    
    // All providers failed, return demo
    return _getDemoResponse(message);
  }

  Future<String> _generateWithProvider(AIProvider provider, String message, String apiKey) async {
    final config = _providers[provider]!;
    
    try {
      String url = config.url;
      if (config.isGemini) {
        url = '${config.url}?key=$apiKey';
      }
      
      final response = await http.post(
        Uri.parse(url),
        headers: config.authHeader.isNotEmpty 
            ? {config.authHeader: '${config.authPrefix}$apiKey', 'Content-Type': 'application/json'}
            : {'Content-Type': 'application/json'},
        body: _buildBodyForProvider(provider, message),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return _parseResponse(provider, response.body);
      } else if (response.statusCode == 429 || response.statusCode == 503) {
        // Rate limited, try next provider
        return '❌ rate_limited';
      } else if (response.statusCode == 401) {
        return '❌ invalid_key';
      }
      return '❌ ${response.statusCode}';
    } catch (e) {
      return '❌ $e';
    }
  }

  Map<String, String> _buildHeaders(AIProvider provider, String apiKey) {
    final config = _providers[provider]!;
    if (config.authHeader.isEmpty) return {};
    return {
      config.authHeader: '${config.authPrefix}$apiKey',
      'Content-Type': 'application/json',
    };
  }

  String _buildBody(AIProvider provider, String message) {
    final config = _providers[provider]!;
    if (config.isGemini) {
      return jsonEncode({
        'contents': [{'parts': [{'text': message}]}],
        'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 256},
      });
    }
    // Groq & OpenRouter use OpenAI format
    return jsonEncode({
      'model': config.model,
      'messages': [
        {'role': 'system', 'content': 'You are NOVA AI, a futuristic AI assistant.'},
        {'role': 'user', 'content': message},
      ],
      'max_tokens': 256,
      'temperature': 0.7,
    });
  }

  String _buildBodyForProvider(AIProvider provider, String message) {
    return _buildBody(provider, message);
  }

  String _parseResponse(AIProvider provider, String responseBody) {
    final data = jsonDecode(responseBody);
    if (provider == AIProvider.gemini) {
      return data['candidates'][0]['content']['parts'][0]['text'] ?? '';
    }
    // Groq & OpenRouter
    return data['choices'][0]['message']['content'] ?? '';
  }

  // Demo fallback responses
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
    } else if (msg.contains('help')) {
      return "I can answer questions, help with tasks, or just chat! Configure your API key in Settings for full AI responses.";
    }
    return "Interesting question! Configure your API key in Settings for full AI responses!";
  }

  // Get provider info
  String getProviderName(AIProvider provider) => _providers[provider]!.name;
  bool isProviderFree(AIProvider provider) => _providers[provider]!.free;
  String getProviderSpeed(AIProvider provider) => _providers[provider]!.speed;
  
  List<AIProvider> get availableProviders => _defaultOrder;
}

class _ProviderConfig {
  final String name;
  final String url;
  final String model;
  final String authHeader;
  final String authPrefix;
  final bool free;
  final String speed;
  
  const _ProviderConfig({
    required this.name,
    required this.url,
    required this.model,
    required this.authHeader,
    required this.authPrefix,
    required this.free,
    required this.speed,
  });
  
  bool get isGemini => name == 'Gemini';
}