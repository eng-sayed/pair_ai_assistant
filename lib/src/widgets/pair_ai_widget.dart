import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../config/pair_ai_embed_config.dart';
import '../events/pair_ai_widget_event.dart';
import '../utils/pair_ai_logger.dart';
import '../webview/pair_ai_webview_factory.dart';

/// Embeds a Pair AI widget inside a WebView without a [Scaffold].
class PairAiWidget extends StatefulWidget {
  /// Creates a bare WebView widget for a Pair AI embed.
  const PairAiWidget({
    super.key,
    required this.config,
    this.onDebugLog,
    this.onPageFinished,
    this.onEvent,
  });

  /// Embed configuration including the verbatim Pair script.
  final PairAiEmbedConfig config;

  /// Optional callback for debug log lines.
  final void Function(String message)? onDebugLog;

  /// Called when the HTML shell finishes loading.
  final void Function(String url)? onPageFinished;

  /// Called when the widget iframe posts a `widget:` or `form:` event.
  final void Function(PairAiWidgetEvent event)? onEvent;

  @override
  State<PairAiWidget> createState() => PairAiWidgetState();
}

/// State for [PairAiWidget], including helpers to run JavaScript in the WebView.
class PairAiWidgetState extends State<PairAiWidget> {
  late final WebViewController _controller;
  late final PairAiLogger _logger;
  late final PairAiWebViewFactory _factory;

  /// Runs [javaScript] in the embed WebView.
  ///
  /// Example apps use this to send `window.postMessage(...)` and exercise
  /// [PairAiWidget.onEvent].
  Future<void> runJavaScript(String javaScript) {
    return _controller.runJavaScript(javaScript);
  }

  @override
  void initState() {
    super.initState();
    _logger = PairAiLogger(widget.config, widget.onDebugLog);
    _factory = PairAiWebViewFactory(
      config: widget.config,
      logger: _logger,
      onPageFinished: (String url) => widget.onPageFinished?.call(url),
      onEvent: widget.onEvent,
    );
    _controller = _factory.create();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_factory.configurePlatform(_controller));
    });
  }

  @override
  void dispose() {
    _factory.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Default Texture Layer mode — hybrid composition causes a blank screen on
    // some Android GPUs (e.g. Adreno on Oppo/Realme).
    return WebViewWidget(
      controller: _controller,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
      },
    );
  }
}
