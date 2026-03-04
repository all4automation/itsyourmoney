import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/currency_formatter.dart';
import '../../domain/models/scenario_result.dart';
import '../../router/app_router.dart';
import '../providers/results_provider.dart';
import '../providers/scenario_settings_provider.dart';
import '../providers/user_input_provider.dart';
import '../widgets/results/scenario_card.dart';
import '../widgets/results/wealth_line_chart.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  bool _showReal = false;

  List<ScenarioResult> _applyInflation(
    List<ScenarioResult> results,
    double inflationRate,
    int currentAge,
  ) {
    return results.map((r) {
      final adjustedPoints = r.dataPoints.map((p) {
        final years = p.age - currentAge;
        double factor = 1.0;
        for (int i = 0; i < years; i++) {
          factor *= (1 + inflationRate);
        }
        return YearlyDataPoint(age: p.age, wealth: p.wealth / factor);
      }).toList();
      return ScenarioResult(
        type: r.type,
        returnRate: r.returnRate,
        dataPoints: adjustedPoints,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(resultsProvider);
    final input = ref.watch(userInputProvider);

    if (results == null || input == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No data available.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.welcome),
                child: const Text('Start Over'),
              ),
            ],
          ),
        ),
      );
    }

    final inflationRate = ref.watch(inflationRateProvider);
    final formatter = ref.watch(currencyFormatterProvider);
    final displayResults = _showReal
        ? _applyInflation(results, inflationRate, input.currentAge)
        : results;

    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('Your Wealth Projection'),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Adjust rates',
                onPressed: () => context.go(AppRoutes.adjust),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Chart
                WealthLineChart(results: displayResults, formatter: formatter),
                const SizedBox(height: 12),
                ChartLegend(results: displayResults),
                const SizedBox(height: 16),

                // Nominal / Real toggle
                Center(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: false,
                        label: Text('Nominal'),
                        icon: Icon(Icons.attach_money),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text('Real (today\'s)'),
                        icon: Icon(Icons.trending_down),
                      ),
                    ],
                    selected: {_showReal},
                    onSelectionChanged: (s) =>
                        setState(() => _showReal = s.first),
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                if (_showReal)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Adjusted for ${CurrencyFormatter.percent(inflationRate)} p.a. inflation — showing purchasing power in today\'s money.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                const SizedBox(height: 28),

                // Heading
                Text(
                  'At age ${input.targetAge}, you could have:',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Scenario cards
                ...displayResults.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ScenarioCard(result: r, formatter: formatter),
                    )),

                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),

                // Summary
                Text(
                  'Summary',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _SummaryRow(
                  label: 'Projection horizon',
                  value: '${input.horizonYears} years',
                ),
                _SummaryRow(
                  label: 'Annual contribution (Year 1)',
                  value: formatter.format(input.initialAnnualSavings),
                ),
                _SummaryRow(
                  label: 'Starting assets',
                  value: formatter.format(input.currentAssets),
                ),
                _SummaryRow(
                  label: 'Income growth',
                  value: CurrencyFormatter.percent(input.incomeGrowthRate),
                ),
                if (_showReal)
                  _SummaryRow(
                    label: 'Inflation assumption',
                    value: CurrencyFormatter.percent(inflationRate),
                  ),
                const SizedBox(height: 28),

                // Actions
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.adjust),
                  child: const Text('Adjust Return Rates'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    ref.read(userInputProvider.notifier).clear();
                    context.go(AppRoutes.welcome);
                  },
                  child: const Text('Start Over'),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
