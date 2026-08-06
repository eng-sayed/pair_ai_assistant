# Pair AI Assistant — Android SDK

**v0.1.0** | `minSdk 24` | Kotlin | AAR / Maven

Standalone Android library that embeds the Pair AI assistant widget in a native `WebView`, with feature parity to the [Flutter package](../../README.md).

## Installation

### Maven Local

```bash
cd sdks/android
./gradlew :pairai:publishToMavenLocal
```

```kotlin
repositories {
    mavenLocal()
    google()
    mavenCentral()
}

dependencies {
    implementation("ai.trypair:pair-ai-assistant:0.1.0")
}
```

### JitPack

```kotlin
repositories {
    maven { url = uri("https://jitpack.io") }
}

dependencies {
    implementation("com.github.eng-sayed.pair_ai_assistant:pairai:0.1.0")
}
```

Adjust the JitPack coordinates to match your published artifact.

## Permissions

The library manifest merges these permissions automatically:

- `INTERNET`
- `CAMERA`
- `RECORD_AUDIO`
- `MODIFY_AUDIO_SETTINGS`

Ensure your host activity uses:

```xml
android:hardwareAccelerated="true"
android:windowSoftInputMode="adjustResize"
```

After adding `MODIFY_AUDIO_SETTINGS`, **reinstall** the app (not hot reload).

## Quick start

### Kotlin — bare WebView

```kotlin
val config = PairAiEmbedConfig.create(
    embedScript = pairScript, // verbatim <script> from Pair
    baseUrl = "https://widgets.trypair.ai",
)

val webView = PairAiWebView(
    context = this,
    config = config,
    host = this, // Activity or Fragment implementing ActivityResultCaller
)
setContentView(webView)
```

### Kotlin — full-screen Activity

```kotlin
startActivity(PairAiActivity.newIntent(this, config))
```

### Kotlin — Fragment

```kotlin
supportFragmentManager.beginTransaction()
    .replace(R.id.container, PairAiFragment.newInstance(config))
    .commit()
```

### Java

```java
PairAiEmbedConfig config = new PairAiEmbedConfig.Builder()
    .embedScript(pairScript)
    .baseUrl("https://widgets.trypair.ai")
    .build();

PairAiWebView webView = new PairAiWebView(this, config, this, null, null, null);
setContentView(webView);
```

## Configuration

| Field | Default | Description |
|-------|---------|-------------|
| `embedScript` | — | Verbatim Pair `<script>` block (required) |
| `baseUrl` | — | Must match `BASE_URL` in script; `http://` or `https://` |
| `userAgent` | `null` | Optional custom WebView user agent |
| `backgroundColor` | `Color.WHITE` | Background behind WebView |
| `enableArabicFontFix` | `true` | Noto Sans Arabic + bilingual font stack |
| `enableIframeMediaPermissions` | `true` | Injects iframe `allow="microphone; camera"` |
| `enableDebugBridge` | `false` | `PairAssistantDebug` JS → logcat / callback |
| `debugLogTag` | `"PairAiAssistant"` | Log prefix |
| `resizeToAvoidBottomInset` | `true` | Sets `SOFT_INPUT_ADJUST_RESIZE` on `PairAiActivity` |
| `htmlLang` | `"ar"` | BCP-47 `lang` on generated HTML |
| `extraHeadHtml` | `null` | Trusted extra `<head>` markup |
| `restrictNavigation` | `true` | Limit WebView navigation to allowed origins |
| `allowedNavigationOrigins` | `[baseUrl origin]` | Additional allowed origins |

Pass `host = null` on `PairAiWebView` only if file picker and media permissions are not needed.

## Debug logs

When `enableDebugBridge = true`, look for `[PairAiAssistant]` in logcat:

| Log prefix | Meaning |
|------------|---------|
| `page:start:` / `page:finished:` | Navigation lifecycle |
| `webview:permission-granted:` | Mic/camera granted to WebView |
| `android:file-selector:open` | Native file picker opened |
| `navigation:blocked:` | URL blocked by origin guard |
| `console:` | WebView console output |

## Troubleshooting

**Blank WebView** — Confirm `baseUrl` matches the script's `BASE_URL` and uses `https://`.

**Microphone denied** — Reinstall after adding `RECORD_AUDIO` and `MODIFY_AUDIO_SETTINGS`. Check system app permissions.

**File upload fails** — Ensure `PairAiWebView` receives a non-null `host` (`Activity` or `Fragment`).

**Camera capture fails** — FileProvider authority `ai.trypair.assistant.fileprovider` is declared in the library manifest; do not override unless you know what you're doing.

## Building

```bash
cd sdks/android
./gradlew :pairai:assembleRelease
./gradlew :pairai:test
```

## Out of scope

The structured JS → native event listener bridge (`PairAssistantEvents`) is not included in this release. Use `enableDebugBridge` for diagnostics.
