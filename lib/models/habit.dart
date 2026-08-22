enum HabitType {
  boolean, // Just a checkmark
  numeric, // Has a target like 3000 ml or 10000 steps
  blocks,  // Has discrete blocks like 4 pomodoros
}

class Habit {
  final String id;
  final String title;
  final String subtitle;
  final HabitType type;
  final double targetValue;
  final String unit;
  final int streak; // Keeping this for backward compatibility or simple tracking
  final List<String> categories;
  final int colorHex;
  final String iconName;
  final int orderIndex;
  final bool isArchived;
  final String? reminderTime; // "HH:MM" format
  final String? timeOfDay; // "Morning", "Afternoon", "Evening", "Anytime"
  final List<int> activeDays;

  const Habit({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.targetValue,
    required this.unit,
    required this.streak,
    required this.categories,
    required this.colorHex,
    required this.iconName,
    this.orderIndex = 0,
    this.isArchived = false,
    this.reminderTime,
    this.timeOfDay = 'Anytime',
    this.activeDays = const [1, 2, 3, 4, 5, 6, 7],
  });

  Habit copyWith({
    String? id,
    String? title,
    String? subtitle,
    HabitType? type,
    double? targetValue,
    String? unit,
    int? streak,
    List<String>? categories,
    int? colorHex,
    String? iconName,
    int? orderIndex,
    bool? isArchived,
    String? reminderTime,
    String? timeOfDay,
    List<int>? activeDays,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      streak: streak ?? this.streak,
      categories: categories ?? this.categories,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      orderIndex: orderIndex ?? this.orderIndex,
      isArchived: isArchived ?? this.isArchived,
      reminderTime: reminderTime ?? this.reminderTime,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      activeDays: activeDays ?? this.activeDays,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'type': type.index,
      'targetValue': targetValue,
      'unit': unit,
      'streak': streak,
      'categories': categories,
      'colorHex': colorHex,
      'iconName': iconName,
      'orderIndex': orderIndex,
      'isArchived': isArchived,
      'reminderTime': reminderTime,
      'timeOfDay': timeOfDay,
      'activeDays': activeDays,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      type: HabitType.values[json['type'] as int],
      targetValue: (json['targetValue'] as num).toDouble(),
      unit: json['unit'] as String,
      streak: json['streak'] as int,
      categories: (json['categories'] as List).map((e) => e as String).toList(),
      colorHex: json['colorHex'] as int,
      iconName: json['iconName'] as String,
      orderIndex: json['orderIndex'] as int? ?? 0,
      isArchived: json['isArchived'] as bool? ?? false,
      reminderTime: json['reminderTime'] as String?,
      timeOfDay: json['timeOfDay'] as String? ?? 'Anytime',
      activeDays: json['activeDays'] != null
          ? (json['activeDays'] as List).map((e) => e as int).toList()
          : const [1, 2, 3, 4, 5, 6, 7],
    );
  }
}

class HabitRecord {
  final String habitId;
  final DateTime date;
  final double currentValue;
  final bool isCompleted;

  const HabitRecord({
    required this.habitId,
    required this.date,
    this.currentValue = 0.0,
    this.isCompleted = false,
  });

  HabitRecord copyWith({
    double? currentValue,
    bool? isCompleted,
  }) {
    return HabitRecord(
      habitId: habitId,
      date: date,
      currentValue: currentValue ?? this.currentValue,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'habitId': habitId,
      'date': date.toIso8601String(),
      'currentValue': currentValue,
      'isCompleted': isCompleted,
    };
  }

  factory HabitRecord.fromJson(Map<String, dynamic> json) {
    return HabitRecord(
      habitId: json['habitId'] as String,
      date: DateTime.parse(json['date'] as String),
      currentValue: (json['currentValue'] as num).toDouble(),
      isCompleted: json['isCompleted'] as bool,
    );
  }
}
