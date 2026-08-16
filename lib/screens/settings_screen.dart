import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/habit_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heatmapSettings = ref.watch(heatmapSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Heatmap Customization ──
          const Text(
            'Heatmap Customization',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.getSurface(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.getSurfaceLight(context)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Palette:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.getTextSecondary(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(5, (index) {
                        final isSelected = heatmapSettings.paletteIndex == index;
                        return GestureDetector(
                          onTap: () {
                            ref.read(heatmapSettingsProvider.notifier).setPalette(index);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? Colors.white : AppTheme.getSurfaceLight(context),
                                width: 2,
                              ),
                            ),
                            child: _PalettePreview(index: index),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    ref.read(heatmapSettingsProvider.notifier).toggleGlow();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: heatmapSettings.isGlowEnabled
                          ? AppTheme.accentNeonGreen.withValues(alpha: 0.2)
                          : AppTheme.getSurfaceLight(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: heatmapSettings.isGlowEnabled
                            ? AppTheme.accentNeonGreen
                            : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      'Glow: ${heatmapSettings.isGlowEnabled ? 'ON' : 'OFF'}',
                      style: TextStyle(
                        color: heatmapSettings.isGlowEnabled ? AppTheme.accentNeonGreen : AppTheme.getTextSecondary(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Data Management ──
          const Text(
            'Data Management',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentMagenta.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(PhosphorIconsRegular.trash, color: AppTheme.accentMagenta),
            ),
            title: const Text('Reset All Data'),
            subtitle: const Text('Clear all habits and progress'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset All Data?'),
                  content: const Text(
                      'This will permanently delete all your habits, progress, and streaks. This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Reset',
                        style: TextStyle(color: AppTheme.accentMagenta),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                ref.read(habitsProvider.notifier).clearAll();
                ref.read(habitRecordsProvider.notifier).clearAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data reset successfully')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _PalettePreview extends StatelessWidget {
  final int index;

  const _PalettePreview({required this.index});

  @override
  Widget build(BuildContext context) {
    const palettes = [
      [Color(0xFF0F362C), Color(0xFF165C45), Color(0xFF1E825F), AppTheme.accentNeonGreen],
      [Color(0xFF3B151F), Color(0xFF671A31), Color(0xFFC02150), Color(0xFFFF4978)],
      [Color(0xFF28114A), Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFFC48BFF)],
      [Color(0xFF401C00), Color(0xFF8A3C00), Color(0xFFD97706), Color(0xFFFBBF24)],
      [Color(0xFF0B2D45), Color(0xFF02629A), Color(0xFF0091E6), Color(0xFF38B2FA)],
    ];
    final p = palettes[index];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: p.map((c) {
        return Container(
          width: 8,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }).toList(),
    );
  }
}
