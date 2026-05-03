import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/neon_text.dart';
import '../widgets/glassmorphic_container.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});
  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> with TickerProviderStateMixin {
  bool _isListening = false;
  String _transcript = '';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(duration: const Duration(seconds: 1), vsync: this)..repeat(reverse: true);
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      _transcript = _isListening ? 'Listening...' : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const NeonText(text: 'VOICE ASSISTANT', fontSize: 20, color: AppColors.secondary), centerTitle: true),
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          FadeIn(child: _buildVoiceAnimation()),
          const SizedBox(height: 40),
          FadeInUp(delay: const Duration(milliseconds: 200), child: _buildStatus()),
          const SizedBox(height: 20),
          FadeInUp(delay: const Duration(milliseconds: 400), child: _buildTranscript()),
        ])),
        FadeInUp(delay: const Duration(milliseconds: 600), child: _buildVoiceCommands()),
      ],))),
    );
  }

  Widget _buildVoiceAnimation() {
    return AnimatedBuilder(animation: _pulseController, builder: (context, child) {
      return Transform.scale(
        scale: _isListening ? 1.0 + (_pulseController.value * 0.3) : 1.0,
        child: Container(
          width: 180, height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: _isListening ? [AppColors.secondary, AppColors.accent] : [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
            boxShadow: [BoxShadow(color: (_isListening ? AppColors.secondary : AppColors.primary).withOpacity(0.5), blurRadius: _isListening ? 40 : 30, spreadRadius: _isListening ? 10 : 5)],
          ),
          child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.white, size: 80),
        ),
      );
    });
  }

  Widget _buildStatus() {
    return Column(children: [
      Text(_isListening ? 'Listening...' : 'Tap to speak', style: TextStyle(color: _isListening ? AppColors.secondary : AppColors.textSecondary, fontSize: 18, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: _toggleListening,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(30), border: Border.all(color: AppColors.primary)),
          child: Text(_isListening ? 'STOP' : 'START', style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
        ),
      ),
    ]);
  }

  Widget _buildTranscript() {
    return GlassmorphicContainer(padding: const EdgeInsets.all(24), borderRadius: 20, child: Column(children: [
      const Text('TRANSCRIPT', style: TextStyle(color: AppColors.textTertiary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
      const SizedBox(height: 16),
      Text(_transcript.isEmpty ? 'Your speech will appear here...' : _transcript, textAlign: TextAlign.center, style: TextStyle(color: _transcript.isEmpty ? AppColors.textHint : AppColors.textPrimary, fontSize: 18, height: 1.5)),
    ]));
  }

  Widget _buildVoiceCommands() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('VOICE COMMANDS', style: TextStyle(color: AppColors.textTertiary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
      const SizedBox(height: 16),
      GlassmorphicContainer(padding: const EdgeInsets.all(20), borderRadius: 20, child: Column(children: [
        _buildCommandItem('Open browser', 'OK'),
        _buildCommandItem('Set a timer', 'OK'),
        _buildCommandItem('Send message', 'OK'),
      ])),
    ]);
  }

  Widget _buildCommandItem(String command, String response) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [
      Icon(Icons.record_voice_over, color: AppColors.secondary, size: 20),
      const SizedBox(width: 12),
      Expanded(child: Text(command, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16))),
      Text('"' + response + '"', style: TextStyle(color: AppColors.textTertiary, fontSize: 14)),
    ]));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}
