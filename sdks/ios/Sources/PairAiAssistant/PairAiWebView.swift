import UIKit
import WebKit

/// UIView wrapping a configured WKWebView for Pair AI embeds.
public final class PairAiWebView: UIView {
    private let config: PairAiEmbedConfig
    private let logger: PairAiLogger
    private let webView: WKWebView
    private let uiDelegate: PairAiWKUIDelegate
    private let navigationDelegate: PairAiWKNavigationDelegate
    private var debugBridge: PairAiDebugBridge?
    private var eventBridge: PairAiEventBridge?

    /// Creates a WebView configured for the given embed settings.
    ///
    /// - Parameters:
    ///   - config: Validated embed configuration.
    ///   - onDebugLog: Optional callback for debug log lines.
    ///   - onPageFinished: Called when the HTML shell finishes loading.
    ///   - onEvent: Called when the widget iframe posts a `widget:` or `form:` event.
    public init(
        config: PairAiEmbedConfig,
        onDebugLog: (@Sendable (String) -> Void)? = nil,
        onPageFinished: ((URL) -> Void)? = nil,
        onEvent: ((PairAiWidgetEvent) -> Void)? = nil
    ) {
        self.config = config
        self.logger = PairAiLogger(config: config, onDebugLog: onDebugLog)

        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        if #available(iOS 10.0, *) {
            webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        }
        webConfiguration.defaultWebpagePreferences.allowsContentJavaScript = true

        if config.enableDebugBridge {
            let bridge = PairAiDebugBridge(logger: logger)
            self.debugBridge = bridge
            webConfiguration.userContentController.add(bridge, name: "PairAssistantDebug")
        } else {
            self.debugBridge = nil
        }

        let enableEventBridge = config.enableEventBridge || onEvent != nil
        if enableEventBridge {
            let bridge = PairAiEventBridge(onEvent: onEvent)
            self.eventBridge = bridge
            webConfiguration.userContentController.add(bridge, name: "PairAssistantEvents")
        } else {
            self.eventBridge = nil
        }

        self.uiDelegate = PairAiWKUIDelegate(logger: logger)
        self.navigationDelegate = PairAiWKNavigationDelegate(
            config: config,
            logger: logger,
            onPageFinished: onPageFinished
        )

        self.webView = WKWebView(frame: .zero, configuration: webConfiguration)

        super.init(frame: .zero)

        backgroundColor = config.backgroundColor
        webView.backgroundColor = config.backgroundColor
        webView.isOpaque = false
        webView.scrollView.backgroundColor = config.backgroundColor
        webView.uiDelegate = uiDelegate
        webView.navigationDelegate = navigationDelegate

        if let userAgent = config.userAgent {
            webView.customUserAgent = userAgent
        }

        if #available(iOS 16.4, *) {
            if config.enableDebugBridge {
                webView.isInspectable = true
            }
        }

        webView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        loadEmbed()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        navigationDelegate.dispose()
        if debugBridge != nil {
            webView.configuration.userContentController.removeScriptMessageHandler(forName: "PairAssistantDebug")
        }
        if eventBridge != nil {
            webView.configuration.userContentController.removeScriptMessageHandler(forName: "PairAssistantEvents")
        }
    }

    /// The underlying WKWebView instance.
    public var underlyingWebView: WKWebView {
        webView
    }

    private func loadEmbed() {
        let html = PairAiHtmlShell.build(config, enableEventBridge: eventBridge != nil)
        guard let baseURL = URL(string: config.baseUrl) else {
            logger.log("config:error: invalid baseUrl \(config.baseUrl)")
            return
        }
        webView.loadHTMLString(html, baseURL: baseURL)
        logger.log("ios:file-selector:native-wkwebview")
    }
}
