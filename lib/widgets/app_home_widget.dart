import 'dart:math';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../providers/habit_provider.dart';

// ==========================================
// 1. Small Widget — Habit Streak (2x2)
// ==========================================
class StreakWidget extends StatelessWidget {
  final Habit? habit;
  final double currentProgress;
  final double targetProgress;
  final String unit;
  final int streak;

  const StreakWidget({
    super.key,
    this.habit,
    required this.currentProgress,
    required this.targetProgress,
    required this.unit,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final title = habit?.title ?? 'No Habit Selected';
    final accentColor = habit != null ? Color(habit!.colorHex) : const Color(0xFFF43F5E);
    final fillPct = targetProgress > 0 ? (currentProgress / targetProgress).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          // Subtle glow towards the bottom right
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.15),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Icon/Name + Add Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            PhosphorIconsFill.fire,
                            color: accentColor,
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  Text(
                                    '$streak streak',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    PhosphorIconsFill.fire,
                                    color: Colors.amber,
                                    size: 8,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Compact Plus Button
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1),
                      color: Colors.white.withOpacity(0.04),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Main content
              Text(
                '${currentProgress.toInt()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                unit,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Target: ${targetProgress.toInt()} $unit',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
              const Spacer(),
              // Horizontal progress bar
              Container(
                height: 5,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(3),
                ),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: fillPct,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentColor, accentColor.withOpacity(0.5)],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. Small Widget — Daily Flow (2x2)
// ==========================================
class DailyFlowWidget extends StatelessWidget {
  final int completedCount;
  final int totalCount;

  const DailyFlowWidget({
    super.key,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final pct = totalCount > 0 ? (completedCount / totalCount) : 0.0;
    final displayPct = (pct * 100).toInt();
    final remaining = max(0, totalCount - completedCount);

    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Flow',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                '$completedCount/$totalCount',
                style: const TextStyle(
                  color: Color(0xFFFBBF24), // gold accent
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Circular Progress Ring
          Center(
            child: SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: pct,
                    backgroundColor: Colors.white.withOpacity(0.06),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF43F5E)), // pink/red
                    strokeWidth: 7,
                  ),
                  Text(
                    '$displayPct%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Bottom remaining label
          Text(
            '$remaining habits remaining',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. Small Widget — Quick Focus (2x2)
// ==========================================
class QuickFocusWidget extends StatelessWidget {
  const QuickFocusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    color: Color(0xFFFBBF24), // yellow lightning
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Quick Focus',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              Text(
                '25m',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Deep Work sprint details
          const Text(
            'Deep Work Sprint',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Zero distractions. Instant brain wave sync.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 8,
              height: 1.3,
              decoration: TextDecoration.none,
            ),
          ),
          const Spacer(),
          // Start Pomodoro Button
          Container(
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF43F5E), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            alignment: Alignment.center,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  'Start Pomodoro',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. Medium Widget — Priority Habits (4x2)
// ==========================================
class PriorityHabitsWidget extends StatelessWidget {
  final List<Habit> habits;
  final Map<String, Map<String, HabitRecord>> records;

  const PriorityHabitsWidget({
    super.key,
    required this.habits,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    final todayKey = HabitRecordNotifier.dateKey(DateTime.now());
    final dayRecords = records[todayKey] ?? {};

    // Filter down to at most 3 habits
    final priorityList = habits.take(3).toList();
    int completedCount = 0;
    for (final h in habits) {
      if (dayRecords[h.id]?.isCompleted ?? false) {
        completedCount++;
      }
    }
    final pct = habits.isNotEmpty ? (completedCount / habits.length * 100).toInt() : 0;

    return Container(
      width: 320,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    PhosphorIconsFill.fire,
                    color: Color(0xFFF43F5E),
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "Today's Priority Habits",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              Text(
                '$pct% Complete',
                style: const TextStyle(
                  color: Color(0xFFFBBF24), // gold accent
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Habit Rows
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                if (index >= priorityList.length) {
                  return Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'No priority habit configured',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 9,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  );
                }

                final habit = priorityList[index];
                final isDone = dayRecords[habit.id]?.isCompleted ?? false;
                final accentColor = Color(habit.colorHex);

                return Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: accentColor,
                            size: 13,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            habit.title,
                            style: TextStyle(
                              color: isDone ? Colors.white30 : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                      isDone
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF10B981),
                              size: 14,
                            )
                          : Icon(
                              Icons.circle_outlined,
                              color: Colors.white.withOpacity(0.15),
                              size: 14,
                            ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 5. Medium Widget — Circadian Energy (4x2)
// ==========================================
class CircadianWidget extends StatelessWidget {
  const CircadianWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.circle_outlined,
                    color: Color(0xFF26E6A4), // cyan circular energy icon
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '24h Circadian Energy Window',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              Text(
                'Peak Focus Zone',
                style: TextStyle(
                  color: Color(0xFF26E6A4),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Inner Focus Information Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Deep Work Sprint & Hydration',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Text(
                      '9:00 – 11:30 AM',
                      style: TextStyle(
                        color: Color(0xFFFBBF24), // gold accent
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'High neuroplasticity and dopamine synthesis. Perfect window for non-distracted sprints.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 8,
                    height: 1.3,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Timeline Row of blocks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(24, (index) {
              final isPeak = index >= 9 && index <= 11;
              final isCurrent = index == 10;
              final color = isCurrent
                  ? const Color(0xFFF43F5E) // Pink (current)
                  : (isPeak ? const Color(0xFF26E6A4) : Colors.white12); // Cyan (peak) or Dark gray
              return Expanded(
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 6. Large Widget — Habit Station Grid (4x4)
// ==========================================
class MasterGridWidget extends StatelessWidget {
  final List<Habit> habits;
  final Map<String, Map<String, HabitRecord>> records;

  const MasterGridWidget({
    super.key,
    required this.habits,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayKey = HabitRecordNotifier.dateKey(today);
    final dayRecords = records[todayKey] ?? {};

    int completedCount = 0;
    for (final h in habits) {
      if (dayRecords[h.id]?.isCompleted ?? false) {
        completedCount++;
      }
    }
    final pct = habits.isNotEmpty ? (completedCount / habits.length * 100).toInt() : 0;

    // Render 7-day Rhythm check indicators (M T W T F S S)
    final weekdayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final todayDay = today.weekday; // 1 = Mon, 7 = Sun

    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            PhosphorIconsFill.squaresFour,
                            color: Color(0xFF8B5CF6),
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Habit Station Master Grid',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Weekly Consistency & Live Check-in',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 9,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$pct% Today',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 7-Day Rhythm Panel
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '7-Day Rhythm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Text(
                      '94% Weekly Score',
                      style: TextStyle(
                        color: Color(0xFF26E6A4), // turquoise accent
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (idx) {
                    final dayNum = idx + 1; // 1 = Mon, 7 = Sun
                    final bool isCurrent = dayNum == todayDay;
                    final bool isPast = dayNum < todayDay;
                    
                    // Mock check state for rhythm
                    final bool isDone = isPast || (isCurrent && pct > 50);

                    return Column(
                      children: [
                        Text(
                          weekdayNames[idx],
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isCurrent
                                ? const LinearGradient(colors: [Color(0xFFF43F5E), Color(0xFF8B5CF6)])
                                : null,
                            color: isCurrent
                                ? null
                                : (isDone ? const Color(0xFF10B981) : Colors.white.withOpacity(0.04)),
                          ),
                          alignment: Alignment.center,
                          child: isDone || isCurrent
                              ? const Icon(Icons.check, color: Colors.white, size: 10)
                              : const Text('-', style: TextStyle(color: Colors.white24, fontSize: 10, decoration: TextDecoration.none)),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2x2 Habit Grid
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildHabitCard(0, dayRecords)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildHabitCard(1, dayRecords)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildHabitCard(2, dayRecords)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildHabitCard(3, dayRecords)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(int idx, Map<String, HabitRecord> dayRecords) {
    if (idx >= habits.length) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Empty slot',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 9,
            decoration: TextDecoration.none,
          ),
        ),
      );
    }

    final habit = habits[idx];
    final isDone = dayRecords[habit.id]?.isCompleted ?? false;
    final currentValue = dayRecords[habit.id]?.currentValue ?? 0.0;
    final accentColor = Color(habit.colorHex);

    final String progressLabel;
    if (habit.type == HabitType.boolean) {
      progressLabel = isDone ? 'Done' : 'Pending';
    } else {
      progressLabel = '${currentValue.toInt()}/${habit.targetValue.toInt()} ${habit.unit}';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDone ? accentColor.withOpacity(0.15) : Colors.transparent,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: accentColor, size: 12),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        habit.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  progressLabel,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 8,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          isDone
              ? const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF10B981),
                  size: 14,
                )
              : Icon(
                  Icons.circle_outlined,
                  color: Colors.white.withOpacity(0.15),
                  size: 14,
                ),
        ],
      ),
    );
  }
}

// ==========================================
// 7. Lock Screen Widget — Habit Ring
// ==========================================
class LockRingWidget extends StatelessWidget {
  final int completedCount;
  final int totalCount;

  const LockRingWidget({
    super.key,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final pct = totalCount > 0 ? (completedCount / totalCount) : 0.0;
    final displayPct = (pct * 100).toInt();

    return Container(
      width: 160,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white12,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Circular Progress Ring
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: pct,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 4,
                ),
                Text(
                  '$displayPct%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Ring Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Habit Ring',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$completedCount of $totalCount Done',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 8. Lock Screen Widget — Best Streak
// ==========================================
class LockStreakWidget extends StatelessWidget {
  final int bestStreak;
  final String nextHabitTitle;
  final String nextHabitDuration;

  const LockStreakWidget({
    super.key,
    required this.bestStreak,
    required this.nextHabitTitle,
    required this.nextHabitDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white12,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Top Row: Streak + On Track
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    PhosphorIconsFill.fire,
                    color: Colors.amber,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${bestStreak}d Best Streak',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              const Text(
                'On Track',
                style: TextStyle(
                  color: Color(0xFF10B981), // green
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Bottom next habit line
          Text(
            'Next up: $nextHabitTitle ($nextHabitDuration)',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 8,
              decoration: TextDecoration.none,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
