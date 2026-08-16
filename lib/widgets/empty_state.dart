import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';
import 'create_habit_sheet.dart';

class EmptyState extends ConsumerWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon ring
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentMagenta.withValues(alpha: 0.08),
              border: Border.all(
                color: AppTheme.accentMagenta.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: const Center(
              child: Icon(
                PhosphorIconsBold.sparkle,
                color: AppTheme.accentMagenta,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Start Your Journey',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Your habit dashboard is empty.\nCreate your first habit and start building momentum.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.getTextSecondary(context),
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Quick-start suggestions
          Text(
            'POPULAR HABITS TO TRY',
            style: TextStyle(
              color: AppTheme.getTextSecondary(context),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: const [
              _SuggestionChip(label: '💧 Hydration', color: AppTheme.accentNeonGreen),
              _SuggestionChip(label: '🧘 Meditation', color: AppTheme.accentOrange),
              _SuggestionChip(label: '📚 Reading', color: AppTheme.accentBlue),
              _SuggestionChip(label: '🏃 Exercise', color: AppTheme.accentMagenta),
              _SuggestionChip(label: '😴 Sleep', color: Color(0xFF9B59B6)),
              _SuggestionChip(label: '✍️ Journaling', color: AppTheme.warningAmber),
            ],
          ),
          const SizedBox(height: 36),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const CreateHabitSheet(),
              );
            },
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.accentMagenta, AppTheme.accentBlue],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentMagenta.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Create Your First Habit',
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
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final Color color;

  const _SuggestionChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
