## 0.2.0 — Widget events

- Add `onEvent` on Flutter `PairAiWidget` / `PairAiWidgetScreen`, Android `PairAiWebView` / `PairAiFragment`, and iOS `PairAiWebView` / `PairAiViewController`
- Forward origin-checked `widget:` and `form:` iframe messages as `PairAiWidgetEvent`
- Optional `enableEventBridge` config flag (also turns on automatically when `onEvent` is set)
- Native iOS example app at `sdks/ios/Example`

## 0.1.0 — Initial release

- Embed any Pair AI widget `<script>` verbatim inside a Flutter WebView
- Android: microphone, camera capture, `setOnShowFileSelector` bridging `image_picker` and `file_picker`
- iOS: native WKWebView picker, `allowsInlineMediaPlayback`
- Arabic font fix with Noto Sans Arabic
- Automatic iframe `allow="microphone; camera"` injection
- Optional debug bridge channel `PairAssistantDebug`
- WebView navigation restricted to allowed origins (defaults to `baseUrl`)
- BCP 47 validation for `htmlLang`
- Microphone permission requested on WebView demand (not at startup)
