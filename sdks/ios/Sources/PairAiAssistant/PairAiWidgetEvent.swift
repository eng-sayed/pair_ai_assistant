import Foundation

/// A widget event forwarded from the WebView to the host app.
public struct PairAiWidgetEvent {
    /// Event name from the widget iframe, e.g. `widget:ready`.
    public let type: String

    /// Original `event.data` object from the iframe message.
    public let data: [String: Any]

    /// Origin that sent the message.
    public let origin: String

    /// Timestamp supplied by the internal bridge, when available.
    public let timestamp: Date

    /// Parses a JSON payload posted on the `PairAssistantEvents` channel.
    public static func tryParse(_ message: String) -> PairAiWidgetEvent? {
        guard let raw = message.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: raw) as? [String: Any],
              let type = obj["type"] as? String,
              !type.isEmpty
        else {
            return nil
        }

        let data = obj["data"] as? [String: Any] ?? [:]
        let origin = obj["origin"] as? String ?? ""
        let timestamp: Date
        if let ts = obj["ts"] as? String {
            timestamp = ISO8601DateFormatter().date(from: ts) ?? Date(timeIntervalSince1970: 0)
        } else {
            timestamp = Date(timeIntervalSince1970: 0)
        }

        return PairAiWidgetEvent(
            type: type,
            data: data,
            origin: origin,
            timestamp: timestamp
        )
    }
}
