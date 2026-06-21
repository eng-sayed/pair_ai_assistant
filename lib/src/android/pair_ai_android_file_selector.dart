import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../utils/pair_ai_file_uri_resolver.dart';
import '../utils/pair_ai_logger.dart';

/// Bridges Android WebView file chooser requests to native pickers.
class PairAiAndroidFileSelector {
  PairAiAndroidFileSelector({
    required PairAiLogger logger,
    ImagePicker? imagePicker,
  })  : _logger = logger,
        _imagePicker = imagePicker ?? ImagePicker();

  final PairAiLogger _logger;
  final ImagePicker _imagePicker;

  /// Handles a WebView file selection request on Android.
  Future<List<String>> handle(FileSelectorParams params) async {
    _logger.log(
      'android:file-selector:open '
      'mode=${params.mode.name} '
      'capture=${params.isCaptureEnabled} '
      'accept=${params.acceptTypes.join(',')}',
    );

    try {
      if (params.isCaptureEnabled) {
        final bool wantsVideo = params.acceptTypes.isNotEmpty &&
            params.acceptTypes.every(
              (String type) =>
                  type.startsWith('video/') || type == 'video/*',
            );

        if (wantsVideo) {
          final PermissionStatus cameraStatus =
              await Permission.camera.request();
          if (!cameraStatus.isGranted && !cameraStatus.isLimited) {
            return <String>[];
          }
          final XFile? video = await _imagePicker.pickVideo(
            source: ImageSource.camera,
          );
          if (video == null) {
            return <String>[];
          }
          return PairAiFileUriResolver.asWebViewFileUris(<String>[video.path]);
        }

        final PermissionStatus cameraStatus =
            await Permission.camera.request();
        if (!cameraStatus.isGranted && !cameraStatus.isLimited) {
          return <String>[];
        }
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        if (image == null) {
          return <String>[];
        }
        return PairAiFileUriResolver.asWebViewFileUris(<String>[image.path]);
      }

      if (_isImageOnlyRequest(params.acceptTypes)) {
        if (params.mode == FileSelectorMode.openMultiple) {
          final List<XFile> images = await _imagePicker.pickMultiImage(
            imageQuality: 85,
          );
          return PairAiFileUriResolver.asWebViewFileUris(
            images.map((XFile file) => file.path),
          );
        }

        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        if (image == null) {
          return <String>[];
        }
        return PairAiFileUriResolver.asWebViewFileUris(<String>[image.path]);
      }

      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: params.mode == FileSelectorMode.openMultiple,
        type: FileType.any,
      );
      if (result == null) {
        return <String>[];
      }

      return PairAiFileUriResolver.asWebViewFileUris(
        result.files.map((PlatformFile file) => file.path).whereType<String>(),
      );
    } catch (error, stackTrace) {
      _logger.log('android:file-selector:error: $error');
      debugPrintStack(stackTrace: stackTrace);
      return <String>[];
    }
  }

  bool _isImageMimeOrExtension(String type) {
    return type.startsWith('image/') ||
        type == 'image/*' ||
        type == '.png' ||
        type == '.jpg' ||
        type == '.jpeg' ||
        type == '.webp' ||
        type == '.gif';
  }

  bool _isImageOnlyRequest(List<String> acceptTypes) {
    if (acceptTypes.isEmpty) {
      return false;
    }
    return acceptTypes.every(_isImageMimeOrExtension);
  }
}
