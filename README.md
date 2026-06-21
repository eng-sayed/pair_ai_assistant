# pair_ai_assistant

**v0.1.0** | MIT | Android & iOS | Flutter >=3.22

Embed the **Pair AI assistant widget** in any Flutter app via a `WebView`. Paste the Pair embed `<script>` **verbatim** — the package handles microphone permissions, camera capture, file uploads (Android bridge + iOS native picker), Arabic font rendering, and iframe media permissions.

![Chat screenshot placeholder](docs/screenshot_chat.png)

## What this package does

Pair ships a web embed script for browsers. Mobile apps need a native WebView bridge for `getUserMedia`, file pickers, and secure-context loading. `pair_ai_assistant` wraps your script in an HTML shell, configures `webview_flutter` for Android and iOS, and exposes two widgets: `PairAiWidget` (bare WebView) and `PairAiWidgetScreen` (Scaffold wrapper).

## Features

- Verbatim Pair `<script>` injection — no parsing or modification
- Microphone recording via WebView permission bridge
- Camera capture and gallery/file uploads
- Android `setOnShowFileSelector` via `image_picker` + `file_picker`
- iOS native WKWebView file picker
- Arabic font fix (Noto Sans Arabic)
- Automatic iframe `allow="microphone; camera"`
- Optional debug bridge (`PairAssistantDebug` channel)

## Installation

### Path dependency (monorepo)

```yaml
dependencies:
  pair_ai_assistant:
    path: ../pair_ai_assistant
```

### Git dependency

```yaml
dependencies:
  pair_ai_assistant:
    git:
      url: https://github.com/eng-sayed/pair_ai_assistant.git
      ref: main
```

Then:

```bash
flutter pub get
cd ios && pod install && cd ..
```

## Android setup

Add to `android/app/src/main/AndroidManifest.xml` **before** `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
```

Ensure your main activity has:

```xml
android:hardwareAccelerated="true"
android:windowSoftInputMode="adjustResize"
```

After adding `MODIFY_AUDIO_SETTINGS`, **reinstall** the app (not hot reload).

See also: [`templates/android_manifest_snippet.xml`](templates/android_manifest_snippet.xml)

## iOS setup

Add to `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Used to record voice messages in the AI assistant chat.</string>
<key>NSCameraUsageDescription</key>
<string>Used to capture photos and videos in the AI assistant chat.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Used to attach photos in the AI assistant chat.</string>
```

See also: [`templates/ios_info_plist_snippet.xml`](templates/ios_info_plist_snippet.xml)

## Minimal usage

```dart
import 'package:flutter/material.dart';
import 'package:pair_ai_assistant/pair_ai_assistant.dart';

const String kPairAiEmbedScript = r'''
<script>
      window.PairAiWidgetSettings = {
        position: 'left',
        type: 'standard',
        user_Id: 'YOUR_USER_ID',
        openAutomatically: true,
      }
      ;(function (d, t) {
        var BASE_URL = 'https://widgets-test.trypair.ai'
        var g = d.createElement(t),
          s = d.getElementsByTagName(t)[0]
        g.src = BASE_URL + '/sdk.js'
        g.async = true
        s.parentNode.insertBefore(g, s)
        g.onload = function () {
          window.PairAiWidgetSDK.run({
            widgetId: 'YOUR_WIDGET_ID',
            baseUrl: BASE_URL,
          })
        }
      })(document, 'script')
</script>
''';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PairAiWidgetScreen(
      config: PairAiEmbedConfig(
        embedScript: kPairAiEmbedScript,
        baseUrl: 'https://widgets-test.trypair.ai',
        enableDebugBridge: false,
      ),
      appBar: AppBar(title: const Text('Support')),
    );
  }
}
```

## Passing the embed script

1. Copy the full `<script>...</script>` block from the Pair dashboard.
2. Paste it into a `const String` in Dart (use a raw string `r'''...'''`).
3. Pass it to `PairAiEmbedConfig(embedScript: ...)`.
4. Set `baseUrl` to the same `BASE_URL` used inside the script.

**Do not modify the script.** If logs show `userId: null` while your script uses `user_Id`, contact the Pair team to confirm the correct field name.

## API reference — `PairAiEmbedConfig`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `embedScript` | `String` | required | Verbatim Pair `<script>` block |
| `baseUrl` | `String` | required | Secure context origin; must match script `BASE_URL` |
| `userAgent` | `String?` | `null` | Optional WebView user agent |
| `backgroundColor` | `Color` | white | WebView background |
| `enableArabicFontFix` | `bool` | `true` | Load Noto Sans Arabic |
| `enableIframeMediaPermissions` | `bool` | `true` | Inject iframe `allow` attributes |
| `enableDebugBridge` | `bool` | `false` | Bridge logs to Dart |
| `debugLogTag` | `String` | `PairAiAssistant` | Log prefix |
| `resizeToAvoidBottomInset` | `bool` | `true` | Scaffold keyboard resize |
| `htmlLang` | `String` | `ar` | HTML `lang` attribute |
| `extraHeadHtml` | `String?` | `null` | Extra `<head>` markup |

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| White screen on Android | Hybrid composition / GPU issue | Package uses Texture Layer mode by design |
| Mic fails / silent audio | Missing `MODIFY_AUDIO_SETTINGS` | Add permission + reinstall app |
| `Requires MODIFY_AUDIO_SETTINGS` in log | Same as above | Reinstall after manifest change |
| File picker does nothing (Android) | `setOnShowFileSelector` not wired | Use this package; check `android:file-selector:configured` log |
| Arabic shows tofu boxes | Missing font | Keep `enableArabicFontFix: true` |
| Keyboard hidden behind input | WebView keyboard quirk | `resizeToAvoidBottomInset: true` on screen |

## Logs reference

| Log line | Meaning |
|----------|---------|
| `app:microphone-permission: granted` | Native mic permission OK |
| `webview:permission-granted: microphone` | WebView mic grant OK |
| `android:file-selector:configured` | Android file bridge ready |
| `android:file-selector:open` | User tapped attach (+) |
| `page:finished: https://...` | HTML shell loaded |
| `debug:installed` | Debug bridge active (if enabled) |

## Limitations

- Android Hybrid Composition is **disabled** — enabling it causes blank screens on some Adreno GPUs (Oppo/Realme).
- iOS Simulator microphone may record silence; test on a real device.
- The package does not parse or validate script contents.

## Roadmap (v0.2)

- Delegate-based file picker override
- `PairAiEmbedConfig.fromAsset()` for script files
- CI + device integration tests

## Example app

```bash
cd example
flutter run
```

## Contributing / License

See [INTEGRATION.md](INTEGRATION.md) for the full integration guide.

MIT — see [LICENSE](LICENSE).
