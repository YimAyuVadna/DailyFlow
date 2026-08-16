import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import '../models/habit.dart';
import '../widgets/app_home_widget.dart';

class HomeWidgetService {
  static const String appGroupId = '<YOUR_APP_GROUP>'; // Needed for iOS if we do it later
  static const String androidWidgetName = 'HabitWidgetProvider';

  static Future<void> updateWidget({
    required List<Habit> habits,
    required Map<String, Map<String, HabitRecord>> records,
    required int globalStreak,
  }) async {
    // 1. Calculate today's stats
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    final dayRecords = records[dateKey] ?? {};
    final activeHabits = habits.where((h) => !h.isArchived).toList();
    
    int completed = 0;
    for (final habit in activeHabits) {
      if (dayRecords[habit.id]?.isCompleted == true) {
        completed++;
      }
    }
    
    final total = activeHabits.length;

    // 2. Render the flutter widget to an image
    await HomeWidget.renderFlutterWidget(
      DailyProgressWidget(
        completed: completed,
        total: total,
        streak: globalStreak,
      ),
      key: 'widget_image', // This matches the ID in widget_layout.xml! Wait, HomeWidget saves to SharedPreferences, then native code reads it.
      logicalSize: const Size(250, 110),
    );

    // 3. Trigger the update to Android
    await HomeWidget.updateWidget(
      name: androidWidgetName,
      iOSName: 'HabitWidget', // Not set up yet
    );
  }
}
