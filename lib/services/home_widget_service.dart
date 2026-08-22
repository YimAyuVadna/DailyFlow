import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/habit.dart';
import '../widgets/app_home_widget.dart';
import '../utils/icon_helper.dart';

@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (uri?.host == 'updateprogress') {
    final appWidgetId = uri?.queryParameters['appWidgetId'];
    if (appWidgetId == null) return;

    final isConfigure = uri?.queryParameters['configure'] == 'true';
    final selectedHabitId = await HomeWidget.getWidgetData<String>('widget_selected_habit_id_$appWidgetId');

    if (isConfigure) {
      final prefs = await SharedPreferences.getInstance();
      final habitsData = prefs.getStringList('habits_data');
      final habits = habitsData?.map((e) => Habit.fromJson(jsonDecode(e))).toList() ?? [];

      final recordsData = prefs.getString('habit_records_data');
      final Map<String, Map<String, HabitRecord>> records = {};
      if (recordsData != null) {
        final decoded = jsonDecode(recordsData) as Map<String, dynamic>;
        decoded.forEach((dateKey, dayData) {
          final dayMap = <String, HabitRecord>{};
          (dayData as Map<String, dynamic>).forEach((hId, recordData) {
            dayMap[hId] = HabitRecord.fromJson(recordData);
          });
          records[dateKey] = dayMap;
        });
      }

      int streak = 0;
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      for (int i = 0; i < 365; i++) {
        final date = todayDate.subtract(Duration(days: i));
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final dayRecs = records[dateKey] ?? {};
        final anyCompleted = dayRecs.values.any((r) => r.isCompleted);
        if (anyCompleted) {
          streak++;
        } else {
          if (i > 0) break;
        }
      }

      await HomeWidgetService.updateWidgetForInstance(
        widgetId: appWidgetId,
        habits: habits,
        records: records,
        globalStreak: streak,
        widgetSelectedHabitId: selectedHabitId,
      );
      return;
    }

    if (selectedHabitId == null) return; // Cannot update progress on all-habit view

    final prefs = await SharedPreferences.getInstance();

    // Read habits
    final habitsData = prefs.getStringList('habits_data');
    if (habitsData == null) return;
    final habits = habitsData.map((e) => Habit.fromJson(jsonDecode(e))).toList();
    final habit = habits.cast<Habit?>().firstWhere((h) => h?.id == selectedHabitId, orElse: () => null);
    if (habit == null || habit.isArchived) return;

    // Read records
    final recordsData = prefs.getString('habit_records_data');
    final Map<String, Map<String, HabitRecord>> records = {};
    if (recordsData != null) {
      final decoded = jsonDecode(recordsData) as Map<String, dynamic>;
      decoded.forEach((dateKey, dayData) {
        final dayMap = <String, HabitRecord>{};
        (dayData as Map<String, dynamic>).forEach((hId, recordData) {
          dayMap[hId] = HabitRecord.fromJson(recordData);
        });
        records[dateKey] = dayMap;
      });
    }

    // Update progress for today
    final today = DateTime.now();
    final dKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    if (!records.containsKey(dKey)) {
      records[dKey] = {};
    }
    
    final dayRecords = Map<String, HabitRecord>.from(records[dKey]!);
    final record = dayRecords[selectedHabitId] ?? HabitRecord(habitId: selectedHabitId, date: today);
    
    double newValue = record.currentValue;
    bool isCompleted = record.isCompleted;

    if (habit.type == HabitType.boolean) {
      // Toggle boolean habit
      isCompleted = !isCompleted;
      newValue = isCompleted ? 1.0 : 0.0;
    } else {
      double incrementAmount = 1.0;
      if (habit.type == HabitType.numeric) {
        final unit = habit.unit.toLowerCase();
        if (unit == 'ml') {
          incrementAmount = 250.0;
        } else if (unit == 'mins' || unit == 'min') {
          incrementAmount = 10.0;
        } else if (unit == 'pages' || unit == 'page') {
          incrementAmount = 5.0;
        } else if (unit == 'steps' || unit == 'step') {
          incrementAmount = 1000.0;
        }
      }

      // Increment by incrementAmount (or toggle back to 0 if already completed)
      if (newValue >= habit.targetValue) {
        newValue = 0.0;
        isCompleted = false;
      } else {
        newValue = (newValue + incrementAmount).clamp(0.0, habit.targetValue);
        isCompleted = newValue >= habit.targetValue;
      }
    }

    dayRecords[selectedHabitId] = record.copyWith(
      currentValue: newValue,
      isCompleted: isCompleted,
    );
    records[dKey] = dayRecords;

    // Save records back to SharedPreferences
    final encodedMap = <String, Map<String, dynamic>>{};
    records.forEach((dateKey, dayMap) {
      final dayData = <String, dynamic>{};
      dayMap.forEach((hId, rec) {
        dayData[hId] = rec.toJson();
      });
      encodedMap[dateKey] = dayData;
    });
    await prefs.setString('habit_records_data', jsonEncode(encodedMap));

    // Calculate global streak (required for widget update)
    int streak = 0;
    final todayDate = DateTime(today.year, today.month, today.day);
    for (int i = 0; i < 365; i++) {
      final date = todayDate.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final dayRecs = records[dateKey] ?? {};
      final anyCompleted = dayRecs.values.any((r) => r.isCompleted);
      if (anyCompleted) {
        streak++;
      } else {
        if (i > 0) break;
      }
    }

    // Render and update the specific widget
    await HomeWidgetService.updateWidgetForInstance(
      widgetId: appWidgetId,
      habits: habits,
      records: records,
      globalStreak: streak,
      widgetSelectedHabitId: selectedHabitId,
    );

    // Also update all other active widgets to keep everything in sync
    final activeIdsString = await HomeWidget.getWidgetData<String>('active_widget_ids_list') ?? '';
    final activeIds = activeIdsString.split(',').where((s) => s.isNotEmpty).toList();
    for (final id in activeIds) {
      if (id == appWidgetId) continue;
      final habitId = await HomeWidget.getWidgetData<String>('widget_selected_habit_id_$id');
      await HomeWidgetService.updateWidgetForInstance(
        widgetId: id,
        habits: habits,
        records: records,
        globalStreak: streak,
        widgetSelectedHabitId: habitId,
      );
    }
    
    // Also update the default fallback widget image
    final defaultHabitId = await HomeWidget.getWidgetData<String>('widget_selected_habit_id');
    await HomeWidgetService.updateWidget(
      habits: habits,
      records: records,
      globalStreak: streak,
      widgetSelectedHabitId: defaultHabitId,
    );
  }
}

