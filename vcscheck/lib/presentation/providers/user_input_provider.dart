import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/user_input.dart';

class UserInputNotifier extends StateNotifier<UserInput?> {
  UserInputNotifier() : super(null);

  void update(UserInput input) => state = input;

  void clear() => state = null;
}

final userInputProvider = StateNotifierProvider<UserInputNotifier, UserInput?>(
  (ref) => UserInputNotifier(),
);
