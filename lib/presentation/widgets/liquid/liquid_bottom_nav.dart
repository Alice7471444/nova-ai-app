import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

/// Liquid glass bottom navigation with wobble effect
class LiquidBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const LiquidBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<LiquidBottomNav> createState() => _LiquidBottomNavState();
}

class _LiquidBottomNavState extends State<LiquidBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _wobbleController;
  int _lastIndex = 0;

  final items = [
    {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home'},
    {'icon': Icons.chat_bubble_outline, 'activeIcon': Icons.chat_bubble, 'label': 'Chat'},
    {'icon': Icons.mic_outlined, 'activeIcon': Icons.mic, 'label': 'Voice'},
    {'icon': Icons.settings_outlined, 'activeIcon': Icons.settings, 'label': 'Settings'},
  ];

  @override
  void initState() {
    super.initState();
    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didUpdateWidget(LiquidBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != _lastIndex) {
      _wobbleController.forward(from: 0);
      _lastIndex = widget.currentIndex;
    }
  }

  @override
  void dispose() {
    _wobbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          return _NavItem(
            icon: items[index]['icon'] as IconData,
            activeIcon: items[index]['activeIcon'] as IconData,
            label: items[index]['label'] as String,
            isActive: widget.currentIndex == index,
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onTap(index);
            },
          );
        }),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _scaleController.forward().then((_) => _scaleController.reverse());
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.isActive
                        ? AppColors.primary.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    widget.isActive ? widget.activeIcon : widget.icon,
                    color: widget.isActive
                        ? AppColors.primary
                        : AppColors.textTertiary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: widget.isActive
                        ? AppColors.primary
                        : AppColors.textTertiary,
                    fontSize: 11,
                    fontWeight: widget.isActive
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  child: Text(widget.label),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
