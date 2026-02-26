import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/preferences_repository.dart';
import '../../domain/models/user_input.dart';

final preferencesRepositoryProvider = Provider<PreferencesRepository>(
  (ref) => PreferencesRepository(),
);

final savedInputProvider = FutureProvider<UserInput?>((ref) async {
  final repo = ref.watch(preferencesRepositoryProvider);
  return repo.loadUserInput();
});
