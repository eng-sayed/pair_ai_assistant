import WebKit

/// Handles WKWebView UI delegate callbacks: media capture permissions and file picking.
final class PairAiWKUIDelegate: NSObject, WKUIDelegate {
    private let logger: PairAiLogger

    init(logger: PairAiLogger) {
        self.logger = logger
    }

    @available(iOS 15.0, *)
    func webView(
        _ webView: WKWebView,
        requestMediaCapturePermissionFor origin: WKSecurityOrigin,
        initiatedByFrame frame: WKFrameInfo,
        type: WKMediaCaptureType,
        decisionHandler: @escaping (WKPermissionDecision) -> Void
    ) {
        let typeName: String
        switch type {
        case .camera:
            typeName = "camera"
        case .microphone:
            typeName = "microphone"
        case .cameraAndMicrophone:
            typeName = "camera,microphone"
        @unknown default:
            typeName = "unknown"
        }

        logger.log("webview:permission-request: types=\(typeName)")

        switch type {
        case .camera, .microphone, .cameraAndMicrophone:
            logger.log("webview:permission-granted: \(typeName)")
            decisionHandler(.grant)
        @unknown default:
            logger.log("webview:permission-denied: unsupported-resource")
            decisionHandler(.deny)
        }
    }
}
