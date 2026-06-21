import 'dart:async';

import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/pair_ai_logger.dart';

/// Handles WebView microphone and camera permission requests.
class PairAiPermissionHandler {
  PairAiPermissionHandler(this.logger);

  final PairAiLogger logger;

  /// Routes [request] to native permission checks before grant/deny.
  void handle(WebViewPermissionRequest request) {
    logger.log(
      'webview:permission-request: '
      'types=${request.types.map((WebViewPermissionResourceType type) => type.name).join(',')}',
    );

    final bool requestsMicrophone = request.types.contains(
      WebViewPermissionResourceType.microphone,
    );
    final bool requestsCamera = request.types.contains(
      WebViewPermissionResourceType.camera,
    );

    if (!requestsMicrophone && !requestsCamera) {
      logger.log('webview:permission-denied: unsupported-resource');
      unawaited(request.deny());
      return;
    }

    unawaited(_grantWebViewMediaAccess(request));
  }

  Future<void> _grantWebViewMediaAccess(
    WebViewPermissionRequest request,
  ) async {
    if (request.types.contains(WebViewPermissionResourceType.microphone)) {
      final PermissionStatus micStatus = await Permission.microphone.status;
      if (!micStatus.isGranted && !micStatus.isLimited) {
        final PermissionStatus requested = await Permission.microphone.request();
        if (!requested.isGranted && !requested.isLimited) {
          logger.log('webview:permission-denied: microphone');
          await request.deny();
          return;
        }
      }
    }

    if (request.types.contains(WebViewPermissionResourceType.camera)) {
      final PermissionStatus cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted && !cameraStatus.isLimited) {
        final PermissionStatus requested = await Permission.camera.request();
        if (!requested.isGranted && !requested.isLimited) {
          logger.log('webview:permission-denied: camera');
          await request.deny();
          return;
        }
      }
    }

    logger.log(
      'webview:permission-granted: '
      '${request.types.map((WebViewPermissionResourceType type) => type.name).join(',')}',
    );
    await request.grant();
  }
}
