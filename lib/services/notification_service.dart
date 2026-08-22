import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  // 30 personalized reminder messages
  final List<String> _reminders = [
    "Your habit is waiting. Let's keep that streak alive!",
    "Ready to build some momentum? It only takes a few minutes.",
    "Consistency is the secret to greatness. You've got this!",
    "Be 1% better today. Time for your habit!",
    "Your future self will thank you for taking action right now.",
    "Small steps lead to massive achievements. Let's check this off.",
    "Don't break the chain! Your rhythm is looking amazing.",
    "A perfect day starts with perfect consistency. Step up!",
    "Time to lock in your daily check-in. Keep the flow going!",
    "Streaks are built one day at a time. Make today count.",
    "No distractions. Just pure focus. Let's do this!",
    "Consistency is key. Time to get to work.",
    "Make your habits a priority. Success is a daily choice.",
    "Fuel your momentum matrix! Let's do your habit.",
    "Tap to check this off and claim your consistency score.",
    "Almost done? Log your progress and keep winning.",
    "The secret of your future is hidden in your daily routine.",
    "Keep showing up. Even small actions count today.",
    "Ready, set, flow! Time to complete your daily ritual.",
    "You are building a powerful system. Don't stop now.",
    "Your habits define you. Let's make today a masterpiece.",
    "Time to check in. Let's keep the streak fire burning!",
    "A quick win is waiting for you. Let's check it off.",
    "Discipline beats motivation every single time. Let's go!",
    "One step closer to your goals. Time for your habit.",
    "Keep the rhythm active. You are doing fantastic.",
    "Unlock your potential. Start your session now.",
    "Time for a quick focus boost. You've got this!",
    "Action breeds confidence. Take action right now.",
    "Keep the momentum high. Time for your habit check-in!"
  ];

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: settings);
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  String getRandomReminderBody() {
    final random = Random();
    return _reminders[random.nextInt(_reminders.length)];
  }

  Future<void> scheduleDailyHabitReminder(
    String habitId,
    String title,
    int hour,
    int minute,
  ) async {
    final int notifId = habitId.hashCode;
    final randomBody = getRandomReminderBody();

    await _plugin.zonedSchedule(
      id: notifId,
      title: 'Habit Reminder: $title',
      body: randomBody,
      scheduledDate: _nextInstanceOfTime(hour, minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Habit Reminders',
          channelDescription: 'Daily reminders for your habits',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelReminder(String habitId) async {
    await _plugin.cancel(id: habitId.hashCode);
  }

  Future<void> showAllHabitsCompletedNotification() async {
    const notifId = 99999;
    await _plugin.show(
      id: notifId,
      title: '⚡ MOMENTUM HIGH',
      body: 'All Habits Crushed! 🌟 Outstanding consistency! Keep it up.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Habit Reminders',
          channelDescription: 'Daily reminders for your habits',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
