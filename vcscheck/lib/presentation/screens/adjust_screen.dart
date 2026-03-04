import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/currency_formatter.dart';
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
  late double _localInflation;
  late AppCurrency _localCurrency;

  @override
  void initState() {
    super.initState();
    _localRates = Map.from(ref.read(scenarioSettingsProvider));
    _localInflation = ref.read(inflationRateProvider);
    _localCurrency = ref.read(currencyProvider);
  }

  void _apply() {
    final notifier = ref.read(scenarioSettingsProvider.notifier);
    for (final entry in _localRates.entries) {
      notifier.updateRate(entry.key, entry.value);
    }
    ref.read(inflationRateProvider.notifier).setRate(_localInflation);
    ref.read(currencyProvider.notifier).setCurrency(_localCurrency);
    context.pop();
  }

  void _reset() {
    ref.read(scenarioSettingsProvider.notifier).resetToDefaults();
    ref.read(inflationRateProvider.notifier).reset();
    ref.read(currencyProvider.notifier).reset();
    setState(() {
      _localRates = {
        for (final t in ScenarioType.values) t: t.defaultReturnRate,
      };
      _localInflation = InflationRateNotifier.defaultRate;
      _localCurrency = AppCurrency.eur;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
          const SizedBox(height: 8),
          _RateExplainerCard(theme: theme),
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
          const Divider(height: 32),
          Text(
            'Inflation',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Used to show purchasing power in today\'s money (Real view on the results screen).',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Annual inflation rate',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '${(_localInflation * 100).toStringAsFixed(1)}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: _localInflation,
            min: 0.0,
            max: 0.10,
            divisions: 100,
            onChanged: (v) => setState(() => _localInflation = v),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0%', style: theme.textTheme.bodySmall),
              Text('10%', style: theme.textTheme.bodySmall),
            ],
          ),
          const Divider(height: 32),
          Text(
            'Currency',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Changes the display symbol and number format. No conversion is applied.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppCurrency.values.map((c) {
              final selected = _localCurrency == c;
              return ChoiceChip(
                label: Text('${c.symbol} ${c.label}'),
                selected: selected,
                onSelected: (_) => setState(() => _localCurrency = c),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
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

class _RateExplainerCard extends StatelessWidget {
  final ThemeData theme;
  const _RateExplainerCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Why these defaults?',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Historical markets (1972–2012) averaged ~10% per year (Schwab). After approximately 30% in taxes, that becomes ~7% — our aggressive rate.\n\n'
              'The moderate rate of 5.5% and conservative rate of 4% (Vanguard standard) add further safety buffers for underperformance or fees.\n\n'
              'All rates are after-tax returns.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
