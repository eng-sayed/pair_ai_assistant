package ai.trypair.assistant.webview

import ai.trypair.assistant.util.PairAiLogger
import android.app.Activity
import android.content.Context
import android.net.Uri
import android.webkit.ValueCallback
import android.webkit.WebChromeClient
import android.webkit.WebView
import androidx.activity.result.ActivityResultCaller
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.FileProvider
import java.io.File

/**
 * Bridges Android WebView file chooser requests to native pickers.
 *
 * Mirrors [PairAiAndroidFileSelector] from the Flutter package.
 */
class PairAiFileChooserHelper(
    private val context: Context,
    host: ActivityResultCaller,
    private val logger: PairAiLogger,
    private val permissionHelper: PairAiPermissionHelper,
) {
    private var filePathCallback: ValueCallback<Array<Uri>>? = null
    private var pendingCaptureUri: Uri? = null

    private val takePictureLauncher = host.registerForActivityResult(
        ActivityResultContracts.TakePicture(),
    ) { success ->
        deliverCaptureResult(success)
    }

    private val captureVideoLauncher = host.registerForActivityResult(
        ActivityResultContracts.CaptureVideo(),
    ) { success ->
        deliverCaptureResult(success)
    }

    private val pickVisualMediaLauncher = host.registerForActivityResult(
        ActivityResultContracts.PickVisualMedia(),
    ) { uri ->
        deliverResult(uri?.let { arrayOf(it) })
    }

    private val pickMultipleVisualMediaLauncher = host.registerForActivityResult(
        ActivityResultContracts.PickMultipleVisualMedia(),
    ) { uris ->
        deliverResult(
            if (uris.isNullOrEmpty()) {
                null
            } else {
                uris.toTypedArray()
            },
        )
    }

    private val openDocumentLauncher = host.registerForActivityResult(
        ActivityResultContracts.OpenDocument(),
    ) { uri ->
        deliverResult(uri?.let { arrayOf(it) })
    }

    private val openMultipleDocumentsLauncher = host.registerForActivityResult(
        ActivityResultContracts.OpenMultipleDocuments(),
    ) { uris ->
        deliverResult(
            if (uris.isNullOrEmpty()) {
                null
            } else {
                uris.toTypedArray()
            },
        )
    }

    fun onShowFileChooser(
        @Suppress("UNUSED_PARAMETER") webView: WebView,
        filePathCallback: ValueCallback<Array<Uri>>,
        fileChooserParams: WebChromeClient.FileChooserParams,
    ): Boolean {
        cancelPendingCallback()

        this.filePathCallback = filePathCallback

        val acceptTypes = fileChooserParams.acceptTypes?.toList().orEmpty()
        val mode = fileChooserParams.mode
        val isCaptureEnabled = fileChooserParams.isCaptureEnabled

        logger.log(
            "android:file-selector:open mode=$mode capture=$isCaptureEnabled " +
                "accept=${acceptTypes.joinToString(",")}",
        )

        try {
            if (isCaptureEnabled) {
                val wantsVideo = acceptTypes.isNotEmpty() &&
                    acceptTypes.all { type ->
                        type.startsWith("video/") || type == "video/*"
                    }
                if (wantsVideo) {
                    launchVideoCapture()
                } else {
                    launchImageCapture()
                }
                return true
            }

            if (isImageOnlyRequest(acceptTypes)) {
                if (mode == WebChromeClient.FileChooserParams.MODE_OPEN_MULTIPLE) {
                    pickMultipleVisualMediaLauncher.launch(
                        PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly),
                    )
                } else {
                    pickVisualMediaLauncher.launch(
                        PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly),
                    )
                }
                return true
            }

            val mimeTypes = acceptTypes.filter { it.isNotBlank() }.toTypedArray()
            if (mode == WebChromeClient.FileChooserParams.MODE_OPEN_MULTIPLE) {
                openMultipleDocumentsLauncher.launch(
                    if (mimeTypes.isEmpty()) arrayOf("*/*") else mimeTypes,
                )
            } else {
                openDocumentLauncher.launch(
                    if (mimeTypes.isEmpty()) arrayOf("*/*") else mimeTypes,
                )
            }
            return true
        } catch (error: Exception) {
            logger.log("android:file-selector:error: $error")
            deliverResult(null)
            return false
        }
    }

    fun destroy() {
        cancelPendingCallback()
    }

    private fun launchImageCapture() {
        permissionHelper.requestCameraPermission { granted ->
            if (!granted) {
                deliverResult(null)
                return@requestCameraPermission
            }
            val uri = createCaptureUri(isVideo = false)
            pendingCaptureUri = uri
            takePictureLauncher.launch(uri)
        }
    }

    private fun launchVideoCapture() {
        permissionHelper.requestCameraPermission { granted ->
            if (!granted) {
                deliverResult(null)
                return@requestCameraPermission
            }
            val uri = createCaptureUri(isVideo = true)
            pendingCaptureUri = uri
            captureVideoLauncher.launch(uri)
        }
    }

    private fun createCaptureUri(isVideo: Boolean): Uri {
        val extension = if (isVideo) "mp4" else "jpg"
        val file = File(
            context.cacheDir,
            "pairai_capture_${System.currentTimeMillis()}.$extension",
        )
        return FileProvider.getUriForFile(
            context,
            "${context.packageName}.pairai.fileprovider",
            file,
        )
    }

    private fun deliverCaptureResult(success: Boolean) {
        val uri = pendingCaptureUri
        pendingCaptureUri = null
        deliverResult(if (success && uri != null) arrayOf(uri) else null)
    }

    private fun deliverResult(uris: Array<Uri>?) {
        filePathCallback?.onReceiveValue(uris)
        filePathCallback = null
    }

    private fun cancelPendingCallback() {
        filePathCallback?.onReceiveValue(null)
        filePathCallback = null
        pendingCaptureUri = null
    }

    private fun isImageMimeOrExtension(type: String): Boolean {
        return type.startsWith("image/") ||
            type == "image/*" ||
            type == ".png" ||
            type == ".jpg" ||
            type == ".jpeg" ||
            type == ".webp" ||
            type == ".gif"
    }

    private fun isImageOnlyRequest(acceptTypes: List<String>): Boolean {
        if (acceptTypes.isEmpty()) {
            return false
        }
        return acceptTypes.all { isImageMimeOrExtension(it) }
    }

}
