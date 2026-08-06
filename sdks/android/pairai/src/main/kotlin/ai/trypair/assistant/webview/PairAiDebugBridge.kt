package ai.trypair.assistant.webview

import ai.trypair.assistant.util.PairAiLogger
import android.webkit.JavascriptInterface

/** Forwards JavaScript debug messages from [PairAiEmbedScripts.debugBridgeJs]. */
class PairAiDebugBridge(
    private val logger: PairAiLogger,
) {
    @JavascriptInterface
    fun postMessage(message: String) {
        logger.log(message)
    }
}
