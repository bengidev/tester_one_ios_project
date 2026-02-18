# Tester One (iOS)

A minimal UIKit-based iOS app project targeting **iOS 12.0**. This project uses storyboards and the classic `AppDelegate` lifecycle (no `SceneDelegate`).

## BetaTest Module at a Glance

This project includes a reusable UIKit module called **BetaTest**.

In simple terms, BetaTest:
- shows a list of test cards,
- runs checks in sequence,
- updates each card status (`initial`, `loading`, `failed`, `success`),
- supports retry for failed items,
- lets the host app control texts, callbacks, and images.

The module is designed for **iOS 12+**, uses **anchor-based Auto Layout**, and is structured so it can be transplanted into another app.

## Read the Docs

Start here if you want to understand how it works:

- Module overview and integration: `docs/BetaTestModule.md`
- Optimization and change history: `docs/BetaTestOptimizationRecord.md`
- Layout behavior details: `docs/BetaTestAdaptiveMosaicPlan.md`
- Execution/refactor plan archive: `.sisyphus/plans/betatest-module-refactor-ios12.md`

## How It Works (Non-Technical Flow)

1. The host app provides test items and what each item should do when executed.
2. BetaTest renders cards and starts processing one item at a time.
3. Each item reports a result (`failed` or `success`) through a completion callback.
4. Failed items can be retried, and the UI updates accordingly.
5. Host app receives optional callbacks for analytics or navigation.

## Requirements
- Xcode 15+ (tested with Xcode 26.2)
- iOS 12.0+ deployment target

## Build & Run
### Xcode
Open `Tester One.xcodeproj` and run on a simulator or device.

### CLI scripts (recommended)
```bash
./run.sh                 # auto: real device if connected, else simulator
./run-simulator.sh       # auto-picks an available simulator by UDID
./run-device.sh          # build + install on connected real device
```

### Manual CLI build
```bash
xcodebuild \
  -project "Tester One.xcodeproj" \
  -scheme "Tester One" \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  build
```

## Tests
Preferred (auto-picks an available simulator safely):
```bash
./run-tests.sh
```

Manual:
```bash
xcodebuild \
  -project "Tester One.xcodeproj" \
  -scheme "Tester One" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,id=<SIMULATOR_UDID>' \
  test
```

## Project Structure
```
Tester One/
  AppDelegate.swift
  ViewController.swift
  Info.plist
  Base.lproj/
    Main.storyboard
    LaunchScreen.storyboard
Tester OneTests/
Tester OneUITests/
```

## Notes
- `SceneDelegate` is intentionally removed to keep iOS 12 compatibility.
- The main window is created via `AppDelegate`, and the UI is loaded from `Main.storyboard`.
- Launch image: **"Tuscan Landscape 6"** by Martin Falbisoner (CC BY-SA 3.0).
  https://commons.wikimedia.org/wiki/File:Tuscan_Landscape_6.JPG

## License
MIT
