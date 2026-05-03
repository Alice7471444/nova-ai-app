import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/ai_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final AuthService authService;
  
  const OnboardingScreen({super.key, required this.authService});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.auto_awesome,
      title: 'Meet NOVA AI',
      description: 'Your intelligent AI companion powered by advanced language models. Ask anything, create anything.',
      color: const Color(0xFF667EEA),
    ),
    OnboardingPage(
      icon: Icons.brush,
      title: 'Sketch to Image',
      description: 'Draw your ideas and watch them transform into stunning AI-generated artwork.',
      color: const Color(0xFFF093FB),
    ),
    OnboardingPage(
      icon: Icons.mic,
      title: 'Voice Assistant',
      description: 'Speak naturally and get instant responses. Your voice is now your controller.',
      color: const Color(0xFF4ECDC4),
    ),
    OnboardingPage(
      icon: Icons.bolt,
      title: 'Instant Results',
      description: 'Lightning-fast responses with automatic provider switching. Always get the best AI.',
      color: const Color(0xFFFFD93D),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _goHome();
    }
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(aiService: AIService(), authService: widget.authService)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildSkipButton(),
            Expanded(child: _buildPageView()),
            _buildIndicators(),
            const SizedBox(height: 32),
            _buildNextButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.topRight,
      child: TextButton(
        onPressed: _goHome,
        child: Text('Skip', style: TextStyle(color: Colors.white.withOpacity(0.5))),
      ),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (page) => setState(() => _currentPage = page),
      itemCount: _pages.length,
      itemBuilder: (context, index) => _buildPage(_pages[index]),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [page.color, page.color.withOpacity(0.5)]),
                boxShadow: [BoxShadow(color: page.color.withOpacity(0.4), blurRadius: 40)],
              ),
              child: Icon(page.icon, color: Colors.white, size: 80),
            ),
          ),
          const SizedBox(height: 64),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              page.title,
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: Text(
              page.description,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index 
              ? _pages[index].color 
              : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildNextButton() {
    final isLast = _currentPage == _pages.length - 1;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _nextPage();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_pages[_currentPage].color, _pages[_currentPage].color.withOpacity(0.7)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            isLast ? 'Get Started' : 'Next',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  
  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
