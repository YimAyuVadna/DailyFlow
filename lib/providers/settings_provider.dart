import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'habit_provider.dart';

class HeatmapSettings {
  final int paletteIndex;
  final bool isGlowEnabled;

  const HeatmapSettings({
    this.paletteIndex = 0,
    this.isGlowEnabled = true,
  });

  HeatmapSettings copyWith({
    int? paletteIndex,
    bool? isGlowEnabled,
  }) {
    return HeatmapSettings(
      paletteIndex: paletteIndex ?? this.paletteIndex,
      isGlowEnabled: isGlowEnabled ?? this.isGlowEnabled,
    );
  }
}

class HeatmapSettingsNotifier extends Notifier<HeatmapSettings> {
  static const _paletteKey = 'heatmap_palette_index';
  static const _glowKey = 'heatmap_glow_enabled';

  @override
  HeatmapSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final paletteIndex = prefs.getInt(_paletteKey) ?? 0;
    final isGlowEnabled = prefs.getBool(_glowKey) ?? true;
    return HeatmapSettings(
      paletteIndex: paletteIndex,
      isGlowEnabled: isGlowEnabled,
    );
  }

  void setPalette(int index) {
    state = state.copyWith(paletteIndex: index);
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setInt(_paletteKey, index);
  }

  void toggleGlow() {
    final newGlow = !state.isGlowEnabled;
    state = state.copyWith(isGlowEnabled: newGlow);
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(_glowKey, newGlow);
  }
}

final heatmapSettingsProvider = NotifierProvider<HeatmapSettingsNotifier, HeatmapSettings>(
  () => HeatmapSettingsNotifier(),
);
