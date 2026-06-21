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
