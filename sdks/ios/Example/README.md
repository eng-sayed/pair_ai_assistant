# Pair AI Assistant — iOS Example

Native UIKit app that embeds [`PairAiAssistant`](../) as a **local Swift package** and logs widget events.

## How this project is linked

These are the steps that were used to wire the example to the SDK in this repo:

1. Created `sdks/ios/Example/PairAiAssistantExample.xcodeproj` (iOS App, UIKit, iOS 15+).
2. Added a **local Swift package** pointing at `sdks/ios` (the folder that contains `Package.swift`):
   - In `project.pbxproj`: `XCLocalSwiftPackageReference` with `relativePath = ..;`
3. Linked the `PairAiAssistant` product to the app target (`packageProductDependencies` + Frameworks build phase).
4. Set `Info.plist` usage strings for microphone, camera, and photo library.
5. `ViewController` builds `PairAiEmbedConfig` from [`PairAiEmbedScript.swift`](PairAiAssistantExample/PairAiEmbedScript.swift) (`https://widgets-test.trypair.ai`) and shows `PairAiWebView` with `onEvent` logging. A **Send window.postMessage** button injects `window.postMessage({ type: 'widget:demo', ... })` so you can see the event on screen.

To recreate the same link in Xcode UI:

1. Open `PairAiAssistantExample.xcodeproj`.
2. File → Add Package Dependencies… → Add Local… → select `sdks/ios`.
3. Add the `PairAiAssistant` library to the `PairAiAssistantExample` target.

## Run

1. Open `sdks/ios/Example/PairAiAssistantExample.xcodeproj` in Xcode.
2. Run on an iOS Simulator.
3. Tap **Send window.postMessage**. The label at the top should show `widget:demo` and the payload. Real widget events such as `widget:ready` also appear there and in the Xcode console:

```
[PairAiEvent] widget:ready ...
[PairAiEvent] widget:demo ...
```
