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
```bash
xcodebuild \
  -project "Tester One.xcodeproj" \
  -scheme "Tester One" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 14' \
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

## License
MIT
