import 'package:go_router/go_router.dart';

import '../presentation/screens/adjust_screen.dart';
import '../presentation/screens/input_screen.dart';
import '../presentation/screens/loading_screen.dart';
import '../presentation/screens/results_screen.dart';
import '../presentation/screens/welcome_screen.dart';

abstract class AppRoutes {
  static const welcome = '/';
  static const input = '/input';
  static const loading = '/loading';
  static const results = '/results';
  static const adjust = '/results/adjust';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.welcome,
  routes: [
    GoRoute(
      path: AppRoutes.welcome,
      name: 'welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.input,
      name: 'input',
      builder: (context, state) => const InputScreen(),
    ),
    GoRoute(
      path: AppRoutes.loading,
      name: 'loading',
      builder: (context, state) => const LoadingScreen(),
    ),
    GoRoute(
      path: AppRoutes.results,
      name: 'results',
      builder: (context, state) => const ResultsScreen(),
      routes: [
        GoRoute(
          path: 'adjust',
          name: 'adjust',
          builder: (context, state) => const AdjustScreen(),
        ),
      ],
    ),
  ],
);
