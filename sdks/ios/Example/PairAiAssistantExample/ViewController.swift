import PairAiAssistant
import UIKit

final class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

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
                onEvent: { event in
                    print("[PairAiEvent] \(event.type) \(event.data)")
                }
            )
            pairView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(pairView)
            NSLayoutConstraint.activate([
                pairView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
}
