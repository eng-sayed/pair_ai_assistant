package ai.trypair.assistant.webview

import ai.trypair.assistant.PairAiEmbedConfig
import ai.trypair.assistant.util.PairAiLogger
import android.webkit.ConsoleMessage
import android.webkit.PermissionRequest
import android.webkit.WebChromeClient
import android.webkit.WebView

/** WebChromeClient for Pair AI embeds — permissions, file chooser, and console logging. */
class PairAiWebChromeClient(
    private val config: PairAiEmbedConfig,
    private val logger: PairAiLogger,
    private val permissionHelper: PairAiPermissionHelper?,
    private val fileChooserHelper: PairAiFileChooserHelper?,
) : WebChromeClient() {

    override fun onPermissionRequest(request: PermissionRequest) {
        if (permissionHelper != null) {
            permissionHelper.handle(request)
        } else {
            logger.log("webview:permission-denied: host-unavailable")
            request.deny()
        }
    }

    override fun onShowFileChooser(
        webView: WebView,
        filePathCallback: android.webkit.ValueCallback<Array<android.net.Uri>>,
        fileChooserParams: FileChooserParams,
    ): Boolean {
        if (fileChooserHelper != null) {
            return fileChooserHelper.onShowFileChooser(webView, filePathCallback, fileChooserParams)
        }
        logger.log("android:file-selector:denied: host-unavailable")
        filePathCallback.onReceiveValue(null)
        return false
    }

    override fun onConsoleMessage(consoleMessage: ConsoleMessage): Boolean {
        if (config.enableDebugBridge) {
            logger.log("console:${consoleMessage.messageLevel()}: ${consoleMessage.message()}")
        }
        return super.onConsoleMessage(consoleMessage)
    }
}
