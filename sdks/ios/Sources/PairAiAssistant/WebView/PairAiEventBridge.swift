import Foundation
import WebKit

/// Forwards JavaScript widget events from the `PairAssistantEvents` channel.
final class PairAiEventBridge: NSObject, WKScriptMessageHandler {
    private let onEvent: ((PairAiWidgetEvent) -> Void)?

    init(onEvent: ((PairAiWidgetEvent) -> Void)?) {
        self.onEvent = onEvent
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        let raw: String
        if let body = message.body as? String {
            raw = body
        } else if let body = message.body as? [String: Any],
                  let data = try? JSONSerialization.data(withJSONObject: body),
                  let encoded = String(data: data, encoding: .utf8) {
            raw = encoded
        } else {
            return
        }

        guard let event = PairAiWidgetEvent.tryParse(raw) else {
            return
        }
        onEvent?(event)
    }
}
