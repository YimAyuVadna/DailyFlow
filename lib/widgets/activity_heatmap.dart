import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../providers/habit_provider.dart';
import '../providers/settings_provider.dart';

class ActivityHeatmap extends ConsumerWidget {
  const ActivityHeatmap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(habitRecordsProvider);
    final habits = ref.watch(habitsProvider).where((h) => !h.isArchived).toList();
    final today = DateTime.now();

    // 1. Calculate Yearly Statistics (last 365 days)
    int totalYearlyCheckins = 0;
    double totalDailyConsistency = 0.0;
    int perfectDaysCount = 0;

    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final dateKey = HabitRecordNotifier.dateKey(date);
      final dayRecords = records[dateKey] ?? {};

      int completed = 0;
      for (final r in dayRecords.values) {
        if (r.isCompleted) {
          completed++;
          totalYearlyCheckins++;
        }
      }

      if (habits.isNotEmpty) {
        totalDailyConsistency += (completed / habits.length);
        if (completed >= habits.length) {
          perfectDaysCount++;
        }
      }
    }

    final avgConsistency = habits.isNotEmpty
        ? (totalDailyConsistency / 365 * 100).toInt()
        : 0;

    final settings = ref.watch(heatmapSettingsProvider);
    const palettes = [
      [Color(0xFF0F362C), Color(0xFF165C45), Color(0xFF1E825F), Color(0xFF26E6A4)],
      [Color(0xFF3B151F), Color(0xFF671A31), Color(0xFFC02150), Color(0xFFFF4978)],
      [Color(0xFF28114A), Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFFC48BFF)],
      [Color(0xFF401C00), Color(0xFF8A3C00), Color(0xFFD97706), Color(0xFFFBBF24)],
      [Color(0xFF0B2D45), Color(0xFF02629A), Color(0xFF0091E6), Color(0xFF38B2FA)],
    ];
    final p = palettes[settings.paletteIndex % palettes.length];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D14), // very dark charcoal/navy
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row: Title & Subtitle + Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Annual Habit Momentum Matrix',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '365 continuous days of habit check-in density',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Intensity Legend
              Row(
                children: [
                  const Text('Less', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                  const SizedBox(width: 4),
                  _buildLegendSquare(const Color(0xFF161B22)),
                  _buildLegendSquare(p[0]),
                  _buildLegendSquare(p[1]),
                  _buildLegendSquare(p[2]),
                  _buildLegendSquare(p[3]),
                  const SizedBox(width: 4),
                  const Text('More', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Annual Heatmap Grid (Scrollable)
          _HeatmapMatrix(
            records: records,
            habits: habits,
            today: today,
            totalYearlyCheckins: totalYearlyCheckins,
            avgConsistency: avgConsistency,
            perfectDaysCount: perfectDaysCount,
            settings: settings,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendSquare(Color color) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _HeatmapMatrix extends StatefulWidget {
  final Map<String, Map<String, HabitRecord>> records;
  final List<Habit> habits;
  final DateTime today;
  final int totalYearlyCheckins;
  final int avgConsistency;
  final int perfectDaysCount;
  final HeatmapSettings settings;

  const _HeatmapMatrix({
    required this.records,
    required this.habits,
    required this.today,
    required this.totalYearlyCheckins,
    required this.avgConsistency,
    required this.perfectDaysCount,
    required this.settings,
  });

  @override
  State<_HeatmapMatrix> createState() => _HeatmapMatrixState();
}

class _HeatmapMatrixState extends State<_HeatmapMatrix> {
  static const int rows = 7;
  static const int columns = 53; // 53 weeks covers a full year
  static const double cellWidth = 10.0;
  static const double cellHeight = 10.0;
  static const double spacing = 3.0;

  late ScrollController _scrollController;
  DateTime? _tappedDate;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime(widget.today.year, widget.today.month, widget.today.day);
    // Grid starts 53 weeks ago (ending today)
    final startDate = today.subtract(const Duration(days: (columns * rows) - 1));

    // Determine currently selected day details
    final activeDate = _tappedDate ?? today;
    final dateKey = HabitRecordNotifier.dateKey(activeDate);
    final dayRecords = widget.records[dateKey] ?? {};

    int completed = 0;
    for (final r in dayRecords.values) {
      if (r.isCompleted) completed++;
    }
    final total = widget.habits.length;
    final completionPercent = total > 0 ? (completed / total * 100).toInt() : 0;
    final isMomentumActive = completed > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Grid + Weekday labels Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Day labels
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16), // align with month labels
                _buildDayLabel('Mon'),
                const SizedBox(height: cellHeight + spacing), // skip Tue
                _buildDayLabel('Wed'),
                const SizedBox(height: cellHeight + spacing), // skip Thu
                _buildDayLabel('Fri'),
                const SizedBox(height: cellHeight + spacing), // skip Sat
                _buildDayLabel('Sun'),
              ],
            ),
            const SizedBox(width: 8),

            // Scrollable Grid Area
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Months labels row
                    Row(
                      children: List.generate(columns, (colIndex) {
                        final date = startDate.add(Duration(days: colIndex * rows));
                        final isNewMonth = colIndex == 0 ||
                            date.month != startDate.add(Duration(days: (colIndex - 1) * rows)).month;

                        return SizedBox(
                          width: cellWidth + spacing,
                          child: isNewMonth
                              ? Text(
                                  DateFormat('MMM').format(date),
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.visible,
                                )
                              : const SizedBox(),
                        );
                      }),
                    ),
                    const SizedBox(height: 4),

                    // Grid Columns
                    Row(
                      children: List.generate(columns, (colIndex) {
                        return Padding(
                          padding: EdgeInsets.only(right: colIndex < columns - 1 ? spacing : 0),
                          child: Column(
                            children: List.generate(rows, (rowIndex) {
                              final dayOffset = (colIndex * rows) + rowIndex;
                              final date = startDate.add(Duration(days: dayOffset));

                              // Hide cells in the future
                              if (date.isAfter(today)) {
                                return SizedBox(width: cellWidth, height: cellHeight + spacing);
                              }

                              final intensity = _getIntensity(date);
                              final isSelected = _tappedDate != null &&
                                  _tappedDate!.year == date.year &&
                                  _tappedDate!.month == date.month &&
                                  _tappedDate!.day == date.day;
                              final isCurrentDay = date.year == today.year &&
                                  date.month == today.month &&
                                  date.day == today.day;

                              final cellColor = _intensityColor(intensity);

                              return Padding(
                                padding: EdgeInsets.only(bottom: rowIndex < rows - 1 ? spacing : 0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _tappedDate = isSelected ? null : date;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    width: cellWidth,
                                    height: cellHeight,
                                    decoration: BoxDecoration(
                                      color: cellColor,
                                      borderRadius: BorderRadius.circular(2),
                                      border: isCurrentDay
                                          ? Border.all(color: Colors.white70, width: 1.2)
                                          : isSelected
                                              ? Border.all(color: Colors.white, width: 1.2)
                                              : null,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Selected Day Details Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF08080C), // slightly darker than main container
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.04),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Date & Completion Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: completionPercent == 100 
                                ? const Color(0xFF26E6A4) 
                                : (completionPercent > 0 ? const Color(0xFF39D353) : const Color(0xFF161B22)),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('yyyy-MM-dd').format(activeDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completionPercent% Completed • $completed of $total targets',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Right: Momentum Active State
              if (isMomentumActive) ...[
                const SizedBox(width: 16),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.whatshot_rounded,
                      color: Color(0xFF26E6A4),
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Momentum Active',
                      style: TextStyle(
                        color: Color(0xFF26E6A4),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Divider
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Divider(
            color: Colors.white.withValues(alpha: 0.08),
            height: 32,
          ),
        ),

        // Yearly Statistics row (3 Cards)
        Row(
          children: [
            _buildStatCard(
              NumberFormat('#,###').format(widget.totalYearlyCheckins),
              'Total Check-ins\n(Year)',
              Colors.white,
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              '${widget.avgConsistency}%',
              'Avg Consistency',
              const Color(0xFF26E6A4),
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              '${widget.perfectDaysCount} Days',
              '100% Perfect\nDays',
              AppTheme.accentMagenta,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDayLabel(String label) {
    return Container(
      height: cellHeight,
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF08080C),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.04),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 9,
                height: 1.3,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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

  Color _intensityColor(double intensity) {
    if (intensity == 0.0) {
      return const Color(0xFF161B22);
    }
    const palettes = [
      [Color(0xFF0F362C), Color(0xFF165C45), Color(0xFF1E825F), Color(0xFF26E6A4)],
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
