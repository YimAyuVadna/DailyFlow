import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';
import '../screens/habit_details_screen.dart';
import 'create_habit_sheet.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'shimmer_track.dart';

import '../utils/icon_helper.dart';

class HabitListItem extends ConsumerWidget {
  final Habit habit;

  const HabitListItem({super.key, required this.habit});

  Color get _accentColor => Color(habit.colorHex);

  IconData get _icon => getHabitIcon(habit.iconName);

  // Smart format: "1,500 / 3,000 ml" or "10,000 / 10,000\nsteps"
  String _formatSubtitle(double current, double target, String unit) {
    final c = _formatNum(current, unit);
    final t = _formatNum(target, unit);
    if (unit.isEmpty) return '$c / $t';
    return '$c / $t\n$unit';
  }

  // Smart number: use k for steps/large counts, plain ml for hydration
  String _formatNum(double val, String unit) {
    final u = unit.toLowerCase();
    if (u == 'ml') {
      // Keep full number with comma grouping
      return val.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
    }
    if (u == 'steps' || u == 'step') {
      // Use k notation
      if (val >= 1000) {
        final k = val / 1000;
        return '${k == k.toInt() ? k.toInt() : k.toStringAsFixed(1)}k';
      }
      return val.toInt().toString();
    }
    if (val == val.toInt()) return val.toInt().toString();
    return val.toStringAsFixed(1);
  }

  // Markers below bar: smart unit
  String _formatMarker(double val, String unit) {
    final u = unit.toLowerCase();
    if (u == 'steps' || u == 'step') {
      if (val >= 1000) {
        final k = val / 1000;
        return '${k == k.toInt() ? k.toInt() : k.toStringAsFixed(1)}k';
      }
      return val.toInt().toString();
    }
    if (u == 'ml') {
      if (val >= 1000) {
        final k = val / 1000;
        return '${k == k.toInt() ? k.toInt() : k.toStringAsFixed(1)}L';
      }
      return val.toInt().toString();
    }
    if (val >= 1000) {
      final k = val / 1000;
      return '${k == k.toInt() ? k.toInt() : k.toStringAsFixed(1)}k';
    }
    return val.toInt().toString();
  }

  // Quick add labels: "+250 ml" or "+2.5k" for steps
  String _quickLabel(double amount, String unit) {
    final u = unit.toLowerCase();
    if (u == 'ml') return '+${amount.toInt()} ml';
    if (u == 'steps' || u == 'step') {
      if (amount >= 1000) {
        final k = amount / 1000;
        return '+${k == k.toInt() ? k.toInt() : k.toStringAsFixed(1)}k';
      }
      return '+${amount.toInt()}';
    }
    if (amount == amount.toInt()) return '+${amount.toInt()} $unit';
    return '+${amount.toStringAsFixed(1)} $unit';
  }

