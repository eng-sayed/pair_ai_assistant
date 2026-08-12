import 'package:flutter/material.dart';

import '../utils/pair_ai_navigation_guard.dart';

/// Configuration for embedding a Pair AI widget script inside a WebView.
@immutable
class PairAiEmbedConfig {
  static final RegExp _htmlLangPattern = RegExp(r'^[a-zA-Z]{2,3}(-[a-zA-Z]{2,8})*$');

  /// Creates a validated embed configuration.
  ///
  /// Throws [AssertionError] when [embedScript] is empty, [baseUrl] is not
  /// an HTTP(S) URL, or [htmlLang] is not a valid BCP 47 language tag.
  factory PairAiEmbedConfig({
    required String embedScript,
    required String baseUrl,
    String? userAgent,
    Color backgroundColor = const Color(0xFFFFFFFF),
    bool enableArabicFontFix = true,
    bool enableIframeMediaPermissions = true,
    bool enableDebugBridge = false,
    bool enableEventBridge = false,
    String debugLogTag = 'PairAiAssistant',
    bool resizeToAvoidBottomInset = true,
    String htmlLang = 'ar',
    String? extraHeadHtml,
    bool restrictNavigation = true,
    List<String>? allowedNavigationOrigins,
  }) {
    assert(
      embedScript.trim().isNotEmpty,
      'embedScript must not be empty',
    );
    assert(
      baseUrl.startsWith('http://') || baseUrl.startsWith('https://'),
      'baseUrl must start with http:// or https://',
    );
    assert(
      _htmlLangPattern.hasMatch(htmlLang),
      'htmlLang must be a valid BCP 47 language tag (e.g. ar, en, ar-SA)',
    );

    final Uri baseUri = Uri.parse(baseUrl);
    final Set<String> origins = <String>{
      PairAiNavigationGuard.originForUri(baseUri),
      if (allowedNavigationOrigins != null) ...allowedNavigationOrigins,
    };

    return PairAiEmbedConfig._(
      embedScript: embedScript,
      baseUrl: baseUrl,
      userAgent: userAgent,
      backgroundColor: backgroundColor,
      enableArabicFontFix: enableArabicFontFix,
      enableIframeMediaPermissions: enableIframeMediaPermissions,
      enableDebugBridge: enableDebugBridge,
      enableEventBridge: enableEventBridge,
      debugLogTag: debugLogTag,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      htmlLang: htmlLang,
      extraHeadHtml: extraHeadHtml,
      restrictNavigation: restrictNavigation,
      allowedNavigationOrigins: origins,
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
    required this.enableEventBridge,
    required this.debugLogTag,
    required this.resizeToAvoidBottomInset,
    required this.htmlLang,
    this.extraHeadHtml,
    required this.restrictNavigation,
    required this.allowedNavigationOrigins,
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

  /// Inject the internal widget-event forwarder.
  ///
  /// Also turns on automatically when `onEvent` is passed to [PairAiWidget].
  final bool enableEventBridge;

  /// Prefix for debug log lines.
  final String debugLogTag;

  /// Passed to [Scaffold.resizeToAvoidBottomInset] on [PairAiWidgetScreen].
  final bool resizeToAvoidBottomInset;

  /// `lang` attribute on the generated HTML document.
  final String htmlLang;

  /// Optional extra markup injected inside `<head>`.
  ///
  /// Only pass trusted markup — it is injected verbatim into the HTML shell.
  final String? extraHeadHtml;

  /// When `true`, WebView navigation is limited to [allowedNavigationOrigins].
  final bool restrictNavigation;

  /// Origins allowed for WebView navigation (defaults to [baseUrl] origin).
  final Set<String> allowedNavigationOrigins;
}
