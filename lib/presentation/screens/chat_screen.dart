import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/ai_service.dart';
import '../widgets/glassmorphic_container.dart';

class ChatMessage {
  final String id;
  final String content;
  final DateTime timestamp;
  final String type;

  ChatMessage({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.type,
  });
}

class ChatScreen extends StatefulWidget {
  final String? initialMessage;
  
  const ChatScreen({super.key, this.initialMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final AIService _aiService = AIService();
  final Uuid _uuid = const Uuid();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _welcomeMessage();
    
    // Handle initial message from voice
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Set the message and send
        _messageController.text = widget.initialMessage!;
        _sendMessage();
      });
    }
  }

  void _welcomeMessage() {
    _messages.add(ChatMessage(
      id: _uuid.v4(),
      content: "Hello! I'm NOVA AI. How can I assist you today?",
      timestamp: DateTime.now(),
      type: 'ai',
    ));
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        id: _uuid.v4(),
        content: text,
        timestamp: DateTime.now(),
        type: 'user',
      ));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    final responseContent = await _aiService.generateResponse(text);
    
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: responseContent.toString(),
        timestamp: DateTime.now(),
        type: 'ai',
      ));
      _isTyping = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList()),
          _buildInputArea(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: FadeIn(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.primaryGradient),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('NOVA AI', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ],
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isTyping && index == _messages.length) {
          return FadeIn(child: _buildTypingIndicator());
        }
        return FadeInUp(
          key: ValueKey(_messages[index].id),
          child: _buildMessageBubble(_messages[index]),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.type == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: isUser ? const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
          color: isUser ? null : AppColors.surface.withOpacity(0.7),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20), topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4), bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          border: isUser ? null : Border.all(color: AppColors.glassPrimary),
          boxShadow: [BoxShadow(color: isUser ? AppColors.primary.withOpacity(0.3) : Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.content, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, height: 1.4)),
            const SizedBox(height: 6),
            Text('${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}', style: TextStyle(color: AppColors.textPrimary.withOpacity(0.6), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.7),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(4), bottomRight: Radius.circular(20)),
        border: Border.all(color: AppColors.glassPrimary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return Container(margin: const EdgeInsets.symmetric(horizontal: 3), width: 8, height: 8, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)));
        }),
      ),
    );
  }

  Widget _buildInputArea() {
    return GlassmorphicContainer(
      borderRadius: 0,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(hintText: 'Type a message...', hintStyle: TextStyle(color: AppColors.textHint), border: InputBorder.none, filled: true, fillColor: AppColors.glassWhite, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return GestureDetector(
      onTap: _sendMessage,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.primaryGradient),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
