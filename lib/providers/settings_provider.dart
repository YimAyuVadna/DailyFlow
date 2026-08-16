import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  @override
  HeatmapSettings build() {
    return const HeatmapSettings();
  }

  void setPalette(int index) {
    state = state.copyWith(paletteIndex: index);
  }

  void toggleGlow() {
    state = state.copyWith(isGlowEnabled: !state.isGlowEnabled);
  }
}

final heatmapSettingsProvider = NotifierProvider<HeatmapSettingsNotifier, HeatmapSettings>(
  () => HeatmapSettingsNotifier(),
);
