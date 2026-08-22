import 'dart:math';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../screens/badges_screen.dart';
import '../theme/app_theme.dart';

extension BadgeDetailExtensions on BadgeData {
  String get rarity {
    switch (id) {
      case 'first_step': return 'COMMON';
      case 'getting_serious': return 'UNCOMMON';
      case 'dedicated': return 'RARE';
      case 'unstoppable': return 'EPIC';
      case 'habit_master': return 'LEGENDARY';
      case 'momentum': return 'COMMON';
      case 'consistency': return 'UNCOMMON';
      case 'habit_lifestyle': return 'RARE';
      case 'streak_starter': return 'COMMON';
      case 'one_week': return 'UNCOMMON';
      case 'one_month': return 'RARE';
      case 'two_months': return 'EPIC';
      case 'half_year': return 'LEGENDARY';
      case 'perfect_day': return 'COMMON';
      case 'flawless_week': return 'UNCOMMON';
      case 'flawless_month': return 'RARE';
      case 'centurion': return 'EPIC';
      case 'weekend_warrior': return 'UNCOMMON';
      case 'overachiever': return 'RARE';
      default: return 'COMMON';
    }
  }

  int get xpReward {
    switch (id) {
      case 'first_step': return 50;
      case 'getting_serious': return 150;
      case 'dedicated': return 300;
      case 'unstoppable': return 500;
      case 'habit_master': return 1000;
      case 'momentum': return 100;
      case 'consistency': return 350;
      case 'habit_lifestyle': return 500;
      case 'streak_starter': return 100;
      case 'one_week': return 200;
      case 'one_month': return 450;
      case 'two_months': return 600;
      case 'half_year': return 1200;
      case 'perfect_day': return 50;
      case 'flawless_week': return 200;
      case 'flawless_month': return 500;
      case 'centurion': return 800;
      case 'weekend_warrior': return 250;
      case 'overachiever': return 300;
      default: return 100;
    }
  }

  String get masteryTier {
    switch (id) {
      case 'first_step': return 'BRONZE TIER';
      case 'getting_serious': return 'SILVER TIER';
      case 'dedicated': return 'GOLD TIER';
      case 'unstoppable': return 'PLATINUM TIER';
      case 'habit_master': return 'DIAMOND TIER';
      case 'momentum': return 'BRONZE TIER';
      case 'consistency': return 'SILVER TIER';
      case 'habit_lifestyle': return 'GOLD TIER';
      case 'streak_starter': return 'BRONZE TIER';
      case 'one_week': return 'SILVER TIER';
      case 'one_month': return 'GOLD TIER';
      case 'two_months': return 'PLATINUM TIER';
      case 'half_year': return 'DIAMOND TIER';
      case 'perfect_day': return 'BRONZE TIER';
      case 'flawless_week': return 'SILVER TIER';
      case 'flawless_month': return 'GOLD TIER';
      case 'centurion': return 'PLATINUM TIER';
      case 'weekend_warrior': return 'SILVER TIER';
      case 'overachiever': return 'GOLD TIER';
      default: return 'BRONZE TIER';
    }
  }

  String get badgePillText {
    switch (id) {
      case 'first_step': return '1 COMP';
      case 'getting_serious': return '50 COMP';
      case 'dedicated': return '100 COMP';
      case 'unstoppable': return '500 COMP';
      case 'habit_master': return '1000 COMP';
      case 'momentum': return '3 DAYS';
      case 'consistency': return '14 DAYS';
      case 'habit_lifestyle': return '50 DAYS';
      case 'streak_starter': return '3 DAYS';
      case 'one_week': return '7 DAYS';
      case 'one_month': return '30 DAYS';
      case 'two_months': return '60 DAYS';
      case 'half_year': return '180 DAYS';
      case 'perfect_day': return '1 DAY';
      case 'flawless_week': return '7 DAYS';
      case 'flawless_month': return '30 DAYS';
      case 'centurion': return '100 DAYS';
      case 'weekend_warrior': return '10 WKND';
      case 'overachiever': return '5 COMP';
      default: return '';
    }
  }
}

class ConfettiParticle {
  final double top;
  final double left;
  final double size;
  final Color color;
  final double rotation;
  final bool isCircle;

  const ConfettiParticle({
    required this.top,
    required this.left,
    required this.size,
    required this.color,
    required this.rotation,
    required this.isCircle,
  });
}

class AchievementUnlockedDialog extends StatefulWidget {
  final BadgeData badge;

  const AchievementUnlockedDialog({super.key, required this.badge});

  static Future<void> show(BuildContext context, BadgeData badge) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => AchievementUnlockedDialog(badge: badge),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: curve,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<AchievementUnlockedDialog> createState() => _AchievementUnlockedDialogState();
}

