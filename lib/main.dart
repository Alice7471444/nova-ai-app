import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/services/ai_service.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/chat_screen.dart';
import 'presentation/screens/voice_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/widgets/neon_text.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.background,
  ));
  
  runApp(const NovaAIApp());
}

class NovaAIApp extends StatelessWidget {
  const NovaAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NOVA AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = AIService();
      if (service.isConfigured == false) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _showApiKeyDialog();
        });
      }
    });
  }

  void _showApiKeyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ApiKeyDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = const [
      HomeScreen(),
      ChatScreen(),
      VoiceScreen(),
      SettingsScreen(),
    ];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: screens[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, 'Home', 0),
          _navItem(Icons.chat_bubble, 'Chat', 1),
          _navItem(Icons.mic, 'Voice', 2),
          _navItem(Icons.settings, 'Settings', 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () { setState(() => _currentIndex = index); HapticFeedback.mediumImpact(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1.0, end: 1.2),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: AppColors.primaryGradient),
                            ),
                            child: Icon(icon, color: Colors.white, size: 20),
                          ),
                        );
                      },
                    )
                  : Icon(icon, color: Colors.white.withOpacity(0.5), size: 22),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : Colors.white.withOpacity(0.5))),
          ],
        ),
      ),
    );
  }
}

class _ApiKeyDialog extends StatefulWidget {
  const _ApiKeyDialog({super.key});

  @override
  State<_ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<_ApiKeyDialog> {
  final _controller = TextEditingController();
  String _provider = 'Groq';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome to NOVA AI', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Enter your API key to get started.', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 20),
            const Text('Provider', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 8),
            Row(children: [
              _chip('Groq'), const SizedBox(width: 8),
              _chip('Gemini'), const SizedBox(width: 8),
              _chip('OpenRouter'),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: 'API key...', hintStyle: TextStyle(color: Colors.white38), border: InputBorder.none),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Get free keys: console.groq.com', style: TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Get Started', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String name) {
    final sel = _provider == name;
    return GestureDetector(
      onTap: () => setState(() => _provider = name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: sel ? AppColors.primary : Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
        child: Text(name, style: TextStyle(color: sel ? Colors.white : Colors.white70, fontSize: 13)),
      ),
    );
  }

  Future<void> _save() async {
    if (_controller.text.isEmpty) return;
    final service = AIService();
    await service.setApiKey(_controller.text);
    await service.setProvider(AIProvider.values.firstWhere((p) => p.name.toLowerCase() == _provider.toLowerCase()));
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }
}
