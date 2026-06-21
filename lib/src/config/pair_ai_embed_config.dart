import 'package:flutter/material.dart';

/// Configuration for embedding a Pair AI widget script inside a WebView.
@immutable
class PairAiEmbedConfig {
  /// Creates a validated embed configuration.
  ///
  /// Throws [AssertionError] when [embedScript] is empty or [baseUrl] is not
  /// an HTTP(S) URL.
  factory PairAiEmbedConfig({
    required String embedScript,
    required String baseUrl,
    String? userAgent,
    Color backgroundColor = const Color(0xFFFFFFFF),
    bool enableArabicFontFix = true,
    bool enableIframeMediaPermissions = true,
    bool enableDebugBridge = false,
    String debugLogTag = 'PairAiAssistant',
    bool resizeToAvoidBottomInset = true,
    String htmlLang = 'ar',
    String? extraHeadHtml,
  }) {
    assert(
      embedScript.trim().isNotEmpty,
      'embedScript must not be empty',
    );
    assert(
      baseUrl.startsWith('http://') || baseUrl.startsWith('https://'),
      'baseUrl must start with http:// or https://',
    );

    return PairAiEmbedConfig._(
      embedScript: embedScript,
      baseUrl: baseUrl,
      userAgent: userAgent,
      backgroundColor: backgroundColor,
      enableArabicFontFix: enableArabicFontFix,
      enableIframeMediaPermissions: enableIframeMediaPermissions,
      enableDebugBridge: enableDebugBridge,
      debugLogTag: debugLogTag,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      htmlLang: htmlLang,
      extraHeadHtml: extraHeadHtml,
    );
  }

  const PairAiEmbedConfig._({
    required this.embedScript,
    required this.baseUrl,
    this.userAgent,
    required this.backgroundColor,
    required this.enableArabicFontFix,
    required this.enableIframeMediaPermissions,
    required this.enableDebugBridge,
    required this.debugLogTag,
    required this.resizeToAvoidBottomInset,
    required this.htmlLang,
    this.extraHeadHtml,
  });

  /// The complete Pair embed `<script>` block, pasted verbatim from Pair.
  final String embedScript;

  /// Must match `BASE_URL` inside [embedScript]. Used as `loadHtmlString` base.
  final String baseUrl;

  /// Optional custom WebView user agent.
  final String? userAgent;

  /// Background color behind the WebView.
  final Color backgroundColor;

  /// Load Noto Sans Arabic and apply a bilingual font stack.
  final bool enableArabicFontFix;

  /// Inject JS that adds `allow="microphone; camera"` on iframes.
  final bool enableIframeMediaPermissions;

  /// Bridge console/network/media logs to Dart via `PairAssistantDebug`.
  final bool enableDebugBridge;

  /// Prefix for debug log lines.
  final String debugLogTag;

  /// Passed to [Scaffold.resizeToAvoidBottomInset] on [PairAiWidgetScreen].
  final bool resizeToAvoidBottomInset;

  /// `lang` attribute on the generated HTML document.
  final String htmlLang;

  /// Optional extra markup injected inside `<head>`.
  final String? extraHeadHtml;
}