class HomeWidgetService {
  static const String appGroupId = '<YOUR_APP_GROUP>';
  static const String androidWidgetName = 'HabitWidgetProvider';

  static Future<void> updateWidget({
    required List<Habit> habits,
    required Map<String, Map<String, HabitRecord>> records,
    required int globalStreak,
    required String? widgetSelectedHabitId,
  }) async {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final dayRecords = records[dateKey] ?? {};

    String title;
    String subtitle;
    double percent;
    int streak;
    IconData icon;
    Color iconColor;

    final selectedHabit = widgetSelectedHabitId != null
        ? habits.cast<Habit?>().firstWhere((h) => h?.id == widgetSelectedHabitId, orElse: () => null)
        : null;

    if (selectedHabit != null) {
      final record = dayRecords[selectedHabit.id];
      final currentValue = record?.currentValue ?? 0.0;
      final targetValue = selectedHabit.targetValue;
      final isCompleted = record?.isCompleted ?? false;

      title = selectedHabit.title;
      percent = targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
      streak = selectedHabit.streak;
      icon = getHabitIcon(selectedHabit.iconName);
      iconColor = Color(selectedHabit.colorHex);

      if (selectedHabit.type == HabitType.boolean) {
        subtitle = isCompleted ? 'Completed' : 'Pending';
      } else {
        final currentStr = currentValue.toStringAsFixed(1).replaceAll('.0', '');
        final targetStr = targetValue.toStringAsFixed(1).replaceAll('.0', '');
        subtitle = '$currentStr / $targetStr ${selectedHabit.unit}';
      }
    } else {
      final activeHabits = habits.where((h) => !h.isArchived).toList();
      int completed = 0;
      for (final habit in activeHabits) {
        if (dayRecords[habit.id]?.isCompleted == true) {
          completed++;
        }
      }
      final total = activeHabits.length;

      title = 'Daily Momentum';
      subtitle = '$completed / $total';
      percent = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
      streak = globalStreak;
      icon = PhosphorIconsFill.fire;
      iconColor = const Color(0xFF00FFB2);
    }

    // Render the flutter widget to an image
    await HomeWidget.renderFlutterWidget(
      DailyProgressWidget(
        title: title,
        subtitle: subtitle,
        percent: percent,
        streak: streak,
        icon: icon,
        iconColor: iconColor,
      ),
      key: 'widget_image',
      logicalSize: const Size(250, 110),
    );

    // Trigger the update to Android
    await HomeWidget.updateWidget(
      name: androidWidgetName,
      iOSName: 'HabitWidget',
    );
  }

