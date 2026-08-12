import 'package:flutter_test/flutter_test.dart';
import 'package:pair_ai_assistant/src/html/pair_ai_html_shell.dart';
import 'package:pair_ai_assistant/pair_ai_assistant.dart';

void main() {
  const String embedScript = '<script>window.PairAiWidgetSettings = {}</script>';

  test('generated HTML contains doctype, lang, and verbatim embed script', () {
    final PairAiEmbedConfig config = PairAiEmbedConfig(
      embedScript: embedScript,
      baseUrl: 'https://widgets-test.trypair.ai',
      enableArabicFontFix: true,
      enableDebugBridge: false,
      enableIframeMediaPermissions: false,
    );

    final String html = PairAiHtmlShell.build(config);

    expect(html, contains('<!DOCTYPE html>'));
    expect(html, contains('<html lang="ar">'));
    expect(html, contains(embedScript));
    expect(html, contains('Noto+Sans+Arabic'));
    expect(html, isNot(contains('__PAIR_AI_ASSISTANT_DEBUG__')));
    expect(html, isNot(contains('__PAIR_AI_ASSISTANT_EVENTS__')));
  });

  test('debug bridge script is injected when enabled', () {
    final PairAiEmbedConfig config = PairAiEmbedConfig(
      embedScript: embedScript,
      baseUrl: 'https://widgets-test.trypair.ai',
      enableDebugBridge: true,
      enableIframeMediaPermissions: false,
    );

    final String html = PairAiHtmlShell.build(config);

    expect(html, contains('__PAIR_AI_ASSISTANT_DEBUG__'));
  });
}
