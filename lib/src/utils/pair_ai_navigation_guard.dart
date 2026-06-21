/// Validates WebView navigation URLs against an allow-list of origins.
class PairAiNavigationGuard {
  PairAiNavigationGuard(this.allowedOrigins);

  final Set<String> allowedOrigins;

  /// Returns whether [url] may be loaded in the WebView.
  bool isAllowed(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      return false;
    }

    if (uri.scheme == 'about' && (uri.path == 'blank' || uri.path.isEmpty)) {
      return true;
    }

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return false;
    }

    if (uri.host.isEmpty) {
      return false;
    }

    return allowedOrigins.contains(_originFor(uri));
  }

  /// Builds the origin string for [uri] (scheme + host + non-default port).
  static String originForUri(Uri uri) => _originFor(uri);

  static String _originFor(Uri uri) {
    final bool isDefaultPort = (uri.scheme == 'http' && uri.port == 80) ||
        (uri.scheme == 'https' && uri.port == 443) ||
        uri.port == 0;
    if (isDefaultPort) {
      return '${uri.scheme}://${uri.host}';
    }
    return '${uri.scheme}://${uri.host}:${uri.port}';
  }
}
