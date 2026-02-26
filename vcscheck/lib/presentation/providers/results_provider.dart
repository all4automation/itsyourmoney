import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/scenario_result.dart';
import '../../domain/services/wealth_calculator.dart';
import 'scenario_settings_provider.dart';
import 'user_input_provider.dart';

final resultsProvider = Provider<List<ScenarioResult>?>((ref) {
  final input = ref.watch(userInputProvider);
  final rates = ref.watch(scenarioSettingsProvider);

  if (input == null) return null;

  return WealthCalculator.calculate(input, customRates: rates);
});
