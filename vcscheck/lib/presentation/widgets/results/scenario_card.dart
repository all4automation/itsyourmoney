import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../domain/models/scenario_result.dart';
import '../../../domain/models/scenario_type.dart';

Color scenarioColor(ScenarioType type) {
  return switch (type) {
    ScenarioType.conservative => const Color(0xFFF5A623),
    ScenarioType.moderate => const Color(0xFF4A90E2),
    ScenarioType.aggressive => const Color(0xFF27AE60),
  };
}

class ScenarioCard extends StatelessWidget {
  final ScenarioResult result;

  const ScenarioCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = scenarioColor(result.type);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  result.type.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${CurrencyFormatter.percent(result.returnRate)} p.a.',
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
            const SizedBox(height: 12),
            Text(
              CurrencyFormatter.format(result.finalWealth),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              result.type.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
