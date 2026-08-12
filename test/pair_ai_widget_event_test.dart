import 'package:flutter_test/flutter_test.dart';
import 'package:pair_ai_assistant/pair_ai_assistant.dart';
import 'package:pair_ai_assistant/src/html/pair_ai_embed_scripts.dart';
import 'package:pair_ai_assistant/src/html/pair_ai_html_shell.dart';

void main() {
  test('parses widget:ready payload', () {
    const String message = '''
{"type":"widget:ready","data":{"type":"widget:ready"},"origin":"http://localhost:3000","ts":"2026-08-12T21:00:00.000Z"}
''';

    final PairAiWidgetEvent? event = PairAiWidgetEvent.tryParse(message);

    expect(event, isNotNull);
    expect(event!.type, 'widget:ready');
    expect(event.origin, 'http://localhost:3000');
    expect(event.data['type'], 'widget:ready');
  });

  test('parses widget:unreadCount payload', () {
    const String message =
        '{"type":"widget:unreadCount","data":{"type":"widget:unreadCount","count":3},"origin":"https://widgets-test.trypair.ai","ts":"2026-08-12T21:00:00.000Z"}';

    final PairAiWidgetEvent? event = PairAiWidgetEvent.tryParse(message);

    expect(event, isNotNull);
    expect(event!.type, 'widget:unreadCount');
    expect(event.data['count'], 3);
  });

  test('returns null for invalid JSON', () {
    expect(PairAiWidgetEvent.tryParse('not-json'), isNull);
  });

  test('returns null when type is missing', () {
    expect(PairAiWidgetEvent.tryParse('{"data":{}}'), isNull);
  });

  test('event bridge JS includes allowed origins as JSON', () {
    final String js = PairAiEmbedScripts.eventBridgeJs(
      <String>['http://localhost:3000', 'https://widgets-test.trypair.ai'],
    );

    expect(js, contains('__PAIR_AI_ASSISTANT_EVENTS__'));
    expect(js, contains('"http://localhost:3000"'));
    expect(js, contains('"https://widgets-test.trypair.ai"'));
    expect(js, contains('PairAssistantEvents'));
  });

  test('HTML shell injects event bridge when enabled', () {
    final PairAiEmbedConfig config = PairAiEmbedConfig(
      embedScript: '<script>window.PairAiWidgetSettings = {}</script>',
      baseUrl: 'http://localhost:3000',
      enableArabicFontFix: false,
      enableIframeMediaPermissions: false,
      enableDebugBridge: false,
      enableEventBridge: true,
    );

    final String html = PairAiHtmlShell.build(config);

    expect(html, contains('__PAIR_AI_ASSISTANT_EVENTS__'));
    expect(html, contains('"http://localhost:3000"'));
  });

  test('HTML shell omits event bridge when disabled', () {
    final PairAiEmbedConfig config = PairAiEmbedConfig(
      embedScript: '<script>window.PairAiWidgetSettings = {}</script>',
      baseUrl: 'https://widgets-test.trypair.ai',
      enableArabicFontFix: true,
      enableIframeMediaPermissions: true,
      enableDebugBridge: false,
    );

    final String html = PairAiHtmlShell.build(config);

    expect(html, isNot(contains('__PAIR_AI_ASSISTANT_EVENTS__')));
  });
}