class _AchievementUnlockedDialogState extends State<AchievementUnlockedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const List<ConfettiParticle> _particles = [
    ConfettiParticle(top: 40, left: 16, size: 8, color: Colors.amber, rotation: 0.2, isCircle: false),
    ConfettiParticle(top: 90, left: 10, size: 6, color: Color(0xFFC084FC), rotation: 0.5, isCircle: true),
    ConfettiParticle(top: 170, left: 20, size: 10, color: Color(0xFF60A5FA), rotation: -0.4, isCircle: false),
    ConfettiParticle(top: 230, left: 8, size: 7, color: Color(0xFF34D399), rotation: 0.1, isCircle: true),
    ConfettiParticle(top: 290, left: 18, size: 9, color: Color(0xFFF87171), rotation: 0.6, isCircle: false),
    
    ConfettiParticle(top: 50, left: 296, size: 7, color: Color(0xFFF87171), rotation: -0.3, isCircle: true),
    ConfettiParticle(top: 110, left: 290, size: 10, color: Colors.amber, rotation: 0.8, isCircle: false),
    ConfettiParticle(top: 180, left: 300, size: 6, color: Color(0xFF60A5FA), rotation: 0.2, isCircle: true),
    ConfettiParticle(top: 240, left: 288, size: 8, color: Color(0xFFC084FC), rotation: -0.6, isCircle: false),
    ConfettiParticle(top: 300, left: 294, size: 7, color: Color(0xFF34D399), rotation: -0.1, isCircle: true),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const dialogBgColor = Color(0xFF0C0C12);
    final rarityColor = widget.badge.rarity == 'LEGENDARY' 
        ? Colors.amber 
        : (widget.badge.rarity == 'EPIC' ? const Color(0xFFC084FC) : const Color(0xFF8B5CF6));

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main Container
          Container(
            width: 328,
            decoration: BoxDecoration(
              color: dialogBgColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Top Achievement Unlocked Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1035),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD97706).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        color: Color(0xFFF59E0B),
                        size: 13,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'ACHIEVEMENT UNLOCKED!',
                        style: TextStyle(
                          color: Color(0xFFF59E0B),
                          fontWeight: FontWeight.w900,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 2. Badge Display Stack
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Outer Soft purple glow
                    Container(
                      width: 114,
                      height: 114,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                            blurRadius: 28,
                            spreadRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    // Main Gradient Badge Box
                    Container(
                      width: 106,
                      height: 106,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Icon(
                          // Show lightning bolt for consistency/Momentum Builder, else badge icon
                          widget.badge.id == 'consistency' ? PhosphorIconsFill.lightning : widget.badge.icon,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                    // Gold star overlapping top-right corner
                    const Positioned(
                      top: -8,
                      right: -8,
                      child: Icon(
                        Icons.star_rounded,
                        color: Color(0xFFF59E0B),
                        size: 28,
                      ),
                    ),
                    // Small dark pill near the bottom of the badge
                    if (widget.badge.badgePillText.isNotEmpty)
                      Positioned(
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            widget.badge.badgePillText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 28),

                // 3. Rarity & XP Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.badge.rarity,
                      style: TextStyle(
                        color: rarityColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppTheme.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${widget.badge.xpReward} XP',
                      style: const TextStyle(
                        color: Color(0xFFF59E0B),
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 4. Achievement Name
                Text(
                  widget.badge.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // 5. Description
                Text(
                  widget.badge.description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                // 6. Mastery Tier Info Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.04),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Trophy Icon Box
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_events_outlined,
                          color: Color(0xFFF59E0B),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Mastery Tier Texts
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mastery Tier',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.badge.masteryTier,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Divider
                      Container(
                        height: 24,
                        width: 1,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      const SizedBox(width: 12),
                      // Unlocked Status
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF10B981),
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Unlocked',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 7. Claim Button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIconsFill.shield,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'CLAIM & EQUIP BADGE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Close Button top-right
          Positioned(
            top: 14,
            right: 14,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white54,
                  size: 16,
                ),
              ),
            ),
          ),

          // Floating Confetti Particles with wiggling animation
          ..._particles.asMap().entries.map((entry) {
            final idx = entry.key;
            final p = entry.value;
            
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double phase = idx * 0.5;
                final double t = _controller.value * 2 * pi + phase;
                
                final double wiggleX = sin(t) * 6.0;
                final double wiggleY = cos(t * 1.5) * 4.0;
                final double extraRotation = sin(t * 0.8) * 0.2;
                
                return Positioned(
                  top: p.top + wiggleY,
                  left: p.left + wiggleX,
                  child: Transform.rotate(
                    angle: p.rotation + extraRotation,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: p.size,
                height: p.size,
                decoration: BoxDecoration(
                  color: p.color,
                  shape: p.isCircle ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: p.isCircle ? null : BorderRadius.circular(p.size * 0.25),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
