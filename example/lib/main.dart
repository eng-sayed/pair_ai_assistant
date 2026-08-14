import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pair_ai_assistant/pair_ai_assistant.dart';

import 'pair_ai_embed_script.dart';

/// Same-window `postMessage` used by the demo button.
///
/// Matches the [window.postMessage](https://developer.mozilla.org/en-US/docs/Web/API/Window/postMessage)
/// pattern: the HTML shell already listens, and forwards `widget:` / `form:`
/// payloads to [PairAiWidget.onEvent].
const String kDemoPostMessageJs = '''
window.postMessage({
  type: 'widget:demo',
  message: 'Hello from window.postMessage'
}, window.location.origin);
''';

void main() => runApp(const PairAiAssistantExampleApp());

class PairAiAssistantExampleApp extends StatelessWidget {
  const PairAiAssistantExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: DemoScreen());
  }
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  final GlobalKey<PairAiWidgetState> _pairKey = GlobalKey<PairAiWidgetState>();
  PairAiWidgetEvent? _lastEvent;
  bool _pageReady = false;

  Future<void> _sendPostMessage() async {
    await _pairKey.currentState?.runJavaScript(kDemoPostMessageJs);
  }

  void _onEvent(PairAiWidgetEvent event) {
    debugPrint('[PairAiEvent] ${event.type} ${event.data}');
    if (!mounted) {
      return;
    }
    setState(() => _lastEvent = event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Pair AI Assistant — Demo')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    _lastEvent == null
                        ? 'No event yet'
                        : '${_lastEvent!.type}\n${_lastEvent!.data}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _pageReady ? _sendPostMessage : null,
                    icon: const Icon(Icons.send),
                    label: const Text('Send window.postMessage'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: PairAiWidget(
              key: _pairKey,
              config: PairAiEmbedConfig(
                embedScript: kPairAiEmbedScript,
                baseUrl: kPairAiBaseUrl,
                enableDebugBridge: kDebugMode,
              ),
              onDebugLog: debugPrint,
              onPageFinished: (_) {
                if (mounted) {
                  setState(() => _pageReady = true);
                }
              },
              onEvent: _onEvent,
            ),
          ),
        ],
      ),
    );
  }
}
