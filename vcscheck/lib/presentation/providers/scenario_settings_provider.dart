import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/currency_formatter.dart';
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

class InflationRateNotifier extends StateNotifier<double> {
  static const double defaultRate = 0.02;

  InflationRateNotifier() : super(defaultRate);

  void setRate(double rate) => state = rate;
  void reset() => state = defaultRate;
}

final inflationRateProvider =
    StateNotifierProvider<InflationRateNotifier, double>(
  (ref) => InflationRateNotifier(),
);

class CurrencyNotifier extends StateNotifier<AppCurrency> {
  CurrencyNotifier() : super(AppCurrency.eur);

  void setCurrency(AppCurrency c) => state = c;
  void reset() => state = AppCurrency.eur;
}

final currencyProvider =
    StateNotifierProvider<CurrencyNotifier, AppCurrency>(
  (ref) => CurrencyNotifier(),
);

final currencyFormatterProvider = Provider<CurrencyFormatter>((ref) {
  return CurrencyFormatter(ref.watch(currencyProvider));
});
