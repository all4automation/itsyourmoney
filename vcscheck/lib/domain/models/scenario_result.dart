import 'scenario_type.dart';

class YearlyDataPoint {
  final int age;
  final double wealth;

  const YearlyDataPoint({required this.age, required this.wealth});
}

class ScenarioResult {
  final ScenarioType type;
  final double returnRate;
  final List<YearlyDataPoint> dataPoints;

  const ScenarioResult({
    required this.type,
    required this.returnRate,
    required this.dataPoints,
  });

  double get finalWealth => dataPoints.last.wealth;

  double get startWealth => dataPoints.first.wealth;
}
