# Pair AI Assistant — iOS SDK

Native Swift SDK for embedding Pair AI assistant widgets in iOS apps using `WKWebView`. Mirrors the behavior of the [`pair_ai_assistant`](../../) Flutter package.

**Requirements:** iOS 15.0+, Swift 5.9+

A runnable sample app is in [`Example/`](Example/README.md). It links this package as a local Swift package and logs `onEvent` to the Xcode console.

## Installation

### Swift Package Manager

Add the package from this repository:

```swift
dependencies: [
    .package(path: "../pair_ai_assistant/sdks/ios"),
]
```

Or via Git URL once published:

```swift
.package(url: "https://github.com/trypair/pair_ai_assistant.git", from: "0.2.0")
```

Then add `PairAiAssistant` to your app target.

### CocoaPods

```ruby
pod 'PairAiAssistant', :path => '../pair_ai_assistant/sdks/ios'
```

## Info.plist

Add usage descriptions for microphone, camera, and photo library access:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Used to record voice messages in the AI assistant chat.</string>
<key>NSCameraUsageDescription</key>
<string>Used to capture photos and videos in the AI assistant chat.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Used to attach photos in the AI assistant chat.</string>
```

## Quick start

### Embed in an existing view controller

```swift
import PairAiAssistant

let config = try PairAiEmbedConfig(
    embedScript: kPairAiEmbedScript,  // verbatim <script> from Pair
    baseUrl: "https://widgets.trypair.ai",
    enableDebugBridge: true
)

let pairView = PairAiWebView(
    config: config,
    onDebugLog: { log in
        print(log)
    },
    onEvent: { event in
        print("[PairAiEvent] \(event.type) \(event.data)")
    }
)
pairView.translatesAutoresizingMaskIntoConstraints = false
view.addSubview(pairView)
// … Auto Layout to fill desired area
```

### Full-screen host

```swift
let viewController = PairAiViewController(
    config: config,
    onDebugLog: { log in
        print(log)
    },
    onEvent: { event in
        print("[PairAiEvent] \(event.type) \(event.data)")
    }
)
navigationController?.pushViewController(viewController, animated: true)
```

## Configuration

| Field | Default | Description |
|-------|---------|-------------|
| `embedScript` | — | Complete Pair embed `<script>` block (required) |
| `baseUrl` | — | HTTP(S) base URL matching `BASE_URL` in the script (required) |
| `userAgent` | `nil` | Optional custom WebView user agent |
| `backgroundColor` | `.white` | Background behind the WebView |
| `enableArabicFontFix` | `true` | Load Noto Sans Arabic and apply bilingual font stack |
| `enableIframeMediaPermissions` | `true` | Inject JS adding `allow="microphone; camera"` on iframes |
| `enableDebugBridge` | `false` | Forward JS debug events via `PairAssistantDebug` channel |
| `enableEventBridge` | `false` | Inject the internal event forwarder (also on when `onEvent` is set) |
| `debugLogTag` | `"PairAiAssistant"` | Log line prefix |
| `resizeToAvoidBottomInset` | `true` | No-op on iOS (Flutter scaffold only) |
| `htmlLang` | `"ar"` | `lang` attribute on generated HTML |
| `extraHeadHtml` | `nil` | Trusted extra markup inside `<head>` |
| `restrictNavigation` | `true` | Limit navigation to allowed origins |
| `allowedNavigationOrigins` | `[baseUrl origin]` | Additional allowed origins |

## Widget events

Pass `onEvent` to `PairAiWebView` or `PairAiViewController`. Setting `onEvent` turns the internal forwarder on automatically — you do not need `enableEventBridge: true` unless you want the bridge without a callback.

```swift
let pairView = PairAiWebView(
    config: config,
    onEvent: { event in
        switch event.type {
        case "widget:ready":
            break
        case "widget:close":
            break
        case "widget:unreadCount":
            let count = event.data["count"]
            print(count ?? "")
        default:
            print("[PairAiEvent] \(event.type) \(event.data)")
        }
    }
)
```

`PairAiWidgetEvent` fields: `type`, `data`, `origin`, `timestamp`.

Known `type` values (not a closed list — unknown `widget:` / `form:` types are still forwarded):

| `type` | When it fires |
|--------|----------------|
| `widget:ready` | Widget iframe finished initializing |
| `widget:close` | Widget requested to close |
| `widget:configUpdated` | Widget pushed a config update |
| `widget:setColor` | Bubble color update |
| `widget:unreadCount` | Unread badge (`data["count"]`) |
| `widget:previewMessage` | Preview card while the chat is closed |
| `widget:dismissPreview` | Preview card dismissed |
| `widget:requestTokenRefresh` | Widget asked the host to refresh the access token |
| `form:resize` / `form:submitted` | Form embed resize / submit |

Host-to-widget calls such as `PairAiWidgetSDK.updateMetadata(...)` are not `onEvent` callbacks.

## Logs reference

| Log prefix | Meaning |
|------------|---------|
| `page:start:` | Navigation started |
| `page:finished:` | Page load completed |
| `navigation:blocked:` | URL blocked by navigation guard |
| `webview:permission-request:` | Media capture permission requested |
| `webview:permission-granted:` | Media capture permission granted |
| `webview:permission-denied:` | Media capture permission denied |
| `ios:file-selector:native-wkwebview` | Using WKWebView native file picker |
| `resource:error:` | Web resource load error |

## Troubleshooting

**Microphone/camera not working** — Ensure `NSMicrophoneUsageDescription` and `NSCameraUsageDescription` are set in your app's `Info.plist`. The SDK grants WKWebView media capture requests automatically; iOS shows the system permission dialog when needed.

**Navigation blocked** — Set `restrictNavigation: false` or add origins to `allowedNavigationOrigins`.

**Arabic text rendering** — Keep `enableArabicFontFix: true` (default). The SDK re-injects font CSS at 0 ms, 300 ms, 1.5 s, and 4 s after each page load.

**Debug logging** — Set `enableDebugBridge: true` and pass an `onDebugLog` closure. On iOS 16.4+, the WebView is inspectable in Safari Web Inspector.

## Development

```bash
cd sdks/ios
swift build
swift test
```

## License

Same as the parent `pair_ai_assistant` repository.
