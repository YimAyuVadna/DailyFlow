import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class MatrixScreen extends ConsumerWidget {
  const MatrixScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(habitRecordsProvider);
    final habits = ref.watch(habitsProvider).where((h) => !h.isArchived).toList();
    final settings = ref.watch(heatmapSettingsProvider);
    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: 364));

    // Build stats
    int totalCompleted = 0;
    int totalPerfectDays = 0;
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;

    for (int i = 0; i < 365; i++) {
      final date = startDate.add(Duration(days: i));
      final dateKey = HabitRecordNotifier.dateKey(date);
      final dayRecords = records[dateKey] ?? {};
      int completed = 0;
      for (final r in dayRecords.values) {
        if (r.isCompleted) completed++;
      }
      if (habits.isNotEmpty && completed == habits.length) {
        totalPerfectDays++;
        tempStreak++;
        if (tempStreak > longestStreak) longestStreak = tempStreak;
      } else {
        tempStreak = 0;
      }
      totalCompleted += completed;
    }

    // Current streak (from today backwards)
    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final dateKey = HabitRecordNotifier.dateKey(date);
      final dayRecords = records[dateKey] ?? {};
      int completed = 0;
      for (final r in dayRecords.values) {
        if (r.isCompleted) completed++;
      }
      if (habits.isNotEmpty && completed == habits.length) {
        currentStreak++;
      } else {
        break;
      }
    }

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
              child: Icon(PhosphorIconsBold.arrowLeft,
                  size: 18, color: Theme.of(context).brightness == Brightness.dark ? AppTheme.textPrimary : AppTheme.lightTextPrimary),
            ),
          ),
        ),
        title: const Text('Activity Matrix',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // ── Stats Row ──
          Row(
            children: [
              _StatCard(label: 'Current Streak', value: '${currentStreak}d',
                  icon: PhosphorIconsFill.fire, color: AppTheme.accentOrange),
              const SizedBox(width: 10),
              _StatCard(label: 'Longest Streak', value: '${longestStreak}d',
                  icon: PhosphorIconsFill.trophy, color: AppTheme.accentNeonGreen),
              const SizedBox(width: 10),
              _StatCard(label: 'Perfect Days', value: '$totalPerfectDays',
                  icon: PhosphorIconsFill.star, color: AppTheme.accentMagenta),
            ],
          ),
          const SizedBox(height: 20),

          // ── Full Year Grid ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.getSurface(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.getSurfaceLight(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Last 365 Days',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                const SizedBox(height: 12),
                _FullYearMatrix(
                  records: records,
                  habits: habits,
                  today: today,
                  settings: settings,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Per-Habit Breakdown ──
          Text('Habit Breakdown',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...habits.map((habit) {
            int habitCompleted = 0;
            for (int i = 0; i < 365; i++) {
              final date = startDate.add(Duration(days: i));
              final dateKey = HabitRecordNotifier.dateKey(date);
              final dayRecords = records[dateKey] ?? {};
              final record = dayRecords[habit.id];
              if (record != null && record.isCompleted) habitCompleted++;
            }
            final pct = ((habitCompleted / 365) * 100).toInt();
            final accentColor = Color(habit.colorHex);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.getSurface(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.getSurfaceLight(context)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(PhosphorIconsFill.checkCircle,
                        color: accentColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(habit.title,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        LayoutBuilder(builder: (context, constraints) {
                          return Stack(
                            children: [
                              Container(
                                height: 6,
                                width: constraints.maxWidth,
                                decoration: BoxDecoration(
                                  color: AppTheme.getSurfaceLight(context),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              Container(
                                height: 6,
                                width: constraints.maxWidth * (habitCompleted / 365),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    accentColor.withValues(alpha: 0.6),
                                    accentColor,
                                  ]),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                        color: accentColor.withValues(alpha: 0.4),
                                        blurRadius: 4),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$habitCompleted',
                          style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Text('days ($pct%)',
                          style: TextStyle(
                              color: AppTheme.getTextSecondary(context),
                              fontSize: 10)),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Full 52-week grid ──────────────────────────────────────────────────────

class _FullYearMatrix extends StatelessWidget {
  final Map<String, Map<String, HabitRecord>> records;
  final List<Habit> habits;
  final DateTime today;
  final HeatmapSettings settings;

  const _FullYearMatrix({
    required this.records,
    required this.habits,
    required this.today,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    const int weeks = 52;
    const int days = 7;
    const double cellSize = 21.0;
    const double gap = 3.0;
    final startDate = today.subtract(Duration(days: weeks * days - 1));

    // Build month labels
    final monthLabels = <int, String>{};
    for (int w = 0; w < weeks; w++) {
      final weekStart = startDate.add(Duration(days: w * 7));
      if (w == 0 || weekStart.day <= 7) {
        monthLabels[w] = DateFormat('MMM').format(weekStart);
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month labels
          Row(
            children: List.generate(weeks, (w) {
              return SizedBox(
                width: cellSize + gap,
                child: Text(
                  monthLabels[w] ?? '',
                  style: TextStyle(
                    color: AppTheme.getTextSecondary(context),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.visible,
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          // Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(weeks, (w) {
              return Column(
                children: List.generate(days, (d) {
                  final date = startDate.add(Duration(days: w * 7 + d));
                  if (date.isAfter(today)) {
                    return SizedBox(width: cellSize + gap, height: cellSize + gap);
                  }
                  final intensity = _getIntensity(date);
                  final cellColor = _intensityColor(intensity, context);
                  final isToday = date.year == today.year &&
                      date.month == today.month &&
                      date.day == today.day;

                  return Padding(
                    padding: const EdgeInsets.only(right: gap, bottom: gap),
                    child: Container(
                      width: cellSize,
                      height: cellSize,
                      decoration: BoxDecoration(
                        color: cellColor,
                        borderRadius: BorderRadius.circular(3),
                        border: isToday
                            ? Border.all(color: Colors.white38, width: 1)
                            : null,
                        boxShadow: settings.isGlowEnabled && intensity > 0.5
                            ? [
                                BoxShadow(
                                  color: cellColor.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                )
                              ]
                            : null,
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
          const SizedBox(height: 10),
          // Legend
          Row(
            children: [
              Text('Less',
                  style: TextStyle(
                      color: AppTheme.getTextSecondary(context), fontSize: 10)),
              const SizedBox(width: 6),
              ...[0.0, 0.25, 0.5, 0.75, 1.0].map((v) => Padding(
                    padding: const EdgeInsets.only(left: 3),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: v == 0.0
                            ? AppTheme.getSurfaceLight(context)
                            : _intensityColor(v, context),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  )),
              const SizedBox(width: 6),
              Text('More',
                  style: TextStyle(
                      color: AppTheme.getTextSecondary(context), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  double _getIntensity(DateTime date) {
    if (habits.isEmpty) return 0.0;
    final dateKey = HabitRecordNotifier.dateKey(date);
    final dayRecords = records[dateKey] ?? {};
    int completed = 0;
    for (final record in dayRecords.values) {
      if (record.isCompleted) completed++;
    }
    return (completed / habits.length).clamp(0.0, 1.0);
  }

  Color _intensityColor(double intensity, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (intensity == 0) {
      return isDark
          ? AppTheme.surfaceLight.withValues(alpha: 0.5)
          : AppTheme.lightSurfaceLight.withValues(alpha: 0.5);
    }
    const palettes = [
      [Color(0xFF0F362C), Color(0xFF165C45), Color(0xFF1E825F), AppTheme.accentNeonGreen],
      [Color(0xFF3B151F), Color(0xFF671A31), Color(0xFFC02150), Color(0xFFFF4978)],
      [Color(0xFF28114A), Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFFC48BFF)],
      [Color(0xFF401C00), Color(0xFF8A3C00), Color(0xFFD97706), Color(0xFFFBBF24)],
      [Color(0xFF0B2D45), Color(0xFF02629A), Color(0xFF0091E6), Color(0xFF38B2FA)],
    ];
    final p = palettes[settings.paletteIndex % palettes.length];
    if (intensity <= 0.25) return p[0];
    if (intensity <= 0.5) return p[1];
    if (intensity <= 0.75) return p[2];
    return p[3];
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.getSurface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: AppTheme.getTextSecondary(context),
                    fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
