import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pair_ai_assistant/src/config/pair_ai_embed_config.dart';
import 'package:pair_ai_assistant/src/html/pair_ai_html_shell.dart';

void main() {
  test('write golden HTML fixture for native SDKs', () {
    const String embedScript = '<script>window.PairAiWidgetSettings = {}</script>';
    final PairAiEmbedConfig config = PairAiEmbedConfig(
      embedScript: embedScript,
      baseUrl: 'https://widgets-test.trypair.ai',
      enableArabicFontFix: true,
      enableDebugBridge: false,
      enableIframeMediaPermissions: true,
      htmlLang: 'ar',
    );

    final String html = PairAiHtmlShell.build(config);
    final List<String> fixturePaths = <String>[
      'sdks/android/pairai/src/test/resources/html_shell_golden.html',
      'sdks/ios/Tests/PairAiAssistantTests/Fixtures/html_shell_golden.html',
    ];
    for (final String path in fixturePaths) {
      final File fixture = File(path);
      fixture.parent.createSync(recursive: true);
      fixture.writeAsStringSync(html);
    }
    expect(html, isNotEmpty);
  });
}
