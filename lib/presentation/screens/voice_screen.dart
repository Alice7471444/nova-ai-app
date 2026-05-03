import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glassmorphic_container.dart';
import 'chat_screen.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> with TickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechEnabled = false;
  String _transcript = '';
  String _lastWords = '';
  String _status = 'Tap to start';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initSpeech() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      _speechEnabled = await _speech.initialize(
        onStatus: (status) {
          if (mounted) {
            setState(() {
              _status = status == 'done' ? 'Tap to start' : status;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _status = 'Error: ${error.errorMsg}';
              _isListening = false;
            });
          }
        },
      );
      if (mounted) setState(() {});
    } else {
      setState(() {
        _status = 'Microphone permission denied';
        _speechEnabled = false;
      });
    }
  }

  void _startListening() async {
    if (!_speechEnabled) {
      await _initSpeech();
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _isListening = true;
      _transcript = '';
    });
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _transcript = result.recognizedWords;
          if (result.finalResult) {
            _isListening = false;
            _lastWords = _transcript;
          }
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
    );
  }

  void _stopListening() async {
    HapticFeedback.lightImpact();
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _onMicTap() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _sendToChat() {
    if (_transcript.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(initialMessage: _transcript),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Voice',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeIn(child: _buildMicButton()),
                    const SizedBox(height: 40),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: _buildStatus(),
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: _buildTranscript(),
                    ),
                  ],
                ),
              ),
              if (_transcript.isNotEmpty)
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: _buildSendButton(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: _onMicTap,
          child: Transform.scale(
            scale: _isListening ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isListening
                      ? [AppColors.primary, AppColors.accent]
                      : [_speechEnabled ? AppColors.primary : AppColors.textTertiary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isListening ? AppColors.primary : (_speechEnabled ? AppColors.primary : Colors.grey))
                        .withOpacity(0.4),
                    blurRadius: _isListening ? 40 : 20,
                    spreadRadius: _isListening ? 10 : 2,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: Colors.white,
                size: 64,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatus() {
    return Column(
      children: [
        Text(
          _isListening ? 'Listening...' : _status,
          style: TextStyle(
            color: _isListening ? AppColors.primary : AppColors.textSecondary,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _speechEnabled ? 'Tap microphone to speak' : 'Tap to enable voice',
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTranscript() {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 20,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TRANSCRIPT',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              if (_transcript.isNotEmpty)
                GestureDetector(
                  onTap: () => setState(() => _transcript = ''),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.textTertiary,
                    size: 18,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _transcript.isEmpty
                ? 'Your speech will appear here...'
                : _transcript,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _transcript.isEmpty ? AppColors.textHint : AppColors.textPrimary,
              fontSize: 18,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return GestureDetector(
      onTap: _sendToChat,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Send to Chat',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _pulseController.dispose();
    super.dispose();
  }
}
