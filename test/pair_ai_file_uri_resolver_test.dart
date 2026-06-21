import 'package:flutter_test/flutter_test.dart';
import 'package:pair_ai_assistant/src/utils/pair_ai_file_uri_resolver.dart';

void main() {
  test('content:// URI passes through unchanged', () async {
    const String uri = 'content://media/external/images/media/42';
    final String? result = await PairAiFileUriResolver.asWebViewFileUri(uri);
    expect(result, uri);
  });

  test('nonexistent path returns null', () async {
    final String? result = await PairAiFileUriResolver.asWebViewFileUri(
      '/tmp/pair_ai_assistant_missing_file_${DateTime.now().millisecondsSinceEpoch}.bin',
    );
    expect(result, isNull);
  });
}
