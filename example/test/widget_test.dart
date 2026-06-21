import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('Demo screen builds', (WidgetTester tester) async {
    await tester.pumpWidget(const PairAiAssistantExampleApp());
    expect(find.text('Pair AI Assistant — Demo'), findsOneWidget);
  });
}
