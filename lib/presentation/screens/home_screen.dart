import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/ai_service.dart';
import 'sketch_to_image_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final AIService aiService;
  final AuthService authService;
  
  const HomeScreen({super.key, required this.aiService, required this.authService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _uuid = const Uuid();
  int _currentTab = 0;
  final _messages = <_Message>[];
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addWelcome();
  }

  void _addWelcome() {
    _messages.add(_Message(
      id: _uuid.v4(),
      content: "Hey! I'm NOVA AI. How can I help you today?",
      isUser: false,
    ));
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    _controller.clear();
    HapticFeedback.lightImpact();
    
    _messages.add(_Message(id: _uuid.v4(), content: text, isUser: true));
    setState(() => _isTyping = true);
    _scroll();
    
    final response = await widget.aiService.generateResponse(text);
    
    setState(() {
      _messages.add(_Message(id: _uuid.v4(), content: response, isUser: false));
      _isTyping = false;
    });
    
    _scroll();
  }

  void _scroll() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SettingsSheet(authService: widget.authService),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: IndexedStack(index: _currentTab, children: [_chatTab(), _discoverTab(), _settingsTab(), const SketchToImageScreen()]),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: AppColors.primaryGradient),
          ),
          child: const Center(
            child: Text('N', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        const Text('NOVA AI', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      ]),
      actions: [
        IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: _showSettings),
      ],
    );
  }

  Widget _chatTab() {
    return Column(children: [
      Expanded(
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: _messages.length + (_isTyping ? 1 : 0),
          itemBuilder: (ctx, i) {
            if (_isTyping && i == _messages.length) return _typingIndicator();
            return _buildMessage(_messages[i]);
          },
        ),
      ),
      _buildInput(),
    ]);
  }

  Widget _buildMessage(_Message msg) {
    return FadeInUp(
      key: ValueKey(msg.id),
      child: Align(
        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: msg.isUser ? AppColors.primary : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(msg.content, style: const TextStyle(color: Colors.white, fontSize: 15)),
        ),
      ),
    );
  }

  Widget _typingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
          child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) => _dot(i))),
        ),
      ]),
    );
  }

  Widget _dot(int i) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + i * 200),
      builder: (ctx, v, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 6, height: 6,
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.3 + v * 0.7), shape: BoxShape.circle),
        );
      },
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(24)),
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Message NOVA AI...',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _send,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.send, color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }

  Widget _discoverTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Discover', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Explore AI features', style: TextStyle(color: Colors.white.withOpacity(0.5))),
        const SizedBox(height: 24),
        _featureCard('Voice AI', 'Talk to NOVA', Icons.mic, Colors.blue),
        const SizedBox(height: 12),
        _featureCard('Image Gen', 'Create images', Icons.image, Colors.purple),
        const SizedBox(height: 12),
        _featureCard('Code Assist', 'Get coding help', Icons.code, Colors.green),
      ]),
    );
  }

  Widget _featureCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
        ])),
        const Icon(Icons.chevron_right, color: Colors.white38),
      ]),
    );
  }

  Widget _settingsTab() {
    return SettingsScreen(authService: widget.authService);
  }

  Widget _settingItem(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.white38),
        ]),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.chat_bubble, 'Chat', 0),
          _navItem(Icons.brush, 'Sketch', 3),
          _navItem(Icons.explore, 'Discover', 1),
          _navItem(Icons.settings, 'Settings', 2),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = _currentTab == index;
    return GestureDetector(
      onTap: () { setState(() => _currentTab = index); HapticFeedback.mediumImpact(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 8, vertical: 8),
        decoration: isSelected
            ? const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryGradient),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              )
            : null,
        child: Row(children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.white54, size: 20),
          if (isSelected) ...[
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ]),
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to sign out?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign Out', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await widget.authService.signOut();
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (_) => true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _Message {
  final String id;
  final String content;
  final bool isUser;
  _Message({required this.id, required this.content, required this.isUser});
}

class _SettingsSheet extends StatelessWidget {
  final AuthService authService;
  const _SettingsSheet({required this.authService});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 24),
        const Text('Quick Settings', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        _sheetItem('Dark Mode', Icons.dark_mode, true),
        _sheetItem('Notifications', Icons.notifications, true),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (_) => true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ),
      ]),
    );
  }

  Widget _sheetItem(String title, IconData icon, bool value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Icon(icon, color: Colors.white70),
        const SizedBox(width: 16),
        Text(title, style: const TextStyle(color: Colors.white)),
        const Spacer(),
        Switch(value: value, onChanged: (_) {}, activeColor: AppColors.primary),
      ]),
    );
  }
}