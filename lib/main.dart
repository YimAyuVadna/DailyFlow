import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

import 'providers/habit_provider.dart';
import 'services/notification_service.dart';
import 'services/home_widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.registerBackgroundCallback(backgroundCallback);

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const DailyFlowApp(),
    ),
  );

  unawaited(_initializeNotifications());
}

Future<void> _initializeNotifications() async {
  try {
    await NotificationService().init();
    await NotificationService().requestPermissions();
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'habitflow startup',
        context: ErrorDescription(
          'Notification initialization failed during app startup.',
        ),
      ),
    );
  }
}

class DailyFlowApp extends ConsumerWidget {
  const DailyFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(homeWidgetUpdaterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'DailyFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}
