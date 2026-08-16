import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';
import 'shimmer_track.dart';

class MomentumCard extends ConsumerWidget {
  const MomentumCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final records = ref.watch(habitRecordsProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final dateKey = HabitRecordNotifier.dateKey(selectedDate);
    final dayRecords = records[dateKey] ?? {};

    int completedCount = 0;
    for (final habit in habits) {
      final record = dayRecords[habit.id];
      if (record != null && record.isCompleted) completedCount++;
    }

    final percent = habits.isEmpty ? 0.0 : completedCount / habits.length;
    final isAllDone = completedCount == habits.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getSurface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isAllDone
              ? AppTheme.accentNeonGreen.withValues(alpha: 0.3)
              : AppTheme.getSurfaceLight(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: AppTheme.accentMagenta, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'MOMENTUM HIGH',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.accentMagenta,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isAllDone
                          ? 'All Habits Crushed! 🌟'
                          : '$completedCount of ${habits.length} Done',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAllDone
                          ? 'Outstanding consistency! Keep it up.'
                          : '${habits.length - completedCount} more to hit 100%.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 80,
                height: 80,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  tween: Tween<double>(begin: 0, end: percent),
                  builder: (context, value, _) {
                    return CustomPaint(
                      painter: CircleProgressPainter(percent: value),
                      child: Center(
                        child: Text(
                          '${(value * 100).toInt()}%',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  const ShimmerTrack(height: 12),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(begin: 0, end: percent),
                    builder: (context, value, _) {
                      return Container(
                        width: constraints.maxWidth * value,
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.accentMagenta,
                              AppTheme.accentNeonGreen,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentNeonGreen.withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            }
          ),
        ],
      ),
    );
  }
}

class CircleProgressPainter extends CustomPainter {
  final double percent;

  CircleProgressPainter({required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 6.0;

    // Background circle
    final bgPaint = Paint()
      ..color = AppTheme.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Gradient arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + 2 * math.pi,
      colors: const [AppTheme.accentMagenta, AppTheme.accentNeonGreen],
    );

    // Glow effect
    final glowPath = Path()
      ..addArc(rect, -math.pi / 2, 2 * math.pi * percent);
    
    canvas.drawPath(
      glowPath,
      Paint()
        ..color = AppTheme.accentNeonGreen.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Gradient arc
    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * percent,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircleProgressPainter oldDelegate) =>
      oldDelegate.percent != percent;
}
