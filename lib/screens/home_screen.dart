import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../providers/habit_provider.dart';
import '../widgets/momentum_card.dart';
import '../widgets/weekly_calendar.dart';
import '../widgets/category_tabs.dart';
import '../widgets/habit_list_item.dart';
import '../widgets/activity_heatmap.dart';
import '../widgets/create_habit_sheet.dart';
import '../widgets/empty_state.dart';
import '../theme/app_theme.dart';
import 'settings_screen.dart';
import 'badges_screen.dart';
import '../widgets/achievement_unlocked_dialog.dart';
import 'package:auto_size_text/auto_size_text.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<List<String>>(unlockedBadgesProvider, (previous, next) {
      if (previous == null) return;
      final acknowledged = ref.read(acknowledgedBadgesProvider);
      final newlyUnlocked = next.where((id) => !previous.contains(id) && !acknowledged.contains(id)).toList();
      if (newlyUnlocked.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          for (final badgeId in newlyUnlocked) {
            final badge = allBadges.firstWhere((b) => b.id == badgeId);
            AchievementUnlockedDialog.show(context, badge);
            ref.read(acknowledgedBadgesProvider.notifier).acknowledgeBadge(badgeId);
          }
        });
      }
    });

    final habits = ref.watch(habitsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final globalStreak = ref.watch(globalStreakProvider);
    final userLevel = ref.watch(userLevelProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    var filteredHabits = habits.toList();
    filteredHabits.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    if (selectedCategory == 'Archived') {
      filteredHabits = filteredHabits.where((h) => h.isArchived).toList();
    } else {
      filteredHabits = filteredHabits.where((h) => !h.isArchived).toList();
      if (selectedCategory != 'All Habits') {
        filteredHabits = filteredHabits.where((h) => h.categories.contains(selectedCategory)).toList();
      }
    }

    final activeHabits = habits.where((h) => !h.isArchived).toList();
    final isEmpty = activeHabits.isEmpty;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── Top Header ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Date and Icon Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(PhosphorIconsRegular.calendarBlank,
                                color: AppTheme.getTextSecondary(context), size: 14),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('EEEE, MMM d').format(DateTime.now()),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.getTextSecondary(context),
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Badges Button
                            IconButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const BadgesScreen()));
                              },
                              icon: Icon(
                                PhosphorIconsRegular.trophy,
                                color: AppTheme.getTextSecondary(context),
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 16),
                            // Settings button
                            IconButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                              },
                              icon: Icon(
                                PhosphorIconsRegular.gear,
                                color: AppTheme.getTextSecondary(context),
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Bottom row: Title and Badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            "Today's Flow",
                            style: Theme.of(context).textTheme.displayMedium,
                            maxLines: 1,
                            minFontSize: 18,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            // Level badge
                            _HeaderBadge(
                              icon: PhosphorIconsFill.star,
                              label: 'LVL $userLevel',
                              color: AppTheme.accentNeonGreen,
                              bgColor: isDark
                                  ? AppTheme.accentNeonGreen.withValues(alpha: 0.12)
                                  : AppTheme.accentNeonGreen.withValues(alpha: 0.1),
                            ),
                            const SizedBox(width: 8),
                            // Real streak badge
                            _HeaderBadge(
                              icon: PhosphorIconsFill.fire,
                              label: globalStreak > 0 ? '$globalStreak DAY${globalStreak != 1 ? 'S' : ''}' : 'NO STREAK',
                              color: AppTheme.accentOrange,
                              bgColor: isDark
                                  ? const Color(0xFF2C221F)
                                  : AppTheme.accentOrange.withValues(alpha: 0.08),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ─── Stats + Calendar (only when there are habits) ─────────────
            if (!isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MomentumCard(),
                      const SizedBox(height: 24),
                      Text('Weekly Consistency',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.getTextSecondary(context),
                              )),
                      const SizedBox(height: 10),
                      const WeeklyCalendar(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

            // ─── Category tabs ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: const CategoryTabs(),
              ),
            ),

            // ─── Empty state ───────────────────────────────────────────────
            if (isEmpty && selectedCategory == 'All Habits')
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(),
              )
            else if (filteredHabits.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Center(
                    child: Text(
                      selectedCategory == 'Archived'
                          ? 'No archived habits yet.'
                          : 'No habits in this category.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              )
            else ...[
              // ─── Habit list (draggable) ─────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverReorderableList(
                  itemCount: filteredHabits.length,
                  onReorder: (oldIndex, newIndex) {
                    ref.read(habitsProvider.notifier).reorderHabits(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final habit = filteredHabits[index];
                    return ReorderableDelayedDragStartListener(
                      key: Key(habit.id),
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: HabitListItem(habit: habit),
                      ),
                    );
                  },
                ),
              ),
            ],

            // ─── Add Button + Heatmap ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Add habit button
                    Container(
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.accentMagenta, AppTheme.accentBlue],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentMagenta.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const CreateHabitSheet(),
                            );
                          },
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_rounded, color: Colors.white, size: 22),
                                SizedBox(width: 8),
                                Text(
                                  'Add New Habit',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const ActivityHeatmap(),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _HeaderBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
