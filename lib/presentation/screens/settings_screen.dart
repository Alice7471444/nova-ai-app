import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/ai_service.dart';
import '../widgets/glassmorphic_container.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AIService _aiService = AIService();
  final TextEditingController _apiKeyController = TextEditingController();
  String _selectedProvider = 'Groq';
  bool _gamingMode = false;
  bool _hapticFeedback = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load saved settings
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
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeIn(child: _buildProfileSection()),
            const SizedBox(height: 24),
            FadeInUp(delay: const Duration(milliseconds: 100), child: _buildAIKeysSection()),
            const SizedBox(height: 24),
            FadeInUp(delay: const Duration(milliseconds: 200), child: _buildAppearanceSection()),
            const SizedBox(height: 24),
            FadeInUp(delay: const Duration(milliseconds: 300), child: _buildVoiceSection()),
            const SizedBox(height: 24),
            FadeInUp(delay: const Duration(milliseconds: 400), child: _buildAboutSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.primaryGradient),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOVA User',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Premium Member',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIKeysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI SETTINGS',
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        GlassmorphicContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: 20,
          child: Column(
            children: [
              _buildSettingRow(
                icon: Icons.key,
                title: 'API Key',
                subtitle: 'Configure AI providers',
                onTap: _showApiKeyDialog,
              ),
              const Divider(color: AppColors.textTertiary, height: 24),
              _buildSettingRow(
                icon: Icons.auto_awesome,
                title: 'AI Provider',
                subtitle: _selectedProvider,
                onTap: _showProviderDialog,
              ),
              const Divider(color: AppColors.textTertiary, height: 24),
              _buildToggleRow(
                icon: Icons.hardware,
                title: 'Gaming Mode',
                value: _gamingMode,
                onChanged: (v) => setState(() => _gamingMode = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'APPEARANCE',
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        GlassmorphicContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: 20,
          child: Column(
            children: [
              _buildToggleRow(
                icon: Icons.vibration,
                title: 'Haptic Feedback',
                value: _hapticFeedback,
                onChanged: (v) => setState(() => _hapticFeedback = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'VOICE',
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        GlassmorphicContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: 20,
          child: Column(
            children: [
              _buildSettingRow(
                icon: Icons.mic,
                title: 'Voice Settings',
                subtitle: 'Configure speech recognition',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ABOUT',
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        GlassmorphicContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: 20,
          child: Column(
            children: [
              _buildSettingRow(
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: '2.1.0',
                onTap: () {},
              ),
              const Divider(color: AppColors.textTertiary, height: 24),
              _buildSettingRow(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Read our policy',
                onTap: () {},
              ),
              const Divider(color: AppColors.textTertiary, height: 24),
              _buildSettingRow(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'Read terms',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: (v) {
            HapticFeedback.lightImpact();
            onChanged(v);
          },
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  void _showApiKeyDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('API Key', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _apiKeyController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Enter API key...',
                hintStyle: TextStyle(color: AppColors.textTertiary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.textTertiary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Get free keys: Groq, Gemini, OpenRouter',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _aiService.setApiKey(_apiKeyController.text);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API key saved!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showProviderDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('AI Provider', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _providerOption('Groq', 'Fastest'),
            _providerOption('Gemini', 'Google AI'),
            _providerOption('OpenRouter', 'Multiple models'),
          ],
        ),
      ),
    );
  }

  Widget _providerOption(String name, String desc) {
    return ListTile(
      title: Text(name, style: TextStyle(color: AppColors.textPrimary)),
      subtitle: Text(desc, style: TextStyle(color: AppColors.textTertiary)),
      trailing: _selectedProvider == name
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () {
        setState(() => _selectedProvider = name);
        Navigator.pop(context);
      },
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}
