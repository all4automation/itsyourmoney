import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/scenario_type.dart';
import '../providers/scenario_settings_provider.dart';
import '../widgets/results/scenario_card.dart';

class AdjustScreen extends ConsumerStatefulWidget {
  const AdjustScreen({super.key});

  @override
  ConsumerState<AdjustScreen> createState() => _AdjustScreenState();
}

class _AdjustScreenState extends ConsumerState<AdjustScreen> {
  late Map<ScenarioType, double> _localRates;

  @override
  void initState() {
    super.initState();
    _localRates = Map.from(ref.read(scenarioSettingsProvider));
  }

  void _apply() {
    final notifier = ref.read(scenarioSettingsProvider.notifier);
    for (final entry in _localRates.entries) {
      notifier.updateRate(entry.key, entry.value);
    }
    context.pop();
  }

  void _reset() {
    ref.read(scenarioSettingsProvider.notifier).resetToDefaults();
    setState(() {
      _localRates = {
        for (final t in ScenarioType.values) t: t.defaultReturnRate,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adjust Return Rates'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Customize the annual return rates for each scenario. Default values are after-tax estimates.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          ...ScenarioType.values.map((type) {
            final rate = _localRates[type] ?? type.defaultReturnRate;
            final color = scenarioColor(type);
            return Padding(
              padding: const EdgeInsets.only(bottom: 28),
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
                        '${type.label} Scenario',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(rate * 100).toStringAsFixed(1)}% p.a.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: rate,
                    min: 0.01,
                    max: 0.15,
                    divisions: 140,
                    activeColor: color,
                    onChanged: (v) {
                      setState(() {
                        _localRates = {..._localRates, type: v};
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1%', style: theme.textTheme.bodySmall),
                      Text('15%', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _apply,
            child: const Text('Apply Changes'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _reset,
            child: const Text('Reset to Defaults'),
          ),
        ],
      ),
    );
  }
}
