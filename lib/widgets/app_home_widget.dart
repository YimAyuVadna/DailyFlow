import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';

class DailyProgressWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final double percent;
  final int streak;
  final IconData icon;
  final Color iconColor;

  const DailyProgressWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.percent,
    required this.streak,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C26), // AppTheme.surfaceLight equivalent
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Progress Bar Track
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: percent,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF2E93), Color(0xFF00FFB2)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(PhosphorIconsFill.flame, color: Color(0xFFFF8A00), size: 12),
              const SizedBox(width: 4),
              Text(
                '$streak Day Streak',
                style: const TextStyle(
                  color: Color(0xFFFF8A00),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
