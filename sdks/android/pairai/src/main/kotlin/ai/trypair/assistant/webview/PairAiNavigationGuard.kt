package ai.trypair.assistant.webview

import android.net.Uri

/** Validates WebView navigation URLs against an allow-list of origins. */
class PairAiNavigationGuard(
    private val allowedOrigins: Set<String>,
) {
    /** Returns whether [url] may be loaded in the WebView. */
    fun isAllowed(url: String): Boolean {
        val uri = Uri.parse(url)
        if (uri.scheme == null && uri.host == null && !url.contains("://")) {
            return false
        }

        if (uri.scheme == "about" && (uri.path == "blank" || uri.path.isNullOrEmpty())) {
            return true
        }

        if (uri.scheme != "http" && uri.scheme != "https") {
            return false
        }

        if (uri.host.isNullOrEmpty()) {
            return false
        }

        return allowedOrigins.contains(originFor(uri))
    }

    companion object {
        /** Builds the origin string for [uri] (scheme + host + non-default port). */
        fun originForUri(uri: Uri): String = originFor(uri)

        internal fun originFor(uri: Uri): String {
            val isDefaultPort = (uri.scheme == "http" && uri.port == 80) ||
                (uri.scheme == "https" && uri.port == 443) ||
                uri.port == -1
            return if (isDefaultPort) {
                "${uri.scheme}://${uri.host}"
            } else {
                "${uri.scheme}://${uri.host}:${uri.port}"
            }
        }
    }
}
