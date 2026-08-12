# Pair AI Assistant — Flutter Integration Guide

Full integration guide for `pair_ai_assistant`. See [README.md](README.md) for quick start.

## Overview

Paste the Pair embed `<script>` verbatim into `PairAiEmbedConfig.embedScript`. The package builds an HTML shell, loads it in a WebView with `baseUrl`, and handles native bridges for microphone, camera, and file uploads.

## Required host app dependencies

The package bundles its own dependencies. The host app only needs:

```yaml
dependencies:
  pair_ai_assistant:
    path: ../pair_ai_assistant   # or git:
```

## Android permissions

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
```

Reinstall the app after adding `MODIFY_AUDIO_SETTINGS`.

## iOS permissions

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Used to record voice messages in the AI assistant chat.</string>
<key>NSCameraUsageDescription</key>
<string>Used to capture photos and videos in the AI assistant chat.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Used to attach photos in the AI assistant chat.</string>
```

## Usage

```dart
PairAiWidgetScreen(
  config: PairAiEmbedConfig(
    embedScript: kPairAiEmbedScript,
    baseUrl: 'https://widgets-test.trypair.ai',
    enableDebugBridge: kDebugMode,
  ),
  appBar: AppBar(title: const Text('Support')),
  onDebugLog: debugPrint,
  onEvent: (PairAiWidgetEvent event) {
    debugPrint('[PairAiEvent] ${event.type} ${event.data}');
  },
)
```

## Widget events

`onEvent` receives `PairAiWidgetEvent` (`type`, `data`, `origin`, `timestamp`). Passing `onEvent` turns the forwarder on automatically.

Typical types: `widget:ready`, `widget:close`, `widget:unreadCount`, `widget:previewMessage`, `widget:requestTokenRefresh`. See [README.md](README.md#widget-events) for the full list.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| White screen (Android) | Do not enable Hybrid Composition |
| Mic silent / `MODIFY_AUDIO_SETTINGS` | Add manifest permission + reinstall |
| File picker no-op (Android) | Use this package; check logs for `android:file-selector:configured` |
| `userId: null` in SDK logs | Script uses `user_Id` — confirm field name with Pair team |
| Arabic tofu | Keep `enableArabicFontFix: true` |

## Checklist

- [ ] Add `pair_ai_assistant` to `pubspec.yaml`
- [ ] Android manifest permissions
- [ ] iOS Info.plist descriptions
- [ ] Paste verbatim script into `kPairAiEmbedScript`
- [ ] `baseUrl` matches script `BASE_URL`
- [ ] Reinstall on Android after permission changes
- [ ] Test mic, attach (+), and text input on real devices
- [ ] Optional: handle `onEvent` (`widget:ready`, `widget:close`, …)

See `example/` for a working demo.
