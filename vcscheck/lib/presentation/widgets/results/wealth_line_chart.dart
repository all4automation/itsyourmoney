import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../domain/models/scenario_result.dart';
import 'scenario_card.dart';

class WealthLineChart extends StatelessWidget {
  final List<ScenarioResult> results;

  const WealthLineChart({super.key, required this.results});

  LineChartBarData _toLineData(ScenarioResult result) {
    final spots = result.dataPoints
        .map((p) => FlSpot(p.age.toDouble(), p.wealth))
        .toList();

    return LineChartBarData(
      spots: spots,
      color: scenarioColor(result.type),
      isCurved: true,
      barWidth: 2.5,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = TextStyle(
      fontSize: 10,
      color: theme.colorScheme.onSurfaceVariant,
    );

    // Determine Y-axis max for padding
    final maxWealth = results
        .map((r) => r.finalWealth)
        .reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 260,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxWealth * 1.1,
          lineBarsData: results.map(_toLineData).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(value.toInt().toString(), style: textStyle),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 64,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(
                    CurrencyFormatter.compact(value),
                    style: textStyle,
                  ),
                ),
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => theme.colorScheme.inverseSurface,
              getTooltipItems: (spots) => spots.map((s) {
                final result = results[s.barIndex];
                return LineTooltipItem(
                  '${result.type.label}\n${CurrencyFormatter.format(s.y)}',
                  TextStyle(
                    color: theme.colorScheme.onInverseSurface,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class ChartLegend extends StatelessWidget {
  final List<ScenarioResult> results;

  const ChartLegend({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: results
          .map((r) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 3,
                      color: scenarioColor(r.type),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      r.type.label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
