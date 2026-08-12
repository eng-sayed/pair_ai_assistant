# Pair AI Assistant — Native SDKs

This folder contains standalone native SDKs that mirror the [Flutter package](../README.md) for embedding the Pair AI assistant widget outside Flutter.

| SDK | Path | Status |
|-----|------|--------|
| **Android** (AAR / Maven) | [`android/`](android/) | Available |
| **iOS** (SPM / CocoaPods) | [`ios/`](ios/) | Available |

## Which SDK should I use?

- **Flutter app** — use the main [`pair_ai_assistant`](../) package (`pubspec.yaml`).
- **Native Android app** — use [`sdks/android`](android/README.md).
- **Native iOS app** — use [`sdks/ios`](ios/README.md).
- **Kotlin Multiplatform / shared logic** — pick the platform SDK per target.

## Feature parity

Both native SDKs aim for full parity with the Flutter implementation:

- Verbatim Pair `<script>` injection via an HTML shell
- WebView media permissions (microphone / camera)
- File upload (Android native picker bridge; iOS WKWebView native picker)
- Arabic font fix (Noto Sans Arabic)
- Automatic iframe `allow="microphone; camera"`
- Optional debug bridge (`PairAssistantDebug`)
- Widget event callback (`onEvent`) for `widget:` / `form:` messages
- Navigation origin guard

Golden-string HTML fixtures are shared between Dart, Android, and iOS tests to prevent drift.

## Repository layout

```
sdks/
├── android/          # Gradle project → ai.trypair:pair-ai-assistant
├── ios/              # Swift Package + CocoaPods
└── README.md         # this file
```

See each platform README for install instructions, permissions, usage, and the **Widget events** (`onEvent`) section:

- Flutter: [README.md](../README.md#widget-events)
- Android: [android/README.md](android/README.md#widget-events)
- iOS: [ios/README.md](ios/README.md#widget-events)
