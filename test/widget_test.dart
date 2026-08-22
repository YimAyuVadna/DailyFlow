import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:habitflow/main.dart';
import 'package:habitflow/providers/habit_provider.dart';
import 'package:habitflow/widgets/achievement_unlocked_dialog.dart';
import 'package:habitflow/screens/badges_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const DailyFlowApp(),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 6));

    expect(find.text("Today's Flow"), findsOneWidget);
  });

  testWidgets('AchievementUnlockedDialog renders correctly', (WidgetTester tester) async {
    final mockBadge = BadgeData(
      id: 'consistency',
      title: 'Momentum Builder',
      description: 'Maintained your habit discipline for 14 continuous days.',
      icon: PhosphorIconsFill.arrowsClockwise,
      color: Colors.blue,
      isUnlocked: (stats) => true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AchievementUnlockedDialog(badge: mockBadge),
        ),
      ),
    );

    expect(find.text('ACHIEVEMENT UNLOCKED!'), findsOneWidget);
    expect(find.text('UNCOMMON'), findsOneWidget);
    expect(find.text('+350 XP'), findsOneWidget);
    expect(find.text('Momentum Builder'), findsOneWidget);
    expect(find.text('Maintained your habit discipline for 14 continuous days.'), findsOneWidget);
    expect(find.text('Mastery Tier'), findsOneWidget);
    expect(find.text('SILVER TIER'), findsOneWidget);
    expect(find.text('CLAIM & EQUIP BADGE'), findsOneWidget);
  });
}
