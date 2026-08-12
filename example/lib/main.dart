import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pair_ai_assistant/pair_ai_assistant.dart';

import 'pair_ai_embed_script.dart';

void main() => runApp(const PairAiAssistantExampleApp());

class PairAiAssistantExampleApp extends StatelessWidget {
  const PairAiAssistantExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DemoScreen(),
    );
  }
}

class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PairAiWidgetScreen(
      config: PairAiEmbedConfig(
        embedScript: kPairAiEmbedScript,
        baseUrl: kPairAiBaseUrl,
        enableDebugBridge: kDebugMode,
      ),
      appBar: AppBar(
        title: const Text('Pair AI Assistant — Demo'),
      ),
      onDebugLog: debugPrint,
      onEvent: (PairAiWidgetEvent event) {
        debugPrint('[PairAiEvent] ${event.type} ${event.data}');
      },
    );
  }
}
