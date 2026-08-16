import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';
import '../models/habit.dart';

class BadgeData {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool Function(BadgeStats stats) isUnlocked;

  const BadgeData({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isUnlocked,
  });
}

class BadgeStats {
  final int totalCompletions;
  final int longestPerfectStreak;
  final int longestActiveStreak;
  final int perfectDays;
  final int weekendCompletions;
  final int maxHabitsInOneDay;

  const BadgeStats({
    required this.totalCompletions,
    required this.longestPerfectStreak,
    required this.longestActiveStreak,
    required this.perfectDays,
    required this.weekendCompletions,
    required this.maxHabitsInOneDay,
  });
}

final _allBadges = [
  // Completions
  BadgeData(
    id: 'first_step',
    title: 'First Step',
    description: 'Complete your first habit goal.',
    icon: PhosphorIconsFill.sneaker,
    color: AppTheme.accentBlue,
    isUnlocked: (s) => s.totalCompletions >= 1,
  ),
  BadgeData(
    id: 'getting_serious',
    title: 'Getting Serious',
    description: 'Complete 50 habits in total.',
    icon: PhosphorIconsFill.barbell,
    color: AppTheme.accentNeonGreen,
    isUnlocked: (s) => s.totalCompletions >= 50,
  ),
  BadgeData(
    id: 'dedicated',
    title: 'Dedicated',
    description: 'Complete 100 habits in total.',
    icon: PhosphorIconsFill.medal,
    color: AppTheme.accentMagenta,
    isUnlocked: (s) => s.totalCompletions >= 100,
  ),
  BadgeData(
    id: 'unstoppable',
    title: 'Unstoppable',
    description: 'Complete 500 habits in total.',
    icon: PhosphorIconsFill.rocket,
    color: AppTheme.accentOrange,
    isUnlocked: (s) => s.totalCompletions >= 500,
  ),
  BadgeData(
    id: 'habit_master',
    title: 'Habit Master',
    description: 'Complete 1000 habits in total.',
    icon: PhosphorIconsFill.crown,
    color: Colors.amber,
    isUnlocked: (s) => s.totalCompletions >= 1000,
  ),

  // Streaks (Active - at least 1 habit)
  BadgeData(
    id: 'momentum',
    title: 'Momentum',
    description: 'Complete at least 1 habit 3 days in a row.',
    icon: PhosphorIconsFill.trendUp,
    color: AppTheme.accentNeonGreen,
    isUnlocked: (s) => s.longestActiveStreak >= 3,
  ),
  BadgeData(
    id: 'consistency',
    title: 'Consistency',
    description: 'Complete at least 1 habit 14 days in a row.',
    icon: PhosphorIconsFill.arrowsClockwise,
    color: AppTheme.accentBlue,
    isUnlocked: (s) => s.longestActiveStreak >= 14,
  ),
  BadgeData(
    id: 'habit_lifestyle',
    title: 'Lifestyle',
    description: 'Complete at least 1 habit 50 days in a row.',
    icon: PhosphorIconsFill.infinity,
    color: AppTheme.accentMagenta,
    isUnlocked: (s) => s.longestActiveStreak >= 50,
  ),

  // Streaks (Perfect - all active habits)
  BadgeData(
    id: 'streak_starter',
    title: 'Streak Starter',
    description: 'Reach a 3-day perfect streak.',
    icon: PhosphorIconsFill.fire,
    color: AppTheme.accentOrange,
    isUnlocked: (s) => s.longestPerfectStreak >= 3,
  ),
  BadgeData(
    id: 'one_week',
    title: 'One Week',
    description: 'Reach a 7-day perfect streak.',
    icon: PhosphorIconsFill.calendarCheck,
    color: AppTheme.accentNeonGreen,
    isUnlocked: (s) => s.longestPerfectStreak >= 7,
  ),
  BadgeData(
    id: 'one_month',
    title: 'One Month',
    description: 'Reach a 30-day perfect streak.',
    icon: PhosphorIconsFill.moonStars,
    color: AppTheme.accentBlue,
    isUnlocked: (s) => s.longestPerfectStreak >= 30,
  ),
  BadgeData(
    id: 'two_months',
    title: 'Two Months',
    description: 'Reach a 60-day perfect streak.',
    icon: PhosphorIconsFill.mountains,
    color: AppTheme.accentMagenta,
    isUnlocked: (s) => s.longestPerfectStreak >= 60,
  ),
  BadgeData(
    id: 'half_year',
    title: 'Half Year',
    description: 'Reach a 180-day perfect streak.',
    icon: PhosphorIconsFill.shieldStar,
    color: Colors.amber,
    isUnlocked: (s) => s.longestPerfectStreak >= 180,
  ),

  // Perfect Days
  BadgeData(
    id: 'perfect_day',
    title: 'Perfect Day',
    description: 'Complete all habits in a single day.',
    icon: PhosphorIconsFill.star,
    color: AppTheme.accentNeonGreen,
    isUnlocked: (s) => s.perfectDays >= 1,
  ),
  BadgeData(
    id: 'flawless_week',
    title: 'Flawless Week',
    description: 'Achieve 7 perfect days total.',
    icon: PhosphorIconsFill.sparkle,
    color: Colors.amber,
    isUnlocked: (s) => s.perfectDays >= 7,
  ),
  BadgeData(
    id: 'flawless_month',
    title: 'Flawless Month',
    description: 'Achieve 30 perfect days total.',
    icon: PhosphorIconsFill.diamond,
    color: Colors.cyanAccent,
    isUnlocked: (s) => s.perfectDays >= 30,
  ),
  BadgeData(
    id: 'centurion',
    title: 'Centurion',
    description: 'Achieve 100 perfect days total.',
    icon: PhosphorIconsFill.shieldCheck,
    color: AppTheme.accentOrange,
    isUnlocked: (s) => s.perfectDays >= 100,
  ),

  // Special/Misc
  BadgeData(
    id: 'weekend_warrior',
    title: 'Weekend Warrior',
    description: 'Complete 10 habits on weekends.',
    icon: PhosphorIconsFill.tent,
    color: AppTheme.accentOrange,
    isUnlocked: (s) => s.weekendCompletions >= 10,
  ),
  BadgeData(
    id: 'overachiever',
    title: 'Overachiever',
    description: 'Complete 5 habits in a single day.',
    icon: PhosphorIconsFill.lightning,
    color: AppTheme.accentMagenta,
    isUnlocked: (s) => s.maxHabitsInOneDay >= 5,
  ),
];

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  BadgeStats _calculateStats(
      List<Habit> activeHabits, Map<String, Map<String, HabitRecord>> records) {
    if (records.isEmpty || activeHabits.isEmpty) {
      return const BadgeStats(
        totalCompletions: 0, 
        longestPerfectStreak: 0, 
        longestActiveStreak: 0,
        perfectDays: 0,
        weekendCompletions: 0,
        maxHabitsInOneDay: 0,
      );
    }

    int totalCompletions = 0;
    int perfectDays = 0;
    int currentPerfectStreak = 0;
    int longestPerfectStreak = 0;
    int currentActiveStreak = 0;
    int longestActiveStreak = 0;
    int weekendCompletions = 0;
    int maxHabitsInOneDay = 0;

    final dateKeys = records.keys.toList()..sort();
    
    for (final dateKey in dateKeys) {
      final dayRecords = records[dateKey]!;
      int completedToday = 0;

      // Check if it's a weekend (Saturday = 6, Sunday = 7)
      final date = DateTime.parse(dateKey);
      final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

      for (final r in dayRecords.values) {
        if (r.isCompleted) {
          completedToday++;
          totalCompletions++;
          if (isWeekend) weekendCompletions++;
        }
      }

      if (completedToday > maxHabitsInOneDay) {
        maxHabitsInOneDay = completedToday;
      }

      // Active Streak (at least 1 habit done)
      if (completedToday > 0) {
        currentActiveStreak++;
        if (currentActiveStreak > longestActiveStreak) {
          longestActiveStreak = currentActiveStreak;
        }
      } else {
        currentActiveStreak = 0;
      }

      // Perfect Streak (all active habits done)
      if (completedToday > 0 && completedToday >= activeHabits.length) {
        perfectDays++;
        currentPerfectStreak++;
        if (currentPerfectStreak > longestPerfectStreak) {
          longestPerfectStreak = currentPerfectStreak;
        }
      } else {
        currentPerfectStreak = 0;
      }
    }

    return BadgeStats(
      totalCompletions: totalCompletions,
      longestPerfectStreak: longestPerfectStreak,
      longestActiveStreak: longestActiveStreak,
      perfectDays: perfectDays,
      weekendCompletions: weekendCompletions,
      maxHabitsInOneDay: maxHabitsInOneDay,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final activeHabits = habits.where((h) => !h.isArchived).toList();
    final records = ref.watch(habitRecordsProvider);

    final stats = _calculateStats(activeHabits, records);

    return Scaffold(
      backgroundColor: AppTheme.getSurface(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceLight(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                PhosphorIconsBold.arrowLeft,
                size: 18,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.textPrimary
                    : AppTheme.lightTextPrimary,
              ),
            ),
          ),
        ),
        title: const Text('Achievements',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Badges',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final badge = _allBadges[index];
                  final isUnlocked = badge.isUnlocked(stats);

                  return _BadgeCard(badge: badge, isUnlocked: isUnlocked);
                },
                childCount: _allBadges.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final BadgeData badge;
  final bool isUnlocked;

  const _BadgeCard({
    required this.badge,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = AppTheme.getSurfaceLight(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: isUnlocked
            ? Border.all(color: badge.color.withValues(alpha: 0.5), width: 2)
            : Border.all(color: Colors.transparent, width: 2),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: badge.color.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Box
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked
                  ? badge.color.withValues(alpha: 0.15)
                  : (isDark ? Colors.white10 : Colors.black12),
            ),
            child: Center(
              child: Icon(
                isUnlocked ? badge.icon : PhosphorIconsFill.lockKey,
                size: 32,
                color: isUnlocked
                    ? badge.color
                    : AppTheme.getTextSecondary(context).withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isUnlocked
                  ? (isDark ? Colors.white : Colors.black)
                  : AppTheme.getTextSecondary(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Description
          Expanded(
            child: Text(
              badge.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.getTextSecondary(context)
                    .withValues(alpha: isUnlocked ? 0.9 : 0.5),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
