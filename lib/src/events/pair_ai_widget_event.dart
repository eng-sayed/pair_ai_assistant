import 'dart:convert';

/// A widget event forwarded from the WebView to the host app.
class PairAiWidgetEvent {
  /// Creates a parsed widget event.
  const PairAiWidgetEvent({
    required this.type,
    required this.data,
    required this.origin,
    required this.timestamp,
  });

  /// Event name from the widget iframe, e.g. `widget:ready`.
  final String type;

  /// Original `event.data` object from the iframe message.
  final Map<String, Object?> data;

  /// Origin that sent the message.
  final String origin;

  /// Timestamp supplied by the internal bridge, when available.
  final DateTime timestamp;

  /// Parses a JSON payload posted on the `PairAssistantEvents` channel.
  ///
  /// Returns `null` when [message] is not a JSON object with a non-empty `type`.
  static PairAiWidgetEvent? tryParse(String message) {
    try {
      final Object? decoded = jsonDecode(message);
      if (decoded is! Map) {
        return null;
      }
      final Map<String, Object?> root = _asStringKeyedMap(decoded);
      final Object? type = root['type'];
      if (type is! String || type.isEmpty) {
        return null;
      }

      final Object? dataRaw = root['data'];
      final Map<String, Object?> data = dataRaw is Map
          ? _asStringKeyedMap(dataRaw)
          : <String, Object?>{};

      final Object? origin = root['origin'];
      final Object? ts = root['ts'];
      return PairAiWidgetEvent(
        type: type,
        data: data,
        origin: origin is String ? origin : '',
        timestamp: ts is String
            ? (DateTime.tryParse(ts) ?? DateTime.fromMillisecondsSinceEpoch(0))
            : DateTime.fromMillisecondsSinceEpoch(0),
      );
    } catch (_) {
      return null;
    }
  }

  static Map<String, Object?> _asStringKeyedMap(Map<dynamic, dynamic> source) {
    return source.map(
      (dynamic key, dynamic value) => MapEntry(key.toString(), value),
    );
  }
}
