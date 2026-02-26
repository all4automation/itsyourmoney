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
    final s = input.savingsRate;
    final g = input.incomeGrowthRate;

    final points = <YearlyDataPoint>[];

    // Year 0 = today (no growth applied yet)
    points.add(YearlyDataPoint(age: input.currentAge, wealth: input.currentAssets));

    double vPrev = input.currentAssets;

    for (int t = 1; t <= n; t++) {
      // E_t = E_0 * (1 + g)^t
      final et = e0 * _pow(1 + g, t);

      // S_t = E_t * s  (annual savings)
      final st = et * s;

      // V_t = (V_{t-1} + S_t) * (1 + r)
      final vt = (vPrev + st) * (1 + r);

      points.add(YearlyDataPoint(age: input.currentAge + t, wealth: vt));
      vPrev = vt;
    }

    return ScenarioResult(
      type: type,
      returnRate: r,
      dataPoints: points,
    );
  }

  // Integer exponent power without dart:math to avoid num cast
  static double _pow(double base, int exp) {
    double result = 1.0;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
}
