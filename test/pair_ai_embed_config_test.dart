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

  test('invalid htmlLang throws assertion', () {
    expect(
      () => PairAiEmbedConfig(
        embedScript: '<script></script>',
        baseUrl: 'https://example.com',
        htmlLang: 'ar"><script>alert(1)</script>',
      ),
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
    expect(
      config.allowedNavigationOrigins,
      contains('https://widgets-test.trypair.ai'),
    );
  });

  test('custom allowedNavigationOrigins are stored', () {
    final PairAiEmbedConfig config = PairAiEmbedConfig(
      embedScript: '<script>ok</script>',
      baseUrl: 'https://widgets-test.trypair.ai',
      allowedNavigationOrigins: <String>[
        'https://widgets.trypair.ai',
        'https://cdn.trypair.ai',
      ],
    );

    expect(config.allowedNavigationOrigins, hasLength(3));
    expect(config.allowedNavigationOrigins, contains('https://widgets-test.trypair.ai'));
    expect(config.allowedNavigationOrigins, contains('https://widgets.trypair.ai'));
  });
}
