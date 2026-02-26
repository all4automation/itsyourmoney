import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/preferences_repository.dart';
import '../../domain/models/user_input.dart';
import '../../router/app_router.dart';
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

  @override
  void initState() {
    super.initState();
    // Pre-fill if user has previous input
    final existing = ref.read(userInputProvider);
    if (existing != null) {
      _currentAgeCtrl.text = existing.currentAge.toString();
      _targetAgeCtrl.text = existing.targetAge.toString();
      _assetsCtrl.text = existing.currentAssets.toStringAsFixed(0);
      _incomeCtrl.text = existing.grossAnnualIncome.toStringAsFixed(0);
      _savingsRateCtrl.text =
          (existing.savingsRate * 100).toStringAsFixed(0);
      _growthRateCtrl.text =
          (existing.incomeGrowthRate * 100).toStringAsFixed(1);
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

  void _onCalculate() async {
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
    );

    ref.read(userInputProvider.notifier).update(input);
    await PreferencesRepository().saveUserInput(input);

    if (mounted) context.go(AppRoutes.loading);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Your Financial Profile')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
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
                suffixText: '€',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                suffixText: '€',
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: ElevatedButton(
            onPressed: _onCalculate,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: const Text('Calculate My Wealth'),
          ),
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
