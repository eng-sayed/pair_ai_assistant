package ai.trypair.assistant

import ai.trypair.assistant.html.PairAiHtmlShell
import ai.trypair.assistant.util.PairAiLogger
import ai.trypair.assistant.webview.PairAiDebugBridge
import ai.trypair.assistant.webview.PairAiEventBridge
import ai.trypair.assistant.webview.PairAiFileChooserHelper
import ai.trypair.assistant.webview.PairAiPermissionHelper
import ai.trypair.assistant.webview.PairAiWebChromeClient
import ai.trypair.assistant.webview.PairAiWebViewClient
import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.util.AttributeSet
import android.webkit.WebView
import android.widget.FrameLayout
import androidx.activity.result.ActivityResultCaller

/**
 * Embeds a Pair AI widget inside a WebView without an activity chrome wrapper.
 *
 * @param host When null, file picker and permission prompts are disabled.
 */
class PairAiWebView @JvmOverloads constructor(
    context: Context,
    private val config: PairAiEmbedConfig,
    host: ActivityResultCaller? = null,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
    private val onDebugLog: ((String) -> Unit)? = null,
    private val onPageFinished: ((String) -> Unit)? = null,
    private val onEvent: ((PairAiWidgetEvent) -> Unit)? = null,
) : FrameLayout(context, attrs, defStyleAttr) {

    private val logger = PairAiLogger(config, onDebugLog)
    private var disposed = false

    private val permissionHelper: PairAiPermissionHelper?
    private val fileChooserHelper: PairAiFileChooserHelper?
    val webView: WebView
    private val webViewClient: PairAiWebViewClient

    init {
        val activity = context.findActivity()
        if (host != null && activity != null) {
            permissionHelper = PairAiPermissionHelper(host, activity, logger)
            fileChooserHelper = PairAiFileChooserHelper(context, host, logger, permissionHelper)
            logger.log("android:file-selector:configured")
        } else {
            if (host == null) {
                logger.log("host:null — file picker and permission prompts disabled")
            }
            permissionHelper = null
            fileChooserHelper = null
        }

        webView = WebView(context).apply {
            layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
            settings.javaScriptEnabled = true
            settings.domStorageEnabled = true
            settings.mediaPlaybackRequiresUserGesture = false
            settings.allowFileAccess = true
            settings.allowContentAccess = true
            config.userAgent?.let { settings.userAgentString = it }
            setBackgroundColor(config.backgroundColor)
        }

        webViewClient = PairAiWebViewClient(
            config = config,
            logger = logger,
            webView = webView,
            onPageFinishedCallback = { url -> onPageFinished?.invoke(url) },
            isDisposed = { disposed },
        )

        webView.webViewClient = webViewClient
        webView.webChromeClient = PairAiWebChromeClient(
            config = config,
            logger = logger,
            permissionHelper = permissionHelper,
            fileChooserHelper = fileChooserHelper,
        )

        if (config.enableDebugBridge) {
            webView.addJavascriptInterface(PairAiDebugBridge(logger), "PairAssistantDebug")
            WebView.setWebContentsDebuggingEnabled(true)
        }

        val enableEventBridge = config.enableEventBridge || onEvent != null
        if (enableEventBridge) {
            webView.addJavascriptInterface(PairAiEventBridge(onEvent), "PairAssistantEvents")
        }

        addView(webView)
        loadEmbed()
    }

    private fun loadEmbed() {
        val enableEventBridge = config.enableEventBridge || onEvent != null
        val html = PairAiHtmlShell.build(config, enableEventBridge = enableEventBridge)
        webView.loadDataWithBaseURL(config.baseUrl, html, "text/html", "utf-8", null)
    }

    override fun onDetachedFromWindow() {
        disposed = true
        webViewClient.cancelScheduledWork()
        fileChooserHelper?.destroy()
        webView.destroy()
        super.onDetachedFromWindow()
    }

    private fun Context.findActivity(): Activity? {
        var current: Context? = this
        while (current is ContextWrapper) {
            if (current is Activity) {
                return current
            }
            current = current.baseContext
        }
        return null
    }
}
