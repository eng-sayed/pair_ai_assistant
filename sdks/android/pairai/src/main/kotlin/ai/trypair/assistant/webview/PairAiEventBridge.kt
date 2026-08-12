package ai.trypair.assistant.webview

import ai.trypair.assistant.PairAiWidgetEvent
import android.os.Handler
import android.os.Looper
import android.webkit.JavascriptInterface

/** Forwards JavaScript widget events from the `PairAssistantEvents` channel. */
class PairAiEventBridge(
    private val onEvent: ((PairAiWidgetEvent) -> Unit)?,
) {
    private val mainHandler = Handler(Looper.getMainLooper())

    @JavascriptInterface
    fun postMessage(message: String) {
        val event = PairAiWidgetEvent.tryParse(message) ?: return
        mainHandler.post {
            onEvent?.invoke(event)
        }
    }
}
