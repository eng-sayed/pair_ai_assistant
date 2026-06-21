import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Resolves local file paths to URIs readable by the Android WebView.
class PairAiFileUriResolver {
  /// Returns a WebView-readable URI for [path], or `null` when unavailable.
  static Future<String?> asWebViewFileUri(String path) async {
    if (path.startsWith('content://')) {
      return path;
    }

    final File source = File(path);
    if (!await source.exists()) {
      return null;
    }

    final String tempDir = (await getTemporaryDirectory()).path;
    if (path.startsWith(tempDir)) {
      return Uri.file(source.absolute.path).toString();
    }

    final String fileName = source.uri.pathSegments.isNotEmpty
        ? source.uri.pathSegments.last
        : 'upload';
    final String copiedPath =
        '$tempDir/pair_ai_assistant_${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await source.copy(copiedPath);
    return Uri.file(copiedPath).toString();
  }

  /// Resolves multiple [paths] to WebView-readable URIs.
  static Future<List<String>> asWebViewFileUris(Iterable<String> paths) async {
    final List<String> uris = <String>[];
    for (final String path in paths) {
      final String? uri = await asWebViewFileUri(path);
      if (uri != null) {
        uris.add(uri);
      }
    }
    return uris;
  }
}
