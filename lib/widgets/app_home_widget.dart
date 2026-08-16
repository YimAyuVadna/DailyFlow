import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';

class DailyProgressWidget extends StatelessWidget {
  final int completed;
  final int total;
  final int streak;

  const DailyProgressWidget({
    super.key,
    required this.completed,
    required this.total,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final double percent = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
    
    return Container(
      width: 250,
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C26), // AppTheme.surfaceLight equivalent
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x3300FFB2)), // Neon Green alpha
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FFB2).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(PhosphorIconsFill.fire, color: Color(0xFF00FFB2), size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Daily Momentum',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              Text(
                '$completed / $total',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar Track
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: percent,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF2E93), Color(0xFF00FFB2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
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