  static Future<void> updateWidgetForInstance({
    required String widgetId,
    required List<Habit> habits,
    required Map<String, Map<String, HabitRecord>> records,
    required int globalStreak,
    required String? widgetSelectedHabitId,
  }) async {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final dayRecords = records[dateKey] ?? {};

    String title;
    String subtitle;
    double percent;
    int streak;
    IconData icon;
    Color iconColor;

    final selectedHabit = widgetSelectedHabitId != null
        ? habits.cast<Habit?>().firstWhere((h) => h?.id == widgetSelectedHabitId, orElse: () => null)
        : null;

    if (selectedHabit != null) {
      final record = dayRecords[selectedHabit.id];
      final currentValue = record?.currentValue ?? 0.0;
      final targetValue = selectedHabit.targetValue;
      final isCompleted = record?.isCompleted ?? false;

      title = selectedHabit.title;
      percent = targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
      streak = selectedHabit.streak;
      icon = getHabitIcon(selectedHabit.iconName);
      iconColor = Color(selectedHabit.colorHex);

      if (selectedHabit.type == HabitType.boolean) {
        subtitle = isCompleted ? 'Completed' : 'Pending';
      } else {
        final currentStr = currentValue.toStringAsFixed(1).replaceAll('.0', '');
        final targetStr = targetValue.toStringAsFixed(1).replaceAll('.0', '');
        subtitle = '$currentStr / $targetStr ${selectedHabit.unit}';
      }
    } else {
      final activeHabits = habits.where((h) => !h.isArchived).toList();
      int completed = 0;
      for (final habit in activeHabits) {
        if (dayRecords[habit.id]?.isCompleted == true) {
          completed++;
        }
      }
      final total = activeHabits.length;

      title = 'Daily Momentum';
      subtitle = '$completed / $total';
      percent = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
      streak = globalStreak;
      icon = PhosphorIconsFill.fire;
      iconColor = const Color(0xFF00FFB2);
    }

    // Render the flutter widget to an image for this specific widgetId
    await HomeWidget.renderFlutterWidget(
      DailyProgressWidget(
        title: title,
        subtitle: subtitle,
        percent: percent,
        streak: streak,
        icon: icon,
        iconColor: iconColor,
      ),
      key: 'widget_image_$widgetId',
      logicalSize: const Size(250, 110),
    );

    // Trigger the update to Android
    await HomeWidget.updateWidget(
      name: androidWidgetName,
      iOSName: 'HabitWidget',
    );
  }
}
