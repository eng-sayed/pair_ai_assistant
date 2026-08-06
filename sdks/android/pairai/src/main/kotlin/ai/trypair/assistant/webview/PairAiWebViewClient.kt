package ai.trypair.assistant.webview

import ai.trypair.assistant.PairAiEmbedConfig
import ai.trypair.assistant.html.PairAiEmbedScripts
import ai.trypair.assistant.util.PairAiLogger
import android.os.Handler
import android.os.Looper
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient

/** WebViewClient for Pair AI embeds — navigation guard and Arabic font re-injection. */
class PairAiWebViewClient(
    private val config: PairAiEmbedConfig,
    private val logger: PairAiLogger,
    private val webView: WebView,
    private val onPageFinishedCallback: (String) -> Unit,
    private val isDisposed: () -> Boolean,
) : WebViewClient() {

    private val navigationGuard = PairAiNavigationGuard(config.allowedNavigationOrigins)
    private val handler = Handler(Looper.getMainLooper())
    private val scheduledRunnables = mutableListOf<Runnable>()

    override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
        return shouldOverrideUrlLoading(view, request.url.toString())
    }

    override fun shouldOverrideUrlLoading(view: WebView?, url: String): Boolean {
        if (!config.restrictNavigation || navigationGuard.isAllowed(url)) {
            return false
        }
        logger.log("navigation:blocked: $url")
        return true
    }

    override fun onPageStarted(view: WebView?, url: String?, favicon: android.graphics.Bitmap?) {
        logger.log("page:start: $url")
        super.onPageStarted(view, url, favicon)
    }

    override fun onPageFinished(view: WebView?, url: String?) {
        val finishedUrl = url.orEmpty()
        logger.log("page:finished: $finishedUrl")
        onPageFinishedCallback(finishedUrl)
        scheduleArabicFontFix()
        super.onPageFinished(view, url)
    }

    fun cancelScheduledWork() {
        scheduledRunnables.forEach { handler.removeCallbacks(it) }
        scheduledRunnables.clear()
    }

    private fun scheduleArabicFontFix() {
        cancelScheduledWork()
        if (!config.enableArabicFontFix) {
            return
        }

        val delaysMs = longArrayOf(0L, 300L, 1500L, 4000L)
        for (delay in delaysMs) {
            val runnable = Runnable {
                if (isDisposed()) {
                    return@Runnable
                }
                webView.evaluateJavascript(PairAiEmbedScripts.arabicFontFixJs, null)
            }
            scheduledRunnables.add(runnable)
            handler.postDelayed(runnable, delay)
        }
    }
}
