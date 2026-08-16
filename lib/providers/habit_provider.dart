import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../services/notification_service.dart';
import '../services/home_widget_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

// Theme Mode Provider (Light/Dark)
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;
  static const _key = 'theme_mode';

  ThemeModeNotifier(this._prefs) : super(ThemeMode.dark) {
    final isLight = _prefs.getBool(_key) ?? false;
    if (isLight) state = ThemeMode.light;
  }

  void toggle() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _prefs.setBool(_key, state == ThemeMode.light);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

// Gamification: Calculate total completed habits for XP/Levels
final userLevelProvider = Provider<int>((ref) {
  final records = ref.watch(habitRecordsProvider);
  int totalCompleted = 0;
  for (final dayRecords in records.values) {
    for (final record in dayRecords.values) {
      if (record.isCompleted) totalCompleted++;
    }
  }
  
  // Easy at first, gets very hard. Max level 500.
  // Using formula: Level = (completions / 1.1) ^ 0.65 + 1
  if (totalCompleted == 0) return 1;
  
  double level = math.pow(totalCompleted / 1.1, 0.65) + 1;
  int finalLevel = level.floor();
  
  return finalLevel > 500 ? 500 : finalLevel;
});

final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day); // Default to today
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'All Habits');

final habitsProvider = StateNotifierProvider<HabitNotifier, List<Habit>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return HabitNotifier(prefs);
});

final habitRecordsProvider = StateNotifierProvider<HabitRecordNotifier, Map<String, Map<String, HabitRecord>>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return HabitRecordNotifier(prefs);
});

// Computes a user's current daily streak (days where at least 1 habit was completed)
final globalStreakProvider = Provider<int>((ref) {
  final records = ref.watch(habitRecordsProvider);
  final habits = ref.watch(habitsProvider).where((h) => !h.isArchived).toList();
  if (habits.isEmpty) return 0;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  int streak = 0;

  for (int i = 0; i < 365; i++) {
    final date = today.subtract(Duration(days: i));
    final dateKey = HabitRecordNotifier.dateKey(date);
    final dayRecords = records[dateKey] ?? {};
    final anyCompleted = dayRecords.values.any((r) => r.isCompleted);
    if (anyCompleted) {
      streak++;
    } else {
      // Allow gap only on today (user might not have done it yet)
      if (i > 0) break;
    }
  }
  return streak;
});

class HabitNotifier extends StateNotifier<List<Habit>> {
  final SharedPreferences _prefs;
  static const _key = 'habits_data';

  HabitNotifier(this._prefs) : super(_initialHabits) {
    _load();
  }

  void _load() {
    final data = _prefs.getStringList(_key);
    if (data != null) {
      state = data.map((e) => Habit.fromJson(jsonDecode(e))).toList();
    }
  }

  void _save() {
    final data = state.map((e) => jsonEncode(e.toJson())).toList();
    _prefs.setStringList(_key, data);
  }

  void addHabit(Habit habit) {
    state = [...state, habit];
    _save();
    _handleNotification(habit);
  }

  void updateHabit(Habit habit) {
    state = state.map((h) => h.id == habit.id ? habit : h).toList();
    _save();
    _handleNotification(habit);
  }

  void removeHabit(String id) {
    state = state.where((h) => h.id != id).toList();
    _save();
    NotificationService().cancelReminder(id);
  }

  void _handleNotification(Habit habit) {
    if (habit.reminderTime != null && !habit.isArchived) {
      final parts = habit.reminderTime!.split(':');
      if (parts.length == 2) {
        NotificationService().scheduleDailyHabitReminder(
          habit.id,
          habit.title,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
      }
    } else {
      NotificationService().cancelReminder(habit.id);
    }
  }

  void toggleArchive(String id) {
    state = state.map((h) {
      if (h.id == id) {
        return h.copyWith(isArchived: !h.isArchived);
      }
      return h;
    }).toList();
    _save();
  }

  void reorderHabits(int oldIndex, int newIndex) {
    final habits = List<Habit>.from(state);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = habits.removeAt(oldIndex);
    habits.insert(newIndex, item);
    
    // Update orderIndex for all items
    for (int i = 0; i < habits.length; i++) {
      habits[i] = habits[i].copyWith(orderIndex: i);
    }
    
    state = habits;
    _save();
  }

  void clearAll() {
    state = [];
    _prefs.remove(_key);
  }

  // Start fresh — no pre-loaded sample data
  static final List<Habit> _initialHabits = [];
}

class HabitRecordNotifier extends StateNotifier<Map<String, Map<String, HabitRecord>>> {
  final SharedPreferences _prefs;
  static const _key = 'habit_records_data';

  HabitRecordNotifier(this._prefs) : super({}) {
    _load();
  }

  static String dateKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _load() {
    final dataString = _prefs.getString(_key);
    if (dataString != null) {
      final decoded = jsonDecode(dataString) as Map<String, dynamic>;
      final map = <String, Map<String, HabitRecord>>{};
      decoded.forEach((dateKey, dayData) {
        final dayMap = <String, HabitRecord>{};
        (dayData as Map<String, dynamic>).forEach((habitId, recordData) {
          dayMap[habitId] = HabitRecord.fromJson(recordData);
        });
        map[dateKey] = dayMap;
      });
      state = map;
    }
  }

  void _save() {
    final encodedMap = <String, Map<String, dynamic>>{};
    state.forEach((dateKey, dayMap) {
      final dayData = <String, dynamic>{};
      dayMap.forEach((habitId, record) {
        dayData[habitId] = record.toJson();
      });
      encodedMap[dateKey] = dayData;
    });
    _prefs.setString(_key, jsonEncode(encodedMap));
  }

  void addProgress(String habitId, DateTime date, double value, Habit habit) {
    final dKey = dateKey(date);
    final currentRecords = Map<String, Map<String, HabitRecord>>.from(state);
    
    if (!currentRecords.containsKey(dKey)) {
      currentRecords[dKey] = {};
    }
    
    final dayRecords = Map<String, HabitRecord>.from(currentRecords[dKey]!);
    final record = dayRecords[habitId] ?? HabitRecord(habitId: habitId, date: date);
    
    double newValue = record.currentValue + value;
    if (newValue > habit.targetValue) newValue = habit.targetValue;
    if (newValue < 0) newValue = 0;
    
    final isCompleted = newValue >= habit.targetValue;
    
    dayRecords[habitId] = record.copyWith(
      currentValue: newValue,
      isCompleted: isCompleted,
    );
    
    currentRecords[dKey] = dayRecords;
    state = currentRecords;
    _save();
  }

  void resetProgress(String habitId, DateTime date) {
    final dKey = dateKey(date);
    final currentRecords = Map<String, Map<String, HabitRecord>>.from(state);
    if (!currentRecords.containsKey(dKey)) return;

    final dayRecords = Map<String, HabitRecord>.from(currentRecords[dKey]!);
    if (dayRecords.containsKey(habitId)) {
      dayRecords[habitId] = dayRecords[habitId]!.copyWith(currentValue: 0.0, isCompleted: false);
      currentRecords[dKey] = dayRecords;
      state = currentRecords;
      _save();
    }
  }
  
  void clearAll() {
    state = {};
    _prefs.remove(_key);
  }
}
