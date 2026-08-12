package ai.trypair.assistant

import android.graphics.Color
import android.net.Uri
import android.os.Parcelable
import ai.trypair.assistant.webview.PairAiNavigationGuard
import kotlinx.parcelize.Parcelize

/**
 * Configuration for embedding a Pair AI widget script inside a WebView.
 *
 * Construct via [Builder] for Java-friendly validation, or use the primary constructor
 * when all fields are already validated.
 */
@Parcelize
data class PairAiEmbedConfig(
    val embedScript: String,
    val baseUrl: String,
    val userAgent: String? = null,
    val backgroundColor: Int = Color.WHITE,
    val enableArabicFontFix: Boolean = true,
    val enableIframeMediaPermissions: Boolean = true,
    val enableDebugBridge: Boolean = false,
    val enableEventBridge: Boolean = false,
    val debugLogTag: String = "PairAiAssistant",
    val resizeToAvoidBottomInset: Boolean = true,
    val htmlLang: String = "ar",
    val extraHeadHtml: String? = null,
    val restrictNavigation: Boolean = true,
    val allowedNavigationOrigins: Set<String> = emptySet(),
) : Parcelable {

    /** Java-friendly builder with the same validation rules as the Flutter package. */
    class Builder {
        private var embedScript: String = ""
        private var baseUrl: String = ""
        private var userAgent: String? = null
        private var backgroundColor: Int = Color.WHITE
        private var enableArabicFontFix: Boolean = true
        private var enableIframeMediaPermissions: Boolean = true
        private var enableDebugBridge: Boolean = false
        private var enableEventBridge: Boolean = false
        private var debugLogTag: String = "PairAiAssistant"
        private var resizeToAvoidBottomInset: Boolean = true
        private var htmlLang: String = "ar"
        private var extraHeadHtml: String? = null
        private var restrictNavigation: Boolean = true
        private var allowedNavigationOrigins: List<String>? = null

        fun embedScript(value: String) = apply { embedScript = value }
        fun baseUrl(value: String) = apply { baseUrl = value }
        fun userAgent(value: String?) = apply { userAgent = value }
        fun backgroundColor(@androidx.annotation.ColorInt value: Int) = apply { backgroundColor = value }
        fun enableArabicFontFix(value: Boolean) = apply { enableArabicFontFix = value }
        fun enableIframeMediaPermissions(value: Boolean) = apply { enableIframeMediaPermissions = value }
        fun enableDebugBridge(value: Boolean) = apply { enableDebugBridge = value }
        fun enableEventBridge(value: Boolean) = apply { enableEventBridge = value }
        fun debugLogTag(value: String) = apply { debugLogTag = value }
        fun resizeToAvoidBottomInset(value: Boolean) = apply { resizeToAvoidBottomInset = value }
        fun htmlLang(value: String) = apply { htmlLang = value }
        fun extraHeadHtml(value: String?) = apply { extraHeadHtml = value }
        fun restrictNavigation(value: Boolean) = apply { restrictNavigation = value }
        fun allowedNavigationOrigins(value: List<String>?) = apply { allowedNavigationOrigins = value }

        fun build(): PairAiEmbedConfig = create(
            embedScript = embedScript,
            baseUrl = baseUrl,
            userAgent = userAgent,
            backgroundColor = backgroundColor,
            enableArabicFontFix = enableArabicFontFix,
            enableIframeMediaPermissions = enableIframeMediaPermissions,
            enableDebugBridge = enableDebugBridge,
            enableEventBridge = enableEventBridge,
            debugLogTag = debugLogTag,
            resizeToAvoidBottomInset = resizeToAvoidBottomInset,
            htmlLang = htmlLang,
            extraHeadHtml = extraHeadHtml,
            restrictNavigation = restrictNavigation,
            allowedNavigationOrigins = allowedNavigationOrigins,
        )
    }

    companion object {
        private val HTML_LANG_PATTERN = Regex("""^[a-zA-Z]{2,3}(-[a-zA-Z]{2,8})*$""")

        /**
         * Creates a validated embed configuration.
         *
         * @throws IllegalArgumentException when [embedScript] is empty, [baseUrl] is not
         *   an HTTP(S) URL, or [htmlLang] is not a valid BCP 47 language tag.
         */
        @JvmStatic
        fun create(
            embedScript: String,
            baseUrl: String,
            userAgent: String? = null,
            backgroundColor: Int = Color.WHITE,
            enableArabicFontFix: Boolean = true,
            enableIframeMediaPermissions: Boolean = true,
            enableDebugBridge: Boolean = false,
            enableEventBridge: Boolean = false,
            debugLogTag: String = "PairAiAssistant",
            resizeToAvoidBottomInset: Boolean = true,
            htmlLang: String = "ar",
            extraHeadHtml: String? = null,
            restrictNavigation: Boolean = true,
            allowedNavigationOrigins: List<String>? = null,
        ): PairAiEmbedConfig {
            require(embedScript.trim().isNotEmpty()) { "embedScript must not be empty" }
            require(baseUrl.startsWith("http://") || baseUrl.startsWith("https://")) {
                "baseUrl must start with http:// or https://"
            }
            require(HTML_LANG_PATTERN.matches(htmlLang)) {
                "htmlLang must be a valid BCP 47 language tag (e.g. ar, en, ar-SA)"
            }

            val baseUri = Uri.parse(baseUrl)
            val origins = linkedSetOf<String>().apply {
                add(PairAiNavigationGuard.originForUri(baseUri))
                allowedNavigationOrigins?.let { addAll(it) }
            }

            return PairAiEmbedConfig(
                embedScript = embedScript,
                baseUrl = baseUrl,
                userAgent = userAgent,
                backgroundColor = backgroundColor,
                enableArabicFontFix = enableArabicFontFix,
                enableIframeMediaPermissions = enableIframeMediaPermissions,
                enableDebugBridge = enableDebugBridge,
                enableEventBridge = enableEventBridge,
                debugLogTag = debugLogTag,
                resizeToAvoidBottomInset = resizeToAvoidBottomInset,
                htmlLang = htmlLang,
                extraHeadHtml = extraHeadHtml,
                restrictNavigation = restrictNavigation,
                allowedNavigationOrigins = origins,
            )
        }
    }
}
