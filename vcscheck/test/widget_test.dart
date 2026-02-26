import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vcscheck/main.dart';

void main() {
  testWidgets('App launches and shows welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: WealthApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Get Started'), findsOneWidget);
  });
}
