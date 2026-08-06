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
- Navigation origin guard

Golden-string HTML fixtures are shared between Dart, Android, and iOS tests to prevent drift.

## Out of scope (all SDKs)

The structured **event listener bridge** (JS → native callbacks for widget events) is deferred to a follow-up. The debug bridge pattern is the extension point for that work.

## Repository layout

```
sdks/
├── android/          # Gradle project → ai.trypair:pair-ai-assistant
├── ios/              # Swift Package + CocoaPods
└── README.md         # this file
```

See each platform README for install instructions, permissions, and usage examples.
