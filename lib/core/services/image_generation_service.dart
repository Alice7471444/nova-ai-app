import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Image generation service for Sketch to Image feature
/// Uses Replicate API as the primary provider with fallback options
class ImageGenerationService {
  // Backend proxy URL - in production this would be your secure server
  static const String _baseUrl = 'https://api.replicate.com';
  
  // API token - in production this should come from backend proxy
  // For demo purposes, we'll use environment variable or placeholder
  String? _apiToken;
  
  bool _isInitialized = false;
  
  /// Initialize the service
  Future<void> init() async {
    // In production, fetch token from secure backend
    // For now, allow manual configuration
    _isInitialized = true;
  }
  
  /// Set API token (for manual configuration if needed)
  void setApiToken(String token) {
    _apiToken = token;
  }
  
  /// Generate image from sketch
  /// [sketchBytes] - PNG image data of the sketch
  /// [prompt] - Optional description to guide generation
  /// [strength] - How much to transform the sketch (0-1)
  Future<ImageGenerationResult> generateFromSketch({
    required Uint8List sketchBytes,
    String? prompt,
    double strength = 0.7,
  }) async {
    try {
      // Convert sketch to base64
      final sketchBase64 = base64Encode(sketchBytes);
      
      // Use Replicate API for image-to-image generation
      // Using stable-diffusion-ultra model for high-quality results
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/predictions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $_apiToken',
        },
        body: jsonEncode({
          'version': 'stability-ai/stable-diffusion-2-1',
          'input': {
            'image': 'data:image/png;base64,$sketchBase64',
            'prompt': prompt ?? 'Transform this sketch into a beautiful detailed artwork',
            'guidance_scale': 7.5,
            'num_inference_steps': 50,
            'strength': strength,
          },
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ImageGenerationResult(
          success: true,
          imageUrl: data['output']?['url'] ?? '',
          message: 'Image generated successfully',
        );
      } else {
        return ImageGenerationResult(
          success: false,
          imageUrl: '',
          message: 'Generation failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ImageGenerationResult(
        success: false,
        imageUrl: '',
        message: 'Error: $e',
      );
    }
  }
  
  /// Generate using Hugging Face Inference API (fallback)
  Future<ImageGenerationResult> generateWithHuggingFace({
    required Uint8List sketchBytes,
    String? prompt,
  }) async {
    try {
      final sketchBase64 = base64Encode(sketchBytes);
      
      // Use Hugging Face image-to-image API
      final response = await http.post(
        Uri.parse('https://api-inference.huggingface.co/models/runwayml/stable-diffusion-v1-5'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiToken',
        },
        body: jsonEncode({
          'inputs': {
            'image': sketchBase64,
            'prompt': prompt ?? 'Beautiful detailed artwork',
          },
        }),
      );
      
      if (response.statusCode == 200) {
        return ImageGenerationResult(
          success: true,
          imageUrl: 'data:image/png;base64,${base64Encode(response.bodyBytes)}',
          message: 'Image generated successfully',
        );
      } else {
        return ImageGenerationResult(
          success: false,
          imageUrl: '',
          message: 'Hugging Face generation failed',
        );
      }
    } catch (e) {
      return ImageGenerationResult(
        success: false,
        imageUrl: '',
        message: 'Error: $e',
      );
    }
  }
  
  /// Simple prompt-based generation (no sketch)
  Future<ImageGenerationResult> generateFromPrompt(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/predictions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $_apiToken',
        },
        body: jsonEncode({
          'version': 'stability-ai/stable-diffusion-xl-base-1.0',
          'input': {
            'prompt': prompt,
            'guidance_scale': 7.5,
            'num_inference_steps': 50,
          },
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ImageGenerationResult(
          success: true,
          imageUrl: data['output']?[0] ?? '',
          message: 'Image generated successfully',
        );
      } else {
        return ImageGenerationResult(
          success: false,
          imageUrl: '',
          message: 'Generation failed',
        );
      }
    } catch (e) {
      return ImageGenerationResult(
        success: false,
        imageUrl: '',
        message: 'Error: $e',
      );
    }
  }
  
  /// Check if service is ready
  bool get isReady => _isInitialized && (_apiToken?.isNotEmpty ?? false);
}

/// Result of image generation
class ImageGenerationResult {
  final bool success;
  final String imageUrl;
  final String message;
  final Uint8List? imageBytes;
  
  ImageGenerationResult({
    required this.success,
    required this.imageUrl,
    required this.message,
    this.imageBytes,
  });
}