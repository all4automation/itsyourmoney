import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/scenario_type.dart';

class ScenarioSettingsNotifier
    extends StateNotifier<Map<ScenarioType, double>> {
  ScenarioSettingsNotifier()
      : super({
          ScenarioType.conservative: ScenarioType.conservative.defaultReturnRate,
          ScenarioType.moderate: ScenarioType.moderate.defaultReturnRate,
          ScenarioType.aggressive: ScenarioType.aggressive.defaultReturnRate,
        });

  void updateRate(ScenarioType type, double rate) {
    state = {...state, type: rate};
  }

  void resetToDefaults() {
    state = {
      for (final t in ScenarioType.values) t: t.defaultReturnRate,
    };
  }
}

final scenarioSettingsProvider =
    StateNotifierProvider<ScenarioSettingsNotifier, Map<ScenarioType, double>>(
  (ref) => ScenarioSettingsNotifier(),
);
