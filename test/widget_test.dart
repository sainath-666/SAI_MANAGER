import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sai_manager/main.dart';

void main() {
  testWidgets('SAI Manager renders dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back, Sai'), findsOneWidget);
    expect(find.text('Tasks Workspace'), findsNothing);
  });
}
