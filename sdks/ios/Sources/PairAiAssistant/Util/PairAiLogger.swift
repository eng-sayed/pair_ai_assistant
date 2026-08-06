import Foundation

/// Internal logger for [PairAiEmbedConfig.debugLogTag].
final class PairAiLogger: @unchecked Sendable {
    private let config: PairAiEmbedConfig
    private let onDebugLog: (@Sendable (String) -> Void)?

    init(config: PairAiEmbedConfig, onDebugLog: (@Sendable (String) -> Void)? = nil) {
        self.config = config
        self.onDebugLog = onDebugLog
    }

    func log(_ message: String) {
        let formatted = "[\(config.debugLogTag)] \(message)"
        #if DEBUG
        print(formatted)
        #endif
        onDebugLog?(formatted)
    }
}
