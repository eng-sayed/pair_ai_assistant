import 'package:flutter_test/flutter_test.dart';
import 'package:pair_ai_assistant/pair_ai_assistant.dart';

void main() {
  test('empty embedScript throws assertion', () {
    expect(
      () => PairAiEmbedConfig(embedScript: '   ', baseUrl: 'https://example.com'),
      throwsA(isA<AssertionError>()),
    );
  });

  test('invalid baseUrl throws assertion', () {
    expect(
      () => PairAiEmbedConfig(embedScript: '<script></script>', baseUrl: 'ftp://x'),
      throwsA(isA<AssertionError>()),
    );
  });

  test('valid config stores fields', () {
    final PairAiEmbedConfig config = PairAiEmbedConfig(
      embedScript: '<script>ok</script>',
      baseUrl: 'https://widgets-test.trypair.ai',
      enableDebugBridge: true,
    );

    expect(config.embedScript, '<script>ok</script>');
    expect(config.baseUrl, 'https://widgets-test.trypair.ai');
    expect(config.enableDebugBridge, isTrue);
  });
}
