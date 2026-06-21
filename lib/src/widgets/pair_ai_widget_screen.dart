import 'package:flutter/material.dart';

import '../config/pair_ai_embed_config.dart';
import 'pair_ai_widget.dart';

/// Full-screen scaffold wrapper around [PairAiWidget].
class PairAiWidgetScreen extends StatelessWidget {
  /// Creates a screen that embeds a Pair AI widget.
  const PairAiWidgetScreen({
    super.key,
    required this.config,
    this.appBar,
    this.onDebugLog,
    this.onPageFinished,
  });

  /// Embed configuration including the verbatim Pair script.
  final PairAiEmbedConfig config;

  /// Optional app bar shown above the widget.
  final PreferredSizeWidget? appBar;

  /// Optional callback for debug log lines.
  final void Function(String message)? onDebugLog;

  /// Called when the HTML shell finishes loading.
  final void Function(String url)? onPageFinished;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: config.resizeToAvoidBottomInset,
      appBar: appBar,
      body: PairAiWidget(
        config: config,
        onDebugLog: onDebugLog,
        onPageFinished: onPageFinished,
      ),
    );
  }
}
