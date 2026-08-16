import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';

class HabitDetailsScreen extends ConsumerWidget {
  final Habit habit;

  const HabitDetailsScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(habitRecordsProvider);
    final accentColor = Color(habit.colorHex);

    // Calculate last 7 days of data for the chart
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final List<BarChartGroupData> barGroups = [];
    double maxY = habit.targetValue > 0 ? habit.targetValue : 1.0;
    
    int currentStreak = 0;
    int maxStreak = 0;
    int completedDays = 0;
    int totalDays = 30;

    // Calculate streaks for the last 30 days
    int tempStreak = 0;
    for (int i = totalDays - 1; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateKey = HabitRecordNotifier.dateKey(date);
      final dayRecords = records[dateKey] ?? {};
      final record = dayRecords[habit.id];
      
      if (record != null && record.isCompleted) {
        completedDays++;
        tempStreak++;
      } else {
        tempStreak = 0;
      }
      
      if (tempStreak > maxStreak) {
        maxStreak = tempStreak;
      }
      if (i == 0) {
        currentStreak = tempStreak;
      }
    }

    // Chart data for last 7 days
    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: 6 - i));
      final dateKey = HabitRecordNotifier.dateKey(date);
      final dayRecords = records[dateKey] ?? {};
      final record = dayRecords[habit.id];
      
      final val = record != null ? record.currentValue : 0.0;
      if (val > maxY) maxY = val;
      
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: val,
              color: accentColor,
              width: 16,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: habit.targetValue > 0 ? habit.targetValue : 1.0,
                color: AppTheme.surfaceLight,
              ),
            ),
          ],
        ),
      );
    }

    final completionRate = totalDays > 0 ? (completedDays / totalDays * 100).toInt() : 0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(habit.title, style: const TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Performance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildStatCard(context, 'Current Streak', '$currentStreak', 'days', accentColor)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(context, 'Best Streak', '$maxStreak', 'days', accentColor)),
                ],
              ),
              const SizedBox(height: 12),
              _buildStatCard(context, '30-Day Completion', '$completionRate%', '', accentColor),
              const SizedBox(height: 32),
              Text(
                'Last 7 Days',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Container(
                height: 200,
                padding: const EdgeInsets.only(top: 20, right: 16, left: 16, bottom: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY * 1.2,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final date = today.subtract(Duration(days: 6 - value.toInt()));
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('E').format(date).substring(0, 1),
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: barGroups,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(color: color, fontWeight: FontWeight.bold),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(unit, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
