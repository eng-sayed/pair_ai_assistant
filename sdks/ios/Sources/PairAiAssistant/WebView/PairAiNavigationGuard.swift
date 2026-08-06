import Foundation

/// Validates WebView navigation URLs against an allow-list of origins.
public struct PairAiNavigationGuard: Sendable {
    public let allowedOrigins: Set<String>

    public init(_ allowedOrigins: Set<String>) {
        self.allowedOrigins = allowedOrigins
    }

    /// Returns whether [url] may be loaded in the WebView.
    public func isAllowed(_ url: String) -> Bool {
        guard let uri = URL(string: url) else {
            return false
        }

        if uri.scheme == "about" {
            let path = uri.path
            if path == "blank" || path.isEmpty {
                return true
            }
        }

        guard uri.scheme == "http" || uri.scheme == "https" else {
            return false
        }

        guard let host = uri.host, !host.isEmpty else {
            return false
        }

        return allowedOrigins.contains(Self.origin(for: uri))
    }

    /// Builds the origin string for [uri] (scheme + host + non-default port).
    public static func origin(for uri: URL) -> String {
        let scheme = uri.scheme ?? ""
        let host = uri.host ?? ""
        let port = uri.port ?? 0

        let isDefaultPort = (scheme == "http" && port == 80)
            || (scheme == "https" && port == 443)
            || port == 0

        if isDefaultPort {
            return "\(scheme)://\(host)"
        }
        return "\(scheme)://\(host):\(port)"
    }
}
