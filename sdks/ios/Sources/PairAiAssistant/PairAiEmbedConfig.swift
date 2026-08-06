import UIKit

/// Configuration for embedding a Pair AI widget script inside a WKWebView.
public struct PairAiEmbedConfig: Sendable {
    private static let htmlLangPattern = try! NSRegularExpression(
        pattern: #"^[a-zA-Z]{2,3}(-[a-zA-Z]{2,8})*$"#
    )

    /// The complete Pair embed `<script>` block, pasted verbatim from Pair.
    public let embedScript: String

    /// Must match `BASE_URL` inside [embedScript]. Used as `loadHTMLString` base URL.
    public let baseUrl: String

    /// Optional custom WebView user agent.
    public let userAgent: String?

    /// Background color behind the WebView.
    public let backgroundColor: UIColor

    /// Load Noto Sans Arabic and apply a bilingual font stack.
    public let enableArabicFontFix: Bool

    /// Inject JS that adds `allow="microphone; camera"` on iframes.
    public let enableIframeMediaPermissions: Bool

    /// Bridge console/network/media logs to native via `PairAssistantDebug`.
    public let enableDebugBridge: Bool

    /// Prefix for debug log lines.
    public let debugLogTag: String

    /// Passed to scaffold resize behavior in Flutter; no-op on iOS (documented).
    public let resizeToAvoidBottomInset: Bool

    /// `lang` attribute on the generated HTML document.
    public let htmlLang: String

    /// Optional extra markup injected inside `<head>`.
    ///
    /// Only pass trusted markup — it is injected verbatim into the HTML shell.
    public let extraHeadHtml: String?

    /// When `true`, WebView navigation is limited to [allowedNavigationOrigins].
    public let restrictNavigation: Bool

    /// Origins allowed for WebView navigation (defaults to [baseUrl] origin).
    public let allowedNavigationOrigins: Set<String>

    /// Creates a validated embed configuration.
    ///
    /// Throws [PairAiConfigError] when [embedScript] is empty, [baseUrl] is not
    /// an HTTP(S) URL, or [htmlLang] is not a valid BCP 47 language tag.
    public init(
        embedScript: String,
        baseUrl: String,
        userAgent: String? = nil,
        backgroundColor: UIColor = .white,
        enableArabicFontFix: Bool = true,
        enableIframeMediaPermissions: Bool = true,
        enableDebugBridge: Bool = false,
        debugLogTag: String = "PairAiAssistant",
        resizeToAvoidBottomInset: Bool = true,
        htmlLang: String = "ar",
        extraHeadHtml: String? = nil,
        restrictNavigation: Bool = true,
        allowedNavigationOrigins: [String]? = nil
    ) throws {
        guard !embedScript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw PairAiConfigError.emptyEmbedScript
        }
        guard baseUrl.hasPrefix("http://") || baseUrl.hasPrefix("https://") else {
            throw PairAiConfigError.invalidBaseUrl
        }
        guard Self.htmlLangPattern.firstMatch(
            in: htmlLang,
            range: NSRange(htmlLang.startIndex..., in: htmlLang)
        ) != nil else {
            throw PairAiConfigError.invalidHtmlLang
        }

        guard let baseUri = URL(string: baseUrl) else {
            throw PairAiConfigError.invalidBaseUrl
        }

        var origins = Set<String>()
        origins.insert(PairAiNavigationGuard.origin(for: baseUri))
        if let allowedNavigationOrigins {
            origins.formUnion(allowedNavigationOrigins)
        }

        self.embedScript = embedScript
        self.baseUrl = baseUrl
        self.userAgent = userAgent
        self.backgroundColor = backgroundColor
        self.enableArabicFontFix = enableArabicFontFix
        self.enableIframeMediaPermissions = enableIframeMediaPermissions
        self.enableDebugBridge = enableDebugBridge
        self.debugLogTag = debugLogTag
        self.resizeToAvoidBottomInset = resizeToAvoidBottomInset
        self.htmlLang = htmlLang
        self.extraHeadHtml = extraHeadHtml
        self.restrictNavigation = restrictNavigation
        self.allowedNavigationOrigins = origins
    }
}
