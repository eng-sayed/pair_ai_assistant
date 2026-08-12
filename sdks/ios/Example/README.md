# Pair AI Assistant — iOS Example

Native UIKit app that embeds [`PairAiAssistant`](../) as a **local Swift package** and logs widget events.

## How this project is linked

These are the steps that were used to wire the example to the SDK in this repo:

1. Created `sdks/ios/Example/PairAiAssistantExample.xcodeproj` (iOS App, UIKit, iOS 15+).
2. Added a **local Swift package** pointing at `sdks/ios` (the folder that contains `Package.swift`):
   - In `project.pbxproj`: `XCLocalSwiftPackageReference` with `relativePath = ..;`
3. Linked the `PairAiAssistant` product to the app target (`packageProductDependencies` + Frameworks build phase).
4. Set `Info.plist` usage strings for microphone, camera, and photo library.
5. `ViewController` builds `PairAiEmbedConfig` from [`PairAiEmbedScript.swift`](PairAiAssistantExample/PairAiEmbedScript.swift) (`https://widgets-test.trypair.ai`) and shows `PairAiWebView` with `onEvent` logging.

To recreate the same link in Xcode UI:

1. Open `PairAiAssistantExample.xcodeproj`.
2. File → Add Package Dependencies… → Add Local… → select `sdks/ios`.
3. Add the `PairAiAssistant` library to the `PairAiAssistantExample` target.

## Run

1. Open `sdks/ios/Example/PairAiAssistantExample.xcodeproj` in Xcode.
2. Run on an iOS Simulator.
3. Watch the Xcode console for lines like:

```
[PairAiEvent] widget:ready ...
[PairAiEvent] widget:close ...
```
