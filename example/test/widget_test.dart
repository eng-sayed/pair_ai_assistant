import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('demo JS sends window.postMessage', () {
    expect(kDemoPostMessageJs, contains('window.postMessage'));
    expect(kDemoPostMessageJs, contains("type: 'widget:demo'"));
  });
}
