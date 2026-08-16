import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../providers/habit_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/matrix_screen.dart';

class ActivityHeatmap extends ConsumerWidget {
  const ActivityHeatmap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(habitRecordsProvider);
    final habits = ref.watch(habitsProvider).where((h) => !h.isArchived).toList();
    final settings = ref.watch(heatmapSettingsProvider);
    final today = DateTime.now();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.05)
              : AppTheme.lightSurfaceLight,
        ),
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.show_chart_rounded,
                      color: AppTheme.accentNeonGreen, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '365-Day Heatmap Activity',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : AppTheme.lightTextPrimary,
                        ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MatrixScreen()),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'Explore Matrix',
                      style: TextStyle(
                        color: AppTheme.accentMagenta.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.accentMagenta.withValues(alpha: 0.9),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Matrix Grid
          _HeatmapMatrix(
            records: records, 
            habits: habits, 
            today: today, 
            settings: settings,
          ),
        ],
      ),
    );
  }
}

class _HeatmapMatrix extends StatefulWidget {
  final Map<String, Map<String, HabitRecord>> records;
  final List<Habit> habits;
  final DateTime today;
  final HeatmapSettings settings;

  const _HeatmapMatrix({
    required this.records,
    required this.habits,
    required this.today,
    required this.settings,
  });

  @override
  State<_HeatmapMatrix> createState() => _HeatmapMatrixState();
}

class _HeatmapMatrixState extends State<_HeatmapMatrix> {
  static const int rows = 7;
  static const int columns = 16;
  DateTime? _tappedDate;

  @override
  Widget build(BuildContext context) {
    final startDate = widget.today.subtract(const Duration(days: (columns * rows) - 1));

    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = 4.0;
        final double cellWidth = (constraints.maxWidth - (spacing * (columns - 1))) / columns;
        final double cellHeight = 10.0;

        return Column(
          children: [
            if (_tappedDate != null)
              _Tooltip(
                date: _tappedDate!,
                records: widget.records,
                habits: widget.habits,
                onDismiss: () => setState(() => _tappedDate = null),
              ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(columns, (colIndex) {
                return Column(
                  children: List.generate(rows, (rowIndex) {
                    final dayOffset = (colIndex * rows) + rowIndex;
                    final date = startDate.add(Duration(days: dayOffset));
                    
                    if (date.isAfter(widget.today)) {
                      return SizedBox(width: cellWidth, height: cellHeight + spacing);
                    }
                    
                    final intensity = _getIntensity(date);
                    final isSelected = _tappedDate != null &&
                        _tappedDate!.year == date.year &&
                        _tappedDate!.month == date.month &&
                        _tappedDate!.day == date.day;
                    final isToday = date.year == widget.today.year &&
                        date.month == widget.today.month &&
                        date.day == widget.today.day;
                    
                    final cellColor = _intensityColor(intensity, context);

                    return Padding(
                      padding: EdgeInsets.only(bottom: spacing),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _tappedDate = isSelected ? null : date;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: cellWidth,
                          height: cellHeight,
                          decoration: BoxDecoration(
                            color: cellColor,
                            borderRadius: BorderRadius.circular(4),
                            border: isToday
                                ? Border.all(color: cellColor == Colors.transparent || intensity == 0 ? Colors.white54 : cellColor, width: 1.5)
                                : isSelected
                                    ? Border.all(color: Colors.white, width: 1.5)
                                    : null,
                            boxShadow: widget.settings.isGlowEnabled && intensity > 0.5
                                ? [
                                    BoxShadow(
                                      color: cellColor.withValues(alpha: 0.5),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  double _getIntensity(DateTime date) {
    if (widget.habits.isEmpty) return 0.0;
    final dateKey = HabitRecordNotifier.dateKey(date);
    final dayRecords = widget.records[dateKey] ?? {};
    int completed = 0;
    for (final record in dayRecords.values) {
      if (record.isCompleted) completed++;
    }
    return (completed / widget.habits.length).clamp(0.0, 1.0);
  }

  Color _intensityColor(double intensity, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (intensity == 0) {
      return isDark ? AppTheme.surfaceLight.withValues(alpha: 0.5) : AppTheme.lightSurfaceLight.withValues(alpha: 0.5);
    }
    
    const palettes = [
      [Color(0xFF0F362C), Color(0xFF165C45), Color(0xFF1E825F), AppTheme.accentNeonGreen],
      [Color(0xFF3B151F), Color(0xFF671A31), Color(0xFFC02150), Color(0xFFFF4978)],
      [Color(0xFF28114A), Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFFC48BFF)],
      [Color(0xFF401C00), Color(0xFF8A3C00), Color(0xFFD97706), Color(0xFFFBBF24)],
      [Color(0xFF0B2D45), Color(0xFF02629A), Color(0xFF0091E6), Color(0xFF38B2FA)],
    ];
    final p = palettes[widget.settings.paletteIndex % palettes.length];
    
    if (intensity <= 0.25) return p[0];
    if (intensity <= 0.5) return p[1];
    if (intensity <= 0.75) return p[2];
    return p[3];
  }
}

class _Tooltip extends StatelessWidget {
  final DateTime date;
  final Map<String, Map<String, HabitRecord>> records;
  final List<Habit> habits;
  final VoidCallback onDismiss;

  const _Tooltip({
    required this.date,
    required this.records,
    required this.habits,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final dateKey = HabitRecordNotifier.dateKey(date);
    final dayRecords = records[dateKey] ?? {};
    int completed = 0;
    for (final r in dayRecords.values) {
      if (r.isCompleted) completed++;
    }
    final total = habits.length;
    final label = DateFormat('MMM d, yyyy').format(date);

    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2A2A35)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.accentNeonGreen.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month_rounded,
                size: 14, color: AppTheme.getTextSecondary(context)),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentNeonGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                total > 0 ? '$completed / $total done' : 'No habits',
                style: const TextStyle(
                  color: AppTheme.accentNeonGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
