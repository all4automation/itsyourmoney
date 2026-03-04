import '../models/scenario_result.dart';
import '../models/scenario_type.dart';
import '../models/user_input.dart';

class WealthCalculator {
  static List<ScenarioResult> calculate(
    UserInput input, {
    Map<ScenarioType, double>? customRates,
  }) {
    return ScenarioType.values.map((type) {
      final rate = customRates?[type] ?? type.defaultReturnRate;
      return _calculateScenario(input, type, rate);
    }).toList();
  }

  static ScenarioResult _calculateScenario(
    UserInput input,
    ScenarioType type,
    double r,
  ) {
    final n = input.horizonYears;
    final e0 = input.grossAnnualIncome;
    final g = input.incomeGrowthRate;

    final points = <YearlyDataPoint>[];
    points.add(YearlyDataPoint(age: input.currentAge, wealth: input.currentAssets));

    double vPrev = input.currentAssets;
    double currentSavingsRate = input.savingsRate;

    for (int t = 1; t <= n; t++) {
      // E_t = E_0 * (1+g)^(t-1): year 1 uses current salary (no raise yet),
      // year 2 uses salary after 1 raise, etc.
      final et = e0 * _pow(1 + g, t - 1);

      // Save More Tomorrow: add smtBoostRate to savings each year income grows,
      // but only if we haven't already reached (or exceeded) the cap.
      if (input.saveMoreTomorrow && g > 0 && currentSavingsRate < input.smtMaxRate) {
        currentSavingsRate =
            (currentSavingsRate + input.smtBoostRate).clamp(0.0, input.smtMaxRate);
      }
      // S_t = E_t * s_t
      final st = et * currentSavingsRate;

      // V_t = V_{t-1} * (1+r) + S_t: savings contributed at end of year
      final vt = vPrev * (1 + r) + st;

      points.add(YearlyDataPoint(age: input.currentAge + t, wealth: vt));
      vPrev = vt;
    }

    return ScenarioResult(
      type: type,
      returnRate: r,
      dataPoints: points,
    );
  }

  static double _pow(double base, int exp) {
    double result = 1.0;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
}
