# Tester One (iOS)

A minimal UIKit-based iOS app project targeting **iOS 12.0**. This project uses storyboards and the classic `AppDelegate` lifecycle (no `SceneDelegate`).

## Requirements
- Xcode 15+ (tested with Xcode 26.2)
- iOS 12.0+ deployment target

## Build & Run
### Xcode
Open `Tester One.xcodeproj` and run on a simulator or device.

### CLI
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
