import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../widgets/glassmorphic_container.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final AuthService authService;
  
  const SettingsScreen({super.key, required this.authService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hapticFeedback = true;
  bool _soundEffects = true;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hapticFeedback = prefs.getBool('haptic') ?? true;
      _soundEffects = prefs.getBool('sound') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptic', _hapticFeedback);
    await prefs.setBool('sound', _soundEffects);
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
        title: const Text('Settings', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeIn(child: _buildProfileSection()),
            const SizedBox(height: 32),
            FadeInUp(child: _buildSection('Experience')),
            _settingsTile(
              icon: Icons.vibration,
              title: 'Haptic Feedback',
              subtitle: 'Feel the response',
              trailing: Switch(
                value: _hapticFeedback,
                activeColor: AppColors.primary,
                onChanged: (v) { setState(() => _hapticFeedback = v); _saveSettings(); },
              ),
            ),
            _settingsTile(
              icon: Icons.volume_up,
              title: 'Sound Effects',
              subtitle: 'Play sounds',
              trailing: Switch(
                value: _soundEffects,
                activeColor: AppColors.primary,
                onChanged: (v) { setState(() => _soundEffects = v); _saveSettings(); },
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(child: _buildSection('About')),
            _settingsTile(icon: Icons.info_outline, title: 'Version', subtitle: '3.3.0'),
            _settingsTile(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', subtitle: 'Learn more'),
            _settingsTile(icon: Icons.description_outlined, title: 'Terms of Service', subtitle: 'Read terms'),
            const SizedBox(height: 32),
            FadeInUp(child: _buildLogoutButton()),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    final user = widget.authService.currentUser;
    return GlassmorphicContainer(
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: AppColors.primaryGradient),
            ),
            child: user?.photoUrl != null
                ? ClipOval(child: Image.network(user!.photoUrl!, fit: BoxFit.cover))
                : Center(child: Text(user?.name.substring(0, 1).toUpperCase() ?? 'U', 
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.name ?? 'User', style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(user?.email ?? '', style: const TextStyle(color: AppColors.textTertiary, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }

  Widget _settingsTile({required IconData icon, required String title, String? subtitle, Widget? trailing}) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                if (subtitle != null) Text(subtitle, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _logout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: const Center(
          child: Text('Sign Out', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await widget.authService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen(authService: AuthService())),
        (route) => false,
      );
    }
  }
}
