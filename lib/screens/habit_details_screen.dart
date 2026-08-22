import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/icon_helper.dart';
import '../widgets/create_habit_sheet.dart';

class HabitDetailsScreen extends ConsumerWidget {
  final Habit habit;

  const HabitDetailsScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(habitRecordsProvider);
    final currentHabit = ref.watch(habitsProvider).firstWhere(
          (h) => h.id == habit.id,
          orElse: () => habit,
        );
    final accentColor = Color(currentHabit.colorHex);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayKey = HabitRecordNotifier.dateKey(today);

    // Calculate current streak
    int currentStreak = 0;
    final todayCompleted = records[todayKey]?[currentHabit.id]?.isCompleted ?? false;
    bool streakActive = false;
    DateTime checkDate = today;

    if (todayCompleted) {
      streakActive = true;
      checkDate = today;
    } else {
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayKey = HabitRecordNotifier.dateKey(yesterday);
      final yesterdayCompleted = records[yesterdayKey]?[currentHabit.id]?.isCompleted ?? false;
      if (yesterdayCompleted) {
        streakActive = true;
        checkDate = yesterday;
      }
    }

    if (streakActive) {
      while (true) {
        final key = HabitRecordNotifier.dateKey(checkDate);
        final completed = records[key]?[currentHabit.id]?.isCompleted ?? false;
        if (completed) {
          currentStreak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }

    // Calculate best record (longest streak)
    int maxStreak = 0;
    int tempStreak = 0;
    DateTime earliestDate = today.subtract(const Duration(days: 365));
    if (records.isNotEmpty) {
      for (final key in records.keys) {
        if (records[key]?.containsKey(currentHabit.id) ?? false) {
          try {
            final parsed = DateTime.parse(key);
            if (parsed.isBefore(earliestDate)) {
              earliestDate = parsed;
            }
          } catch (_) {}
        }
      }
    }

    DateTime d = DateTime(earliestDate.year, earliestDate.month, earliestDate.day);
    while (!d.isAfter(today)) {
      final key = HabitRecordNotifier.dateKey(d);
      final completed = records[key]?[currentHabit.id]?.isCompleted ?? false;
      if (completed) {
        tempStreak++;
        if (tempStreak > maxStreak) {
          maxStreak = tempStreak;
        }
      } else {
        tempStreak = 0;
      }
      d = d.add(const Duration(days: 1));
    }

    // Calculate today completion percentage
    final todayRecord = records[todayKey]?[currentHabit.id];
    int todayPct = 0;
    if (todayRecord != null) {
      if (todayRecord.isCompleted) {
        todayPct = 100;
      } else if (currentHabit.targetValue > 0) {
        todayPct = ((todayRecord.currentValue / currentHabit.targetValue) * 100).clamp(0, 100).toInt();
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF050508),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon Box
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            getHabitIcon(currentHabit.iconName),
                            color: accentColor,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Titles
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (currentHabit.categories.isNotEmpty ? currentHabit.categories.first : 'Habit').toUpperCase(),
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentHabit.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentHabit.type == HabitType.boolean
                                    ? 'Goal: Complete daily'
                                    : 'Goal: ${currentHabit.targetValue.toInt()} ${currentHabit.unit.isNotEmpty ? currentHabit.unit : (currentHabit.type == HabitType.blocks ? 'blocks' : '')} / day',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Close Button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 2. Statistics Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            label: 'Current Streak',
                            value: '🔥 ${currentStreak}d',
                            accentColor: AppTheme.accentOrange,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            label: 'Best Record',
                            value: '🏅 ${maxStreak}d',
                            accentColor: accentColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            label: 'Today',
                            value: '$todayPct%',
                            accentColor: accentColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 3. 28-Day Consistency Matrix
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: ConsistencyMatrix(
                        habit: currentHabit,
                        records: records,
                        accentColor: accentColor,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4. Active Days Target
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: ActiveDaysTarget(
                        habit: currentHabit,
                        accentColor: accentColor,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 5. Bottom Action Button
                    GestureDetector(
                      onTap: () => _startFocusMode(context, ref, currentHabit),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Focus Mode',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: accentColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _startFocusMode(BuildContext context, WidgetRef ref, Habit habit) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FocusSessionDialog(habit: habit),
    );
  }
}

class ConsistencyMatrix extends ConsumerWidget {
  final Habit habit;
  final Map<String, Map<String, HabitRecord>> records;
  final Color accentColor;

  const ConsistencyMatrix({
    super.key,
    required this.habit,
    required this.records,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(const Duration(days: 34)); // 35 days total

    // Calculate stats for the last 30 days
    int completedDaysCount = 0;
    for (int i = 0; i < 30; i++) {
      final date = today.subtract(Duration(days: i));
      final dateKey = HabitRecordNotifier.dateKey(date);
      if (records[dateKey]?[habit.id]?.isCompleted ?? false) {
        completedDaysCount++;
      }
    }
    final completionRate = (completedDaysCount / 30 * 100).toInt();

    final settings = ref.watch(heatmapSettingsProvider);
    const palettes = [
      [Color(0xFF0F362C), Color(0xFF165C45), Color(0xFF1E825F), Color(0xFF26E6A4)],
      [Color(0xFF3B151F), Color(0xFF671A31), Color(0xFFC02150), Color(0xFFFF4978)],
      [Color(0xFF28114A), Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFFC48BFF)],
      [Color(0xFF401C00), Color(0xFF8A3C00), Color(0xFFD97706), Color(0xFFFBBF24)],
      [Color(0xFF0B2D45), Color(0xFF02629A), Color(0xFF0091E6), Color(0xFF38B2FA)],
    ];
    final p = palettes[settings.paletteIndex % palettes.length];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(PhosphorIconsRegular.calendarBlank, color: p[3], size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Monthly Consistency Matrix',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const Text(
              'Recent Activity',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Row containing 5-week grid on the left and stats on the right
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Grid + Labels
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (colIndex) {
                    return Padding(
                      padding: EdgeInsets.only(right: colIndex < 4 ? 4.0 : 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(7, (rowIndex) {
                          final dayOffset = (colIndex * 7) + rowIndex;
                          final date = startDate.add(Duration(days: dayOffset));
                          final dateKey = HabitRecordNotifier.dateKey(date);

                          final record = records[dateKey]?[habit.id];
                          final isCompleted = record?.isCompleted ?? false;
                          final double val = record?.currentValue ?? 0.0;
                          final double target = habit.targetValue > 0 ? habit.targetValue : 1.0;
                          final double pct = isCompleted ? 1.0 : (val / target).clamp(0.0, 1.0);

                          final bool hasProgress = pct > 0.0;
                          final Color cellColor;
                          if (!hasProgress) {
                            cellColor = AppTheme.surfaceLight;
                          } else if (pct <= 0.25) {
                            cellColor = p[0];
                          } else if (pct <= 0.5) {
                            cellColor = p[1];
                          } else if (pct <= 0.75) {
                            cellColor = p[2];
                          } else {
                            cellColor = p[3];
                          }

                          return Padding(
                            padding: EdgeInsets.only(bottom: rowIndex < 6 ? 4.0 : 0.0),
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: cellColor,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: hasProgress
                                      ? p[3].withValues(alpha: 0.3)
                                      : Colors.white.withValues(alpha: 0.03),
                                  width: 1,
                                ),
                                boxShadow: isCompleted
                                    ? [
                                        BoxShadow(
                                          color: p[3].withValues(alpha: 0.2),
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : [],
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 106, // 5 columns * 18px + 4 gaps * 4px = 106px
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '5w ago',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        'Today',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            // Right: Consistency Stats (calculated over 30 days)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMiniStat('COMPLETION RATE', '$completionRate%', accentColor),
                  const SizedBox(height: 12),
                  _buildMiniStat('TOTAL ACTIVE', '$completedDaysCount / 30 days', accentColor),
                  const SizedBox(height: 12),
                  _buildMiniStat('WEEKLY AVERAGE', '${(completedDaysCount / 4.28).toStringAsFixed(1)} days', accentColor),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class ActiveDaysTarget extends ConsumerWidget {
  final Habit habit;
  final Color accentColor;

  const ActiveDaysTarget({
    super.key,
    required this.habit,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final activeColor = AppTheme.accentMagenta;
    final activeDaysList = (habit.activeDays as List?)?.cast<int>() ?? const [1, 2, 3, 4, 5, 6, 7];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(PhosphorIconsFill.target, color: accentColor, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Active Days Target',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const Text(
              'Tap to toggle',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Weekdays row
        Row(
          children: List.generate(7, (index) {
            final dayNumber = index + 1;
            final isSelected = activeDaysList.contains(dayNumber);

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index < 6 ? 8.0 : 0.0),
                child: GestureDetector(
                  onTap: () {
                    final currentActive = List<int>.from(activeDaysList);
                    if (currentActive.contains(dayNumber)) {
                      currentActive.remove(dayNumber);
                    } else {
                      currentActive.add(dayNumber);
                    }
                    currentActive.sort();
                    ref.read(habitsProvider.notifier).updateHabit(
                          habit.copyWith(activeDays: currentActive),
                        );
                  },
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? activeColor : AppTheme.surfaceLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.04),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        weekdays[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class FocusSessionDialog extends StatefulWidget {
  final Habit habit;

  const FocusSessionDialog({super.key, required this.habit});

  @override
  State<FocusSessionDialog> createState() => _FocusSessionDialogState();
}

class _FocusSessionDialogState extends State<FocusSessionDialog> {
  int selectedMinutes = 25;
  int secondsRemaining = 25 * 60;
  int totalSeconds = 25 * 60;
  Timer? timer;
  bool isRunning = false;
  bool hasStarted = false;

  void _startSession() {
    setState(() {
      totalSeconds = selectedMinutes * 60;
      secondsRemaining = totalSeconds;
      hasStarted = true;
      isRunning = true;
    });
    _startTimer();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        _completeSession();
      }
    });
  }

  void _toggleTimer() {
    if (isRunning) {
      timer?.cancel();
    } else {
      _startTimer();
    }
    setState(() {
      isRunning = !isRunning;
    });
  }

  void _completeSession() {
    timer?.cancel();
    final container = ProviderScope.containerOf(context);
    final selectedDate = container.read(selectedDateProvider);
    final double addVal = widget.habit.type == HabitType.boolean
        ? widget.habit.targetValue
        : 1.0;

    container.read(habitRecordsProvider.notifier).addProgress(
          widget.habit.id,
          selectedDate,
          addVal,
          widget.habit,
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Focus Session completed for "${widget.habit.title}"!'),
        backgroundColor: Color(widget.habit.colorHex),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(widget.habit.colorHex);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: hasStarted ? _buildTimerView(accentColor) : _buildSelectionView(accentColor),
      ),
    );
  }

  Widget _buildSelectionView(Color accentColor) {
    final durations = [5, 10, 15, 25, 45, 60];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Select Duration',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          widget.habit.title,
          style: TextStyle(
            color: accentColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: durations.map((mins) {
            final isSelected = selectedMinutes == mins;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedMinutes = mins;
                });
              },
              child: Container(
                width: 90,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? accentColor.withValues(alpha: 0.15) : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? accentColor : Colors.white.withValues(alpha: 0.05),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$mins min',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        // Start Button
        GestureDetector(
          onTap: _startSession,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Start Session',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Cancel Button
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerView(Color accentColor) {
    final min = (secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final sec = (secondsRemaining % 60).toString().padLeft(2, '0');
    final progress = (totalSeconds - secondsRemaining) / totalSeconds;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Focus Session',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.habit.title,
          style: TextStyle(
            color: accentColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 32),
        // Countdown circle
        SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
              Text(
                '$min:$sec',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _toggleTimer,
              iconSize: 28,
              style: IconButton.styleFrom(
                backgroundColor: accentColor.withValues(alpha: 0.15),
                foregroundColor: accentColor,
                padding: const EdgeInsets.all(12),
              ),
              icon: Icon(
                isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: _completeSession,
              iconSize: 28,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.06),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(12),
              ),
              icon: const Icon(Icons.check_rounded),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () => Navigator.pop(context),
              iconSize: 28,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.06),
                foregroundColor: Colors.white54,
                padding: const EdgeInsets.all(12),
              ),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      ],
    );
  }
}
