import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/neon_text.dart';
import '../widgets/glassmorphic_container.dart';
import '../widgets/chat_bubble.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});
  
  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> with TickerProviderStateMixin {
  bool _isListening = false;
  String _transcript = '';
  bool _hasResult = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _transcript = 'Listening...';
      }
    });
    
    // Simulate listening for 3 seconds
    if (_isListening) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isListening = false;
            _transcript = 'Voice recognition ready!';
            _hasResult = true;
          });
        }
      });
    }
  }

  void _clearTranscript() {
    setState(() {
      _transcript = '';
      _hasResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const NeonText(
          text: 'VOICE',
          fontSize: 20,
          color: AppColors.secondary,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.textSecondary),
            onPressed: _clearTranscript,
          ),
        ],
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
                    FadeIn(child: _buildVoiceAnimation()),
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
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: _buildVoiceCommands(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceAnimation() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isListening ? 1.0 + (_pulseAnimation.value * 0.2) : 1.0,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: _isListening 
                    ? [AppColors.secondary, AppColors.accent]
                    : [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_isListening ? AppColors.secondary : AppColors.primary)
                      .withOpacity(_isListening ? 0.6 : 0.4),
                  blurRadius: _isListening ? 50 : 30,
                  spreadRadius: _isListening ? 15 : 5,
                ),
              ],
            ),
            child: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: Colors.white,
              size: 80,
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
          _isListening ? 'Listening...' : 'Tap to speak',
          style: TextStyle(
            color: _isListening ? AppColors.secondary : AppColors.textSecondary,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _toggleListening,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            decoration: BoxDecoration(
              color: (_isListening ? AppColors.secondary : AppColors.primary).withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: _isListening ? AppColors.secondary : AppColors.primary,
              ),
            ),
            child: Text(
              _isListening ? 'STOP' : 'START',
              style: TextStyle(
                color: _isListening ? AppColors.secondary : AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        if (!_isListening && !_hasResult) ...[
          const SizedBox(height: 12),
          Text(
            'Tap to start voice recognition',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
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
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              if (_transcript.isNotEmpty)
                GestureDetector(
                  onTap: _clearTranscript,
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
            _transcript.isEmpty ? 'Your speech will appear here...' : _transcript,
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

  Widget _buildVoiceCommands() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EXAMPLE COMMANDS',
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        GlassmorphicContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: 20,
          child: Column(
            children: [
              _buildCommandItem('Open browser', Icons.language),
              _buildCommandItem('Set a timer', Icons.timer),
              _buildCommandItem('Send message', Icons.message),
              _buildCommandItem('Play music', Icons.music_note),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommandItem(String command, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              command,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            '"Try it"',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}
