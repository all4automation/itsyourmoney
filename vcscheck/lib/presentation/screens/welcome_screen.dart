import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';
import '../providers/preferences_provider.dart';
import '../providers/user_input_provider.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final savedInput = ref.watch(savedInputProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Icon(
                Icons.show_chart_rounded,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                'Plan Your\nFinancial Future',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'See where your wealth could be in 10, 20 or 30 years — based on just a few numbers.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(flex: 2),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.input),
                child: const Text('Get Started'),
              ),
              const SizedBox(height: 12),
              savedInput.when(
                data: (input) => input != null
                    ? TextButton(
                        onPressed: () {
                          ref.read(userInputProvider.notifier).update(input);
                          context.go(AppRoutes.results);
                        },
                        child: const Text('Load Previous Plan'),
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, e) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
