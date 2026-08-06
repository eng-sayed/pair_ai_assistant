import WebKit

/// Handles navigation policy and post-load Arabic font re-injection.
final class PairAiWKNavigationDelegate: NSObject, WKNavigationDelegate {
    private let config: PairAiEmbedConfig
    private let logger: PairAiLogger
    private let navigationGuard: PairAiNavigationGuard
    private let onPageFinished: ((URL) -> Void)?
    private var disposed = false
    private var arabicFontWorkItems: [DispatchWorkItem] = []

    init(
        config: PairAiEmbedConfig,
        logger: PairAiLogger,
        onPageFinished: ((URL) -> Void)?
    ) {
        self.config = config
        self.logger = logger
        self.navigationGuard = PairAiNavigationGuard(config.allowedNavigationOrigins)
        self.onPageFinished = onPageFinished
    }

    func dispose() {
        disposed = true
        arabicFontWorkItems.forEach { $0.cancel() }
        arabicFontWorkItems.removeAll()
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        let urlString = url.absoluteString
        if !config.restrictNavigation || navigationGuard.isAllowed(urlString) {
            decisionHandler(.allow)
            return
        }

        logger.log("navigation:blocked: \(urlString)")
        decisionHandler(.cancel)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let url = webView.url {
            logger.log("page:start: \(url.absoluteString)")
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let url = webView.url {
            logger.log("page:finished: \(url.absoluteString)")
            onPageFinished?(url)
        }
        scheduleArabicFontFix(on: webView)
    }

    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        logger.log("resource:error: description=\(error.localizedDescription)")
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        logger.log("resource:error: description=\(error.localizedDescription)")
    }

    private func scheduleArabicFontFix(on webView: WKWebView) {
        guard config.enableArabicFontFix else {
            return
        }

        arabicFontWorkItems.forEach { $0.cancel() }
        arabicFontWorkItems.removeAll()

        let delays: [TimeInterval] = [0, 0.3, 1.5, 4.0]
        for delay in delays {
            let workItem = DispatchWorkItem { [weak self, weak webView] in
                guard let self, let webView, !self.disposed else {
                    return
                }
                webView.evaluateJavaScript(PairAiEmbedScripts.arabicFontFixJs, completionHandler: nil)
            }
            arabicFontWorkItems.append(workItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
        }
    }
}
