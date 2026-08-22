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
    await updateAllWidgets(habits: habits, records: records, globalStreak: globalStreak);
  }

  static Future<void> updateWidgetForInstance({
    required String widgetId,
    required List<Habit> habits,
    required Map<String, Map<String, HabitRecord>> records,
    required int globalStreak,
    required String? widgetSelectedHabitId,
  }) async {
    await updateAllWidgets(habits: habits, records: records, globalStreak: globalStreak);
  }

  static Future<void> updateAllWidgets({
    required List<Habit> habits,
    required Map<String, Map<String, HabitRecord>> records,
    required int globalStreak,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    final types = ['streak', 'flow', 'focus', 'priority', 'circadian', 'master_grid', 'lock_ring', 'lock_streak'];
    
    for (final type in types) {
      final activeIdsString = prefs.getString('active_widget_ids_list_$type') ?? '';
      final activeIds = activeIdsString.split(',').where((s) => s.isNotEmpty).toList();
      
      // Check legacy/default list for streak widgets too
      if (type == 'streak') {
        final legacyIdsString = prefs.getString('active_widget_ids_list') ?? '';
        final legacyIds = legacyIdsString.split(',').where((s) => s.isNotEmpty).toList();
        activeIds.addAll(legacyIds);
      }
      
      if (activeIds.isEmpty) {
        // Render fallback image
        await _renderWidgetImage(
          widgetId: null,
          type: type,
          habits: habits,
          records: records,
          globalStreak: globalStreak,
          widgetSelectedHabitId: prefs.getString('widget_selected_habit_id'),
        );
      } else {
        for (final widgetId in activeIds) {
          final habitId = prefs.getString('widget_selected_habit_id_$widgetId');
          await _renderWidgetImage(
            widgetId: widgetId,
            type: type,
            habits: habits,
            records: records,
            globalStreak: globalStreak,
            widgetSelectedHabitId: habitId,
          );
        }
      }

      // Notify Android to refresh this specific provider
      final String androidProviderName;
      if (type == 'streak') {
        androidProviderName = 'StreakWidgetProvider';
        // Redraw legacy widget too just in case
        await HomeWidget.updateWidget(
          name: 'HabitWidgetProvider',
          iOSName: 'HabitWidget',
        );
      } else if (type == 'flow') {
        androidProviderName = 'DailyFlowWidgetProvider';
      } else if (type == 'focus') {
        androidProviderName = 'QuickFocusWidgetProvider';
      } else if (type == 'priority') {
        androidProviderName = 'PriorityHabitsWidgetProvider';
      } else if (type == 'circadian') {
        androidProviderName = 'CircadianWidgetProvider';
      } else if (type == 'master_grid') {
        androidProviderName = 'MasterGridWidgetProvider';
      } else if (type == 'lock_ring') {
        androidProviderName = 'LockRingWidgetProvider';
      } else if (type == 'lock_streak') {
        androidProviderName = 'LockStreakWidgetProvider';
      } else {
        androidProviderName = 'StreakWidgetProvider';
      }

      await HomeWidget.updateWidget(
        name: androidProviderName,
        iOSName: 'HabitWidget',
      );
    }
  }

  static Future<void> _renderWidgetImage({
    required String? widgetId,
    required String type,
    required List<Habit> habits,
    required Map<String, Map<String, HabitRecord>> records,
    required int globalStreak,
    required String? widgetSelectedHabitId,
  }) async {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final dayRecords = records[dateKey] ?? {};

    final selectedHabit = widgetSelectedHabitId != null
        ? habits.cast<Habit?>().firstWhere((h) => h?.id == widgetSelectedHabitId, orElse: () => null)
        : null;

    // 1. Calculate values for Streak
    final double currentProgress;
    final double targetProgress;
    final String unit;
    final int streak;
    if (selectedHabit != null) {
      final record = dayRecords[selectedHabit.id];
      currentProgress = record?.currentValue ?? 0.0;
      targetProgress = selectedHabit.targetValue;
      unit = selectedHabit.unit.isEmpty ? 'done' : selectedHabit.unit;
      streak = selectedHabit.streak;
    } else {
      final firstHabit = habits.where((h) => !h.isArchived).firstOrNull;
      currentProgress = firstHabit != null ? (dayRecords[firstHabit.id]?.currentValue ?? 0.0) : 0.0;
      targetProgress = firstHabit != null ? firstHabit.targetValue : 1.0;
      unit = firstHabit != null && firstHabit.unit.isNotEmpty ? firstHabit.unit : 'done';
      streak = firstHabit != null ? firstHabit.streak : 0;
    }

    // 2. Calculate values for Flow
    final activeHabits = habits.where((h) => !h.isArchived).toList();
    int completedCount = 0;
    for (final habit in activeHabits) {
      if (dayRecords[habit.id]?.isCompleted == true) {
        completedCount++;
      }
    }
    final totalCount = activeHabits.length;

    // 3. Calculate values for LockStreak
    final Habit? nextIncomplete = activeHabits.cast<Habit?>().firstWhere(
      (h) => dayRecords[h?.id]?.isCompleted != true,
      orElse: () => null,
    );
    final nextHabitTitle = nextIncomplete?.title ?? 'None';
    final nextHabitDuration = nextIncomplete != null
        ? (nextIncomplete.type == HabitType.numeric ? '${nextIncomplete.targetValue.toInt()} ${nextIncomplete.unit}' : '10m')
        : 'None';

    final Widget widgetToRender;
    final Size logicalSize;

    switch (type) {
      case 'streak':
        widgetToRender = StreakWidget(
          habit: selectedHabit ?? habits.where((h) => !h.isArchived).firstOrNull,
          currentProgress: currentProgress,
          targetProgress: targetProgress,
          unit: unit,
          streak: streak,
        );
        logicalSize = const Size(160, 160);
        break;
      case 'flow':
        widgetToRender = DailyFlowWidget(
          completedCount: completedCount,
          totalCount: totalCount,
        );
        logicalSize = const Size(160, 160);
        break;
      case 'focus':
        widgetToRender = const QuickFocusWidget();
        logicalSize = const Size(160, 160);
        break;
      case 'priority':
        widgetToRender = PriorityHabitsWidget(
          habits: activeHabits,
          records: records,
        );
        logicalSize = const Size(320, 160);
        break;
      case 'circadian':
        widgetToRender = const CircadianWidget();
        logicalSize = const Size(320, 160);
        break;
      case 'master_grid':
        widgetToRender = MasterGridWidget(
          habits: activeHabits,
          records: records,
        );
        logicalSize = const Size(320, 320);
        break;
      case 'lock_ring':
        widgetToRender = LockRingWidget(
          completedCount: completedCount,
          totalCount: totalCount,
        );
        logicalSize = const Size(160, 72);
        break;
      case 'lock_streak':
        widgetToRender = LockStreakWidget(
          bestStreak: globalStreak,
          nextHabitTitle: nextHabitTitle,
          nextHabitDuration: nextHabitDuration,
        );
        logicalSize = const Size(160, 72);
        break;
      default:
        widgetToRender = StreakWidget(
          habit: selectedHabit ?? habits.where((h) => !h.isArchived).firstOrNull,
          currentProgress: currentProgress,
          targetProgress: targetProgress,
          unit: unit,
          streak: streak,
        );
        logicalSize = const Size(160, 160);
    }

    final key = widgetId != null ? 'widget_image_${type}_$widgetId' : 'widget_image_$type';
    await HomeWidget.renderFlutterWidget(
      widgetToRender,
      key: key,
      logicalSize: logicalSize,
    );
  }
}
