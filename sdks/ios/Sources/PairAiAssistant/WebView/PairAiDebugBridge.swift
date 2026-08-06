import WebKit

/// Forwards JavaScript messages from the `PairAssistantDebug` channel to native logs.
final class PairAiDebugBridge: NSObject, WKScriptMessageHandler {
    private let logger: PairAiLogger

    init(logger: PairAiLogger) {
        self.logger = logger
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        if let body = message.body as? String {
            logger.log(body)
        } else {
            logger.log(String(describing: message.body))
        }
    }
}