  List<double> get _quickAddButtons {
    if (habit.type != HabitType.numeric) return [];
    final u = habit.unit.toLowerCase();
    if (u == 'ml') return [250, 500];
    if (u == 'mins' || u == 'min') return [10, 30];
    if (u == 'pages' || u == 'page') return [5, 10];
    if (u == 'steps' || u == 'step') return [1000, 2500];
    return [1];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(habitRecordsProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final dateKey = HabitRecordNotifier.dateKey(selectedDate);
    final dayRecords = records[dateKey] ?? {};
    final record = dayRecords[habit.id] ?? HabitRecord(habitId: habit.id, date: selectedDate);
    final progress = habit.targetValue > 0
        ? (record.currentValue / habit.targetValue).clamp(0.0, 1.0)
        : 0.0;
    final pct = (progress * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Dismissible(
      key: Key(habit.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => CreateHabitSheet(initialHabit: habit),
          );
          return false;
        }
        return true;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          final notifier = ref.read(habitsProvider.notifier);
          notifier.removeHabit(habit.id);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Habit "${habit.title}" deleted.'),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'UNDO',
                onPressed: () => notifier.addHabit(habit),
              ),
            ),
          );
        }
      },
      background: Container(
        padding: const EdgeInsets.only(left: 24),
        decoration: BoxDecoration(color: Colors.indigoAccent, borderRadius: BorderRadius.circular(20)),
        alignment: Alignment.centerLeft,
        child: const Icon(PhosphorIconsBold.pencilSimple, color: Colors.white),
      ),
      secondaryBackground: Container(
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
        alignment: Alignment.centerRight,
        child: const Icon(PhosphorIconsBold.trash, color: Colors.white),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getSurface(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: record.isCompleted
                ? _accentColor.withValues(alpha: 0.5)
                : AppTheme.getSurfaceLight(context),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HabitDetailsScreen(habit: habit)));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: Icon | Title+Subtitle | Edit | Check ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon box
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_accentColor, _accentColor.withValues(alpha: 0.5)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    // Title + subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            habit.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                            maxLines: 1,
                            minFontSize: 12,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (habit.type == HabitType.blocks)
                                Text(
                                  '${record.currentValue.toInt()} / ${habit.targetValue.toInt()} ${habit.unit.isNotEmpty ? habit.unit : 'blocks'}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                                )
                              else
                                Flexible(
                                  child: Text(
                                    _formatSubtitle(record.currentValue, habit.targetValue, habit.unit)
                                        .replaceAll('\n', ' '),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              const Icon(PhosphorIconsFill.fire, color: AppTheme.accentOrange, size: 13),
                              const SizedBox(width: 3),
                              Text(
                                '${habit.streak}d',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.accentOrange,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Check button
                    GestureDetector(
                      onTap: () {
                        if (!record.isCompleted) {
                          ref.read(habitRecordsProvider.notifier).addProgress(
                                habit.id, selectedDate,
                                habit.targetValue - record.currentValue, habit);
                        } else {
                          ref.read(habitRecordsProvider.notifier).resetProgress(habit.id, selectedDate);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: record.isCompleted ? _accentColor : AppTheme.getSurfaceLight(context),
                          shape: BoxShape.circle,
                          boxShadow: record.isCompleted
                              ? [BoxShadow(color: _accentColor.withValues(alpha: 0.5), blurRadius: 12)]
                              : [],
                        ),
                        child: Icon(
                          PhosphorIconsBold.check,
                          color: record.isCompleted ? Colors.white : AppTheme.getTextSecondary(context),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Progress Bar ──
                if (habit.type == HabitType.blocks)
                  _buildBlocksProgress(context, record, ref, selectedDate)
                else
                  _buildGlowingLinearProgress(context, progress),

                // ── Below bar: "X% done" + quick-add ──
                if (habit.type == HabitType.numeric && !record.isCompleted) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$pct% done',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.getTextSecondary(context),
                            ),
                      ),
                      Row(
                        children: [
                          if (record.currentValue > 0)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: GestureDetector(
                                onTap: () => ref
                                    .read(habitRecordsProvider.notifier)
                                    .addProgress(habit.id, selectedDate, -_quickAddButtons.first, habit),
                                child: Container(
                                  height: 28,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.getSurfaceLight(context),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.undo_rounded, size: 16, color: AppTheme.getTextSecondary(context)),
                                ),
                              ),
                            ),
                          ..._quickAddButtons.map((amount) => Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: GestureDetector(
                                  onTap: () => ref
                                      .read(habitRecordsProvider.notifier)
                                      .addProgress(habit.id, selectedDate, amount, habit),
                                  child: Container(
                                    height: 28,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: _accentColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: _accentColor.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      _quickLabel(amount, habit.unit),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: _accentColor,
                                            fontWeight: FontWeight.bold,
                                            height: 1.0,
                                          ),
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
                ],

                // ── Markers for Numeric (steps/large values) ──
                if (habit.type == HabitType.numeric) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatMarker(habit.targetValue * 0.25, habit.unit),
                          style: TextStyle(color: _accentColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      Text(_formatMarker(habit.targetValue * 0.50, habit.unit),
                          style: TextStyle(color: _accentColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      Text(_formatMarker(habit.targetValue * 0.75, habit.unit),
                          style: TextStyle(color: _accentColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      Text('${_formatMarker(habit.targetValue, habit.unit)} Goal',
                          style: TextStyle(color: _accentColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],

                // ── "X% done" for boolean (completed state) ──
                if (habit.type == HabitType.boolean && record.isCompleted)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('100% done',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: _accentColor)),
                        GestureDetector(
                          onTap: () => ref
                              .read(habitRecordsProvider.notifier)
                              .resetProgress(habit.id, selectedDate),
                          child: Container(
                            height: 28,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.getSurfaceLight(context),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.undo_rounded, size: 14, color: AppTheme.getTextSecondary(context)),
                                const SizedBox(width: 4),
                                Text('Undo',
                                    style: TextStyle(
                                        color: AppTheme.getTextSecondary(context),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Blocks footer: "X of Y Pomodoros • Tap to log" ──
                if (habit.type == HabitType.blocks) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${record.currentValue.toInt()} of ${habit.targetValue.toInt()} ${habit.unit.isNotEmpty ? habit.unit : 'Pomodoros'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Row(
                        children: [
                          if (record.currentValue > 0 && !record.isCompleted)
                            GestureDetector(
                              onTap: () => ref
                                  .read(habitRecordsProvider.notifier)
                                  .addProgress(habit.id, selectedDate, -1.0, habit),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Icon(Icons.undo_rounded,
                                    size: 18, color: AppTheme.getTextSecondary(context)),
                              ),
                            ),
                          if (!record.isCompleted)
                            GestureDetector(
                              onTap: () => ref
                                  .read(habitRecordsProvider.notifier)
                                  .addProgress(habit.id, selectedDate, 1.0, habit),
                              child: Text(
                                'Tap to log',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: _accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
        ),
      ),
    );
  }

  Widget _buildGlowingLinearProgress(BuildContext context, double progress) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          // Shimmer background track
          const ShimmerTrack(height: 12),
          // Filled portion
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0, end: progress),
            builder: (context, value, _) {
              return Container(
                width: constraints.maxWidth * value,
                height: 12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_accentColor.withValues(alpha: 0.6), _accentColor],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildBlocksProgress(BuildContext context, HabitRecord record, WidgetRef ref, DateTime selectedDate) {
    final total = habit.targetValue.toInt();
    final current = record.currentValue.toInt();
    return Row(
      children: List.generate(total, (i) {
        final filled = i < current;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (i == current) {
                ref.read(habitRecordsProvider.notifier).addProgress(habit.id, selectedDate, 1.0, habit);
              } else if (i == current - 1) {
                ref.read(habitRecordsProvider.notifier).addProgress(habit.id, selectedDate, -1.0, habit);
              }
            },
            child: Padding(
              padding: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
              child: Stack(
                children: [
                  // Shimmer track (always visible underneath)
                  ShimmerTrack(
                    height: 12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  // Filled overlay
                  if (filled)
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_accentColor.withValues(alpha: 0.6), _accentColor],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: _accentColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
