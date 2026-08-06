import Foundation

/// Validation errors thrown when constructing [PairAiEmbedConfig].
public enum PairAiConfigError: Error, Equatable, LocalizedError {
    case emptyEmbedScript
    case invalidBaseUrl
    case invalidHtmlLang

    public var errorDescription: String? {
        switch self {
        case .emptyEmbedScript:
            return "embedScript must not be empty"
        case .invalidBaseUrl:
            return "baseUrl must start with http:// or https://"
        case .invalidHtmlLang:
            return "htmlLang must be a valid BCP 47 language tag (e.g. ar, en, ar-SA)"
        }
    }
}
