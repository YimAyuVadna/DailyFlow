import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';

class WeeklyCalendar extends ConsumerWidget {
  const WeeklyCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Center the calendar on the selected date (3 days before, 3 days after)
    final start = selectedDate.subtract(const Duration(days: 3));
    
    final List<Map<String, dynamic>> days = List.generate(7, (index) {
      final date = start.add(Duration(days: index));
      String status = 'future';
      if (date.isBefore(today)) status = 'completed';
      if (date.isAtSameMomentAs(today)) status = 'completed'; // or 'current' if we want today to be distinct
      
      // We will define 'current' as the *selected* date.
      if (date.isAtSameMomentAs(selectedDate)) status = 'current';

      return {
        'day': DateFormat('E').format(date).substring(0, 1),
        'date': date.day,
        'status': status,
        'fullDate': date,
      };
    });

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.getSurface(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: days.map((d) {
          final isCurrent = d['status'] == 'current';
          final isCompleted = d['status'] == 'completed';
          final dateObj = d['fullDate'] as DateTime;

          return GestureDetector(
            onTap: () {
              ref.read(selectedDateProvider.notifier).state = dateObj;
            },
            child: Container(
            width: 42,
            height: 65,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppTheme.accentNeonGreen.withValues(alpha: 0.1)
                  : (isCurrent ? AppTheme.getSurfaceLight(context) : Theme.of(context).scaffoldBackgroundColor),
              gradient: isCurrent
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.accentMagenta.withValues(alpha: 0.2),
                        Colors.transparent
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: isCurrent
                  ? Border.all(color: AppTheme.accentMagenta, width: 2)
                  : Border.all(color: Colors.transparent, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  d['day'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isCurrent || isCompleted
                        ? AppTheme.accentNeonGreen
                        : AppTheme.getTextSecondary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  d['date'].toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isCurrent || isCompleted
                        ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                        : AppTheme.getTextSecondary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isCurrent || isCompleted
                        ? AppTheme.accentNeonGreen
                        : AppTheme.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ));
        }).toList(),
      ),
    );
  }
}
