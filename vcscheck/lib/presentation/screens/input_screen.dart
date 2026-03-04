import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/currency_formatter.dart';
import '../../domain/models/user_input.dart';
import '../../router/app_router.dart';
import '../providers/scenario_settings_provider.dart';
import '../providers/user_input_provider.dart';
import '../widgets/input/question_field.dart';

class InputScreen extends ConsumerStatefulWidget {
  const InputScreen({super.key});

  @override
  ConsumerState<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends ConsumerState<InputScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentAgeCtrl = TextEditingController();
  final _targetAgeCtrl = TextEditingController();
  final _assetsCtrl = TextEditingController();
  final _incomeCtrl = TextEditingController();
  final _savingsRateCtrl = TextEditingController();
  final _growthRateCtrl = TextEditingController();

  bool _saveMoreTomorrow = false;
  double _smtBoostRate = 3.0; // shown as percent

  @override
  void initState() {
    super.initState();
    final existing = ref.read(userInputProvider);
    if (existing != null) {
      _currentAgeCtrl.text = existing.currentAge.toString();
      _targetAgeCtrl.text = existing.targetAge.toString();
      _assetsCtrl.text = existing.currentAssets.toStringAsFixed(0);
      _incomeCtrl.text = existing.grossAnnualIncome.toStringAsFixed(0);
      _savingsRateCtrl.text = (existing.savingsRate * 100).toStringAsFixed(0);
      _growthRateCtrl.text = (existing.incomeGrowthRate * 100).toStringAsFixed(1);
      _saveMoreTomorrow = existing.saveMoreTomorrow;
      _smtBoostRate = existing.smtBoostRate * 100;
    }
  }

  @override
  void dispose() {
    _currentAgeCtrl.dispose();
    _targetAgeCtrl.dispose();
    _assetsCtrl.dispose();
    _incomeCtrl.dispose();
    _savingsRateCtrl.dispose();
    _growthRateCtrl.dispose();
    super.dispose();
  }

  void _onCalculate() {
    if (!_formKey.currentState!.validate()) return;

    final currentAge = int.parse(_currentAgeCtrl.text.trim());
    final targetAge = int.parse(_targetAgeCtrl.text.trim());
    final assets = double.parse(_assetsCtrl.text.trim().replaceAll(',', '.'));
    final income = double.parse(_incomeCtrl.text.trim().replaceAll(',', '.'));
    final savingsRate =
        double.parse(_savingsRateCtrl.text.trim().replaceAll(',', '.')) / 100;
    final growthRate =
        double.parse(_growthRateCtrl.text.trim().replaceAll(',', '.')) / 100;

    final input = UserInput(
      currentAge: currentAge,
      targetAge: targetAge,
      currentAssets: assets,
      grossAnnualIncome: income,
      savingsRate: savingsRate,
      incomeGrowthRate: growthRate,
      saveMoreTomorrow: _saveMoreTomorrow,
      smtBoostRate: _smtBoostRate / 100,
    );

    ref.read(userInputProvider.notifier).update(input);
    context.go(AppRoutes.loading);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = ref.watch(currencyProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Financial Profile'),
        actions: [
          DropdownButton<AppCurrency>(
            value: currency,
            underline: const SizedBox(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            items: AppCurrency.values
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text('${c.symbol} ${c.label}'),
                    ))
                .toList(),
            onChanged: (c) {
              if (c != null) {
                ref.read(currencyProvider.notifier).setCurrency(c);
              }
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader('About You'),
              const SizedBox(height: 16),
              QuestionField(
                label: 'Current Age',
                controller: _currentAgeCtrl,
                hint: '35',
                suffixText: 'years',
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1 || n > 120) {
                    return 'Enter a valid age (1–120)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              QuestionField(
                label: 'Target Retirement Age',
                controller: _targetAgeCtrl,
                hint: '65',
                suffixText: 'years',
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  final current = int.tryParse(_currentAgeCtrl.text);
                  if (n == null || n < 1 || n > 120) {
                    return 'Enter a valid age (1–120)';
                  }
                  if (current != null && n <= current) {
                    return 'Must be greater than current age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _SectionHeader('Your Finances'),
              const SizedBox(height: 16),
              QuestionField(
                label: 'Current Investable Assets',
                controller: _assetsCtrl,
                hint: '50000',
                suffixText: currency.symbol,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                infoText:
                    'Include cash, stocks, and retirement accounts.\n\nYour home\'s value is intentionally excluded — you\'ll always need somewhere to live, so we keep it as a safety buffer.',
                validator: (v) {
                  final n = double.tryParse(v?.replaceAll(',', '.') ?? '');
                  if (n == null || n < 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              QuestionField(
                label: 'Gross Annual Income',
                controller: _incomeCtrl,
                hint: '60000',
                suffixText: currency.symbol,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final n = double.tryParse(v?.replaceAll(',', '.') ?? '');
                  if (n == null || n < 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _SectionHeader('Growth Assumptions'),
              const SizedBox(height: 16),
              QuestionField(
                label: 'Annual Savings Rate',
                controller: _savingsRateCtrl,
                hint: '20',
                suffixText: '%',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final n = double.tryParse(v?.replaceAll(',', '.') ?? '');
                  if (n == null || n < 0 || n > 100) {
                    return 'Enter a value between 0 and 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              QuestionField(
                label: 'Expected Annual Income Growth',
                controller: _growthRateCtrl,
                hint: '3',
                suffixText: '%',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final n = double.tryParse(v?.replaceAll(',', '.') ?? '');
                  if (n == null || n < 0 || n > 50) {
                    return 'Enter a value between 0 and 50';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _SectionHeader('Accelerate Your Plan'),
              const SizedBox(height: 16),
              _SmtCard(
                enabled: _saveMoreTomorrow,
                boostRate: _smtBoostRate,
                onToggle: (v) => setState(() => _saveMoreTomorrow = v),
                onBoostChanged: (v) => setState(() => _smtBoostRate = v),
                theme: theme,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _onCalculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: const Text('Calculate My Wealth'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmtCard extends StatelessWidget {
  final bool enabled;
  final double boostRate;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onBoostChanged;
  final ThemeData theme;

  const _SmtCard({
    required this.enabled,
    required this.boostRate,
    required this.onToggle,
    required this.onBoostChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: enabled
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Save More Tomorrow',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Automatically increase your savings rate with each raise — painlessly.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(value: enabled, onChanged: onToggle),
              ],
            ),
            if (enabled) ...[
              const SizedBox(height: 16),
              Text(
                'Extra savings per raise: ${boostRate.toStringAsFixed(1)}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Slider(
                value: boostRate,
                min: 0.5,
                max: 10,
                divisions: 19,
                label: '${boostRate.toStringAsFixed(1)}%',
                onChanged: onBoostChanged,
              ),
              Text(
                'Example: On a 10% raise, ${boostRate.toStringAsFixed(1)}% goes to savings, '
                '${(10 - boostRate).clamp(0, 10).toStringAsFixed(1)}% to lifestyle.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}
