import PairAiAssistant
import UIKit

final class ViewController: UIViewController {
    private var pairView: PairAiWebView?
    private let eventLabel = UILabel()
    private let sendButton = UIButton(type: .system)

    /// Same-window `postMessage` used by the demo button.
    /// The HTML shell already listens and forwards `widget:` / `form:` payloads to `onEvent`.
    private static let postMessageJs = """
    window.postMessage({
      type: 'widget:demo',
      message: 'Hello from window.postMessage'
    }, window.location.origin);
    """

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureChrome()

        do {
            let config = try PairAiEmbedConfig(
                embedScript: kPairAiEmbedScript,
                baseUrl: kPairAiBaseUrl,
                enableDebugBridge: true
            )
            let pairView = PairAiWebView(
                config: config,
                onDebugLog: { log in
                    print("[PairAiDebug] \(log)")
                },
                onPageFinished: { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.sendButton.isEnabled = true
                    }
                },
                onEvent: { [weak self] event in
                    DispatchQueue.main.async {
                        self?.showEvent(event)
                    }
                }
            )
            self.pairView = pairView
            pairView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(pairView)
            NSLayoutConstraint.activate([
                pairView.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 12),
                pairView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                pairView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                pairView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
        } catch {
            let label = UILabel()
            label.text = "Pair AI config error: \(error)"
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            ])
        }
    }

    private func configureChrome() {
        eventLabel.text = "No event yet"
        eventLabel.numberOfLines = 0
        eventLabel.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        eventLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(eventLabel)

        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.title = "Send window.postMessage"
        buttonConfig.image = UIImage(systemName: "paperplane.fill")
        buttonConfig.imagePadding = 8
        sendButton.configuration = buttonConfig
        sendButton.isEnabled = false
        sendButton.addTarget(self, action: #selector(sendPostMessage), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sendButton)

        NSLayoutConstraint.activate([
            eventLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            eventLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            eventLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sendButton.topAnchor.constraint(equalTo: eventLabel.bottomAnchor, constant: 12),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    @objc private func sendPostMessage() {
        pairView?.underlyingWebView.evaluateJavaScript(Self.postMessageJs) { _, error in
            if let error {
                print("[PairAiDemo] postMessage failed: \(error)")
            }
        }
    }

    private func showEvent(_ event: PairAiWidgetEvent) {
        print("[PairAiEvent] \(event.type) \(event.data)")
        eventLabel.text = "\(event.type)\n\(event.data)"
    }
}
