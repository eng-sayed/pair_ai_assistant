import '../config/pair_ai_embed_config.dart';
import 'pair_ai_embed_scripts.dart';

/// Builds the HTML document that wraps a verbatim Pair embed script.
abstract final class PairAiHtmlShell {
  /// Generates a complete HTML page for [config].
  ///
  /// [enableEventBridge] overrides [PairAiEmbedConfig.enableEventBridge] when
  /// set, so a host `onEvent` callback can turn the bridge on automatically.
  static String build(
    PairAiEmbedConfig config, {
    bool? enableEventBridge,
  }) {
    final StringBuffer head = StringBuffer()
      ..writeln('<meta charset="utf-8">')
      ..writeln(
        '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
      )
      ..writeln(
        '<meta name="viewport" content="width=device-width, initial-scale=1.0, '
        'maximum-scale=1.0, user-scalable=no">',
      );

    if (config.enableArabicFontFix) {
      head
        ..writeln('<link rel="preconnect" href="https://fonts.googleapis.com">')
        ..writeln(
          '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>',
        )
        ..writeln(
          '<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Arabic'
          ':wght@400;500;600;700&display=swap" rel="stylesheet">',
        )
        ..writeln('<style>')
        ..writeln('html, body { margin: 0; padding: 0; height: 100%; background: #fff; }')
        ..writeln('*, *::before, *::after {')
        ..writeln("  font-family: 'Noto Sans Arabic', 'Geeza Pro', 'Baghdad',")
        ..writeln("    'Damascus', 'Arial Unicode MS', Tahoma, 'Helvetica Neue',")
        ..writeln('    Helvetica, -apple-system, BlinkMacSystemFont,')
        ..writeln("    'Segoe UI', Roboto, ui-sans-serif, system-ui, sans-serif !important;")
        ..writeln('}')
        ..writeln('</style>');
    } else {
      head.writeln(
        '<style>html, body { margin: 0; padding: 0; height: 100%; }</style>',
      );
    }

    if (config.extraHeadHtml != null) {
      head.writeln(config.extraHeadHtml);
    }

    final bool injectEvents = enableEventBridge ?? config.enableEventBridge;
    final StringBuffer bodyPrefix = StringBuffer();
    if (config.enableDebugBridge ||
        config.enableIframeMediaPermissions ||
        injectEvents) {
      bodyPrefix.writeln('<script>');
      if (config.enableIframeMediaPermissions) {
        bodyPrefix.writeln(PairAiEmbedScripts.iframeMediaPermissionsJs);
      }
      if (config.enableDebugBridge) {
        bodyPrefix.writeln(PairAiEmbedScripts.debugBridgeJs);
      }
      if (injectEvents) {
        bodyPrefix.writeln(
          PairAiEmbedScripts.eventBridgeJs(config.allowedNavigationOrigins),
        );
      }
      bodyPrefix.writeln('</script>');
    }

    return '''
<!DOCTYPE html>
<html lang="${config.htmlLang}">
<head>
$head
</head>
<body>
$bodyPrefix${config.embedScript}
</body>
</html>
''';
  }
}
