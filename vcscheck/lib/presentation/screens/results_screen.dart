import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/currency_formatter.dart';
import '../../router/app_router.dart';
import '../providers/results_provider.dart';
import '../providers/user_input_provider.dart';
import '../widgets/results/scenario_card.dart';
import '../widgets/results/wealth_line_chart.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(resultsProvider);
    final input = ref.watch(userInputProvider);

    if (results == null || input == null) {
      // Fallback: user navigated here directly without input
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
                tooltip: 'Adjust return rates',
                onPressed: () => context.go(AppRoutes.adjust),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Chart
                WealthLineChart(results: results),
                const SizedBox(height: 12),
                ChartLegend(results: results),
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
                ...results.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ScenarioCard(result: r),
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
                  value: CurrencyFormatter.format(input.initialAnnualSavings),
                ),
                _SummaryRow(
                  label: 'Starting assets',
                  value: CurrencyFormatter.format(input.currentAssets),
                ),
                _SummaryRow(
                  label: 'Income growth',
                  value: CurrencyFormatter.percent(input.incomeGrowthRate),
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
