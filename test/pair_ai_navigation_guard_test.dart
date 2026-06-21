import 'package:flutter_test/flutter_test.dart';
import 'package:pair_ai_assistant/src/utils/pair_ai_navigation_guard.dart';

void main() {
  late PairAiNavigationGuard guard;

  setUp(() {
    guard = PairAiNavigationGuard(<String>{
      'https://widgets-test.trypair.ai',
    });
  });

  test('allows same-origin https navigation', () {
    expect(
      guard.isAllowed('https://widgets-test.trypair.ai/sdk.js'),
      isTrue,
    );
  });

  test('allows about:blank', () {
    expect(guard.isAllowed('about:blank'), isTrue);
  });

  test('blocks javascript scheme', () {
    expect(guard.isAllowed('javascript:alert(1)'), isFalse);
  });

  test('blocks foreign origins', () {
    expect(guard.isAllowed('https://evil.example/phish'), isFalse);
  });

  test('blocks invalid URLs', () {
    expect(guard.isAllowed('not a url'), isFalse);
  });
}
