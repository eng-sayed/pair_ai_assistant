import 'package:flutter/foundation.dart';

import '../config/pair_ai_embed_config.dart';

/// Internal logger for [PairAiEmbedConfig.debugLogTag].
class PairAiLogger {
  PairAiLogger(this.config, [this.onDebugLog]);

  final PairAiEmbedConfig config;
  final void Function(String message)? onDebugLog;

  void log(String message) {
    final String formatted = '[${config.debugLogTag}] $message';
    debugPrint(formatted);
    onDebugLog?.call(formatted);
  }
}
