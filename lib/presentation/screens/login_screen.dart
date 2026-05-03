import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/ai_service.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;

  const LoginScreen({super.key, required this.authService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Check for existing session and auto-login
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSession());
  }

  Future<void> _checkSession() async {
    await widget.authService.init();
    if (widget.authService.isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => HomeScreen(aiService: AIService(), authService: widget.authService)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeInDown(child: _buildLogo()),
                    const SizedBox(height: 48),
                    FadeInUp(delay: const Duration(milliseconds: 200), child: _buildTitle()),
                    const SizedBox(height: 16),
                    FadeInUp(delay: const Duration(milliseconds: 300), child: _buildSubtitle()),
                    const SizedBox(height: 64),
                    FadeInUp(delay: const Duration(milliseconds: 400), child: _buildGoogleButton()),
                    const SizedBox(height: 16),
                    FadeInUp(delay: const Duration(milliseconds: 500), child: _buildOnboardingButton()),
                  ],
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120, height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: AppColors.primaryGradient),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 30),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('NOVA', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            Text('AI', style: TextStyle(color: AppColors.accent, fontSize: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Welcome to NOVA AI',
      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Your futuristic AI assistant is ready.\nSign in to get started.',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, height: 1.5),
    );
  }

  Widget _buildGoogleButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _signIn,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.black))
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.g_mobiledata, color: Colors.black, size: 32),
                  SizedBox(width: 12),
                  Text('Continue with Google', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }

  Widget _buildOnboardingButton() {
    return TextButton(
      onPressed: _goOnboarding,
      child: Text('Take a Tour', style: TextStyle(color: Colors.white.withOpacity(0.5))),
    );
  }

  Widget _buildFooter() {
    return Text(
      'By continuing, you agree to our Terms of Service',
      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
    );
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    final success = await widget.authService.signInWithGoogle();

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => HomeScreen(aiService: AIService(), authService: widget.authService)),
        );
      }
    }
  }

  void _goOnboarding() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => OnboardingScreen(authService: widget.authService)));
  }
}
