package ai.trypair.assistant.webview

import ai.trypair.assistant.util.PairAiLogger
import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.webkit.PermissionRequest
import androidx.activity.result.ActivityResultCaller
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat

/** Handles WebView microphone and camera permission requests. */
class PairAiPermissionHelper(
    host: ActivityResultCaller,
    private val activity: Activity,
    private val logger: PairAiLogger,
) {
    private var pendingRequest: PermissionRequest? = null

    private val permissionLauncher = host.registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions(),
    ) { results ->
        val request = pendingRequest
        if (request != null) {
            pendingRequest = null
            finishWebViewPermissionRequest(request, results)
            return@registerForActivityResult
        }

        val callback = pendingCameraCallback
        if (callback != null) {
            pendingCameraCallback = null
            callback(results[Manifest.permission.CAMERA] == true)
        }
    }

    private var pendingCameraCallback: ((Boolean) -> Unit)? = null

    /** Routes [request] to native permission checks before grant/deny. */
    fun handle(request: PermissionRequest) {
        logger.log(
            "webview:permission-request: types=${request.resources.joinToString(",")}",
        )

        val requestsMicrophone = request.resources.contains(PermissionRequest.RESOURCE_AUDIO_CAPTURE)
        val requestsCamera = request.resources.contains(PermissionRequest.RESOURCE_VIDEO_CAPTURE)

        if (!requestsMicrophone && !requestsCamera) {
            logger.log("webview:permission-denied: unsupported-resource")
            request.deny()
            return
        }

        val permissionsToRequest = mutableListOf<String>()
        if (requestsMicrophone &&
            !isPermissionGranted(Manifest.permission.RECORD_AUDIO)
        ) {
            permissionsToRequest.add(Manifest.permission.RECORD_AUDIO)
        }
        if (requestsCamera && !isPermissionGranted(Manifest.permission.CAMERA)) {
            permissionsToRequest.add(Manifest.permission.CAMERA)
        }

        if (permissionsToRequest.isEmpty()) {
            logger.log(
                "webview:permission-granted: ${request.resources.joinToString(",")}",
            )
            request.grant(request.resources)
            return
        }

        pendingRequest = request
        permissionLauncher.launch(permissionsToRequest.toTypedArray())
    }

    fun hasCameraPermission(): Boolean = isPermissionGranted(Manifest.permission.CAMERA)

    fun requestCameraPermission(onResult: (Boolean) -> Unit) {
        if (hasCameraPermission()) {
            onResult(true)
            return
        }
        pendingCameraCallback = onResult
        permissionLauncher.launch(arrayOf(Manifest.permission.CAMERA))
    }

    private fun finishWebViewPermissionRequest(
        request: PermissionRequest,
        results: Map<String, Boolean>,
    ) {
        val requestsMicrophone = request.resources.contains(PermissionRequest.RESOURCE_AUDIO_CAPTURE)
        val requestsCamera = request.resources.contains(PermissionRequest.RESOURCE_VIDEO_CAPTURE)

        val microphoneGranted = !requestsMicrophone ||
            results[Manifest.permission.RECORD_AUDIO] == true
        val cameraGranted = !requestsCamera ||
            results[Manifest.permission.CAMERA] == true

        if (microphoneGranted && cameraGranted) {
            logger.log(
                "webview:permission-granted: ${request.resources.joinToString(",")}",
            )
            request.grant(request.resources)
        } else {
            if (requestsMicrophone && results[Manifest.permission.RECORD_AUDIO] != true) {
                logger.log("webview:permission-denied: microphone")
            }
            if (requestsCamera && results[Manifest.permission.CAMERA] != true) {
                logger.log("webview:permission-denied: camera")
            }
            request.deny()
        }
    }

    private fun isPermissionGranted(permission: String): Boolean {
        return ContextCompat.checkSelfPermission(activity, permission) ==
            PackageManager.PERMISSION_GRANTED
    }
}
