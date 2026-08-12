import UIKit

/// Full-screen view controller wrapper around [PairAiWebView].
public final class PairAiViewController: UIViewController {
    private let pairWebView: PairAiWebView

    /// Creates a view controller that embeds a Pair AI widget.
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
        self.pairWebView = PairAiWebView(
            config: config,
            onDebugLog: onDebugLog,
            onPageFinished: onPageFinished,
            onEvent: onEvent
        )
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        view.backgroundColor = pairWebView.backgroundColor

        pairWebView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pairWebView)
        NSLayoutConstraint.activate([
            pairWebView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pairWebView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            pairWebView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            pairWebView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }

    /// The embedded Pair AI WebView.
    public var webView: PairAiWebView {
        pairWebView
    }
}
