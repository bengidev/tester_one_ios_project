# AGENTS.md - Tester One

> Comprehensive guide for AI agents working on the Tester One iOS project.

## Project Overview

**Tester One** is a minimal UIKit-based iOS application for device diagnostics and testing. The app features a MoneyMate-branded landing screen and a device diagnostic test list interface. It is designed to be a lightweight, iOS 12-compatible testing utility.

- **Project Type**: iOS Native App (UIKit)
- **Primary Purpose**: Device diagnostic testing utility
- **Branding**: MoneyMate financial/testing theme

---

## Technology Stack

| Component | Version/Details |
|-----------|-----------------|
| **Language** | Swift 5.0 |
| **iOS Target** | 12.0+ (iOS 26.1 for tests) |
| **Architecture** | Classic AppDelegate (No SceneDelegate) |
| **UI Framework** | UIKit (Programmatic - No Storyboards) |
| **Persistence** | Core Data (configured, minimal usage) |
| **Development** | Xcode 15+ (tested with Xcode 26.2) |

### Build Configuration

- **Bundle Identifier**: `co.id.LangitMerah.Tester-One`
- **Version**: 1.0
- **Build**: 1
- **Team ID**: 2N64875GLV
- **Orientation**: Portrait only
- **Devices**: iPhone, iPad (Universal)
- **Mac Catalyst**: Not supported

---

## Project Structure

```
Tester One/
├── AppDelegate.swift              # App lifecycle, window setup, Core Data stack
├── MainViewController.swift       # Landing screen with MoneyMate branding
├── DeviceTestViewController.swift # Device diagnostics list (UITableView)
├── AlphaTestTableViewCell.swift   # Custom table cell with status indicators
├── DeviceTestTableViewCell.swift  # Alternative cell implementation
├── UIViewController+Injection.swift # InjectionIII hot reload support (DEBUG)
├── Info.plist                   # Launch screen configuration
├── Assets.xcassets/             # App icons, images, colors
│   ├── AppIcon.appiconset
│   ├── LaunchImage.imageset
│   ├── MoneyMateHero.imageset   # Landing page hero image
│   ├── cpuImage.imageset        # Cell icon
│   ├── successImage.imageset    # Status: success (iOS 12 fallback)
│   └── failedImage.imageset     # Status: failure (iOS 12 fallback)
├── Base.lproj/                  # Empty (programmatic UI)
└── Tester_One.xcdatamodeld/     # Core Data model

Tester OneTests/                   # Unit tests
└── Tester_OneTests.swift

Tester OneUITests/                 # UI tests
├── Tester_OneUITests.swift
└── Tester_OneUITestsLaunchTests.swift
```

---

## Key Components

### 1. AppDelegate.swift
- **Purpose**: Classic AppDelegate pattern for iOS 12 compatibility
- **Key Features**:
  - Window-based app lifecycle (no SceneDelegate)
  - Core Data persistent container setup
  - Programmatic root view controller injection
  - Navigation controller as root

### 2. MainViewController.swift
- **Purpose**: Landing/welcome screen
- **Key Features**:
  - MoneyMate branding with hero image
  - Animated entrance transitions
  - Primary "Let's Start" button with press animations
  - Dark mode support (iOS 13+)
  - iOS 12 fallback for colors and images
- **Navigation**: Pushes to `DeviceTestViewController`

### 3. DeviceTestViewController.swift
- **Purpose**: Device diagnostic tests list
- **Key Features**:
  - UITableView with custom cells (`AlphaTestTableViewCell`)
  - Dynamic status indicators (success/failure/pending)
  - Action button with state toggle ("Mulai Tes" / "Dalam Pengecekan")
  - Custom navigation bar styling
  - Test items: Battery, Camera, Speaker, Microphone, Display, Touchscreen, Wi-Fi, Bluetooth, Charging, Vibration, Face ID/Touch ID, GPS, Proximity, Ambient Light sensors

### 4. AlphaTestTableViewCell.swift
- **Purpose**: Custom table view cell for test items
- **Key Features**:
  - Card-based design with shadows
  - Icon, title, action button, and status indicator
  - Dynamic type support (`preferredFont`)
  - Multi-line title support
  - Status states: `.success`, `.failure`, `.pending`
  - iOS 12 fallback images for status indicators

### 5. UIViewController+Injection.swift
- **Purpose**: InjectionIII hot reload support
- **Condition**: `DEBUG` builds only
- **Features**:
  - Automatic `viewDidLoad()` re-trigger on injection
  - View refresh handling
  - UITableView/UICollectionView data reload

---

## Build & Test Instructions

### Build from Command Line

```bash
# Debug build for simulator
xcodebuild \
  -project "Tester One.xcodeproj" \
  -scheme "Tester One" \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  build
```

### Run Tests

```bash
# Unit tests
xcodebuild \
  -project "Tester One.xcodeproj" \
  -scheme "Tester One" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 14' \
  test
```

### Format Code

The project uses SwiftFormat. Run before committing:

```bash
swiftformat .
```

Configuration: `.swiftformat` (151 lines of rules)

---

## Build Scripts

The project includes several convenience scripts for building, testing, and running the app:

| Script | Purpose | Usage |
|--------|---------|-------|
| `run.sh` | Universal run script (simulator or device) | `./run.sh [simulator\|device] [device-name]` |
| `run-simulator.sh` | Build and run on iOS Simulator | `./run-simulator.sh` |
| `run-device.sh` | Build and install on connected device | `./run-device.sh [device-name]` |
| `run-tests.sh` | Run unit tests | `./run-tests.sh` |
| `build-and-format.sh` | Format code and build | `./build-and-format.sh` |

### `run.sh` - Universal Run Script

Main entry point for running the app. Defaults to simulator mode.

```bash
# Run on simulator (default)
./run.sh
./run.sh simulator
./run.sh sim

# Run on connected device
./run.sh device
./run.sh device "iPhone Beng"
```

### `run-simulator.sh` - Simulator Build & Run

Builds the app for iOS Simulator and automatically launches it.
- Automatically detects available simulators (prefers iPhone 16 Pro → 15 Pro → 14 Pro)
- Boots simulator if not running
- Installs and launches the app

```bash
./run-simulator.sh
```

### `run-device.sh` - Real Device Build & Install

Builds and installs the app on a connected physical iPhone/iPad.
- Lists available devices
- Supports targeting specific device by name
- Handles code signing for development

```bash
# Use first available device
./run-device.sh

# Target specific device
./run-device.sh "iPhone Beng"
```

**Known Issue - Launch Command Failed:**
On iOS 17+, the automatic app launch may fail with "Launch command failed, please tap the app icon". This is due to Apple security restrictions on remote app launching. The app is installed successfully - just tap the icon to launch it manually.

**Workarounds:**
1. **Tap to launch** - The app is installed; just tap its icon on the home screen
2. **Keep device unlocked** during installation
3. **Trust the developer** - Go to Settings → VPN & Device Management → Trust
4. **Use ios-deploy** - Install with `brew install ios-deploy` for better launch support

---

## Auto Layout Constraint Debugging

The project has strict Auto Layout constraint checking enabled:

### Build Settings (Compile-time)

| Setting | Value | Purpose |
|---------|-------|---------|
| `SWIFT_TREAT_WARNINGS_AS_ERRORS` | `YES` | Swift warnings fail the build |
| `GCC_TREAT_WARNINGS_AS_ERRORS` | `YES` | Clang warnings fail the build |

### AutoLayoutDebugger (Runtime)

A runtime debugger is included that **crashes the app in DEBUG builds** when Auto Layout constraint violations occur.

**File:** `Tester One/AutoLayoutDebugger.swift`

**Behavior:**
- In DEBUG builds: Constraint conflicts trigger a `fatalError()` with detailed error message
- In RELEASE builds: Debugger is inactive (no performance impact)

**Example crash output:**
```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    AUTO LAYOUT CONSTRAINT VIOLATION                          ║
╠══════════════════════════════════════════════════════════════════════════════╣

❌ Build failed due to Auto Layout constraint conflict!

Constraint: <NSLayoutConstraint:0x... ...>
Conflicts with: <NSLayoutConstraint:0x... ...>
```

**To disable:** Remove `AutoLayoutDebugger.activate()` from `AppDelegate.swift`

### `run-tests.sh` - Run Unit Tests

Executes the unit test suite on iOS Simulator.

```bash
./run-tests.sh
```

### `build-and-format.sh` - Format & Build

Runs SwiftFormat and then builds the project. Useful for pre-commit validation.

```bash
./build-and-format.sh
```

---

## Coding Conventions

### Formatting (via SwiftFormat)

| Rule | Setting |
|------|---------|
| **Indentation** | 2 spaces |
| **Max Width** | 130 characters |
| **Line Ending** | Linebreak at end of file |
| **Trailing Commas** | Required for multi-element lists |
| **Import Grouping** | `testable-bottom` |
| **Self** | Remove redundant `self` |
| **Modifier Order** | Access control → `override` → others |

### Code Style Guidelines

1. **Class Structure** (via `organizeDeclarations`):
   ```swift
   // MARK: - ClassName
   
   final class ClassName: Parent {
     
     // MARK: Internal
     
     // MARK: Private
   }
   
   // MARK: Extensions
   ```

2. **Declaration Order**:
   - Nested types
   - Static properties
   - Instance properties
   - Instance lifecycle (`init`, `deinit`)
   - Static/class methods
   - Instance methods

3. **Access Control**: Explicit access modifiers on all declarations

4. **MARK Comments**: Use for organizing code sections

5. **Enums for Constants**:
   ```swift
   private enum Layout {
     static let padding: CGFloat = 16
   }
   
   private enum Colors {
     static let primary = UIColor(...)
   }
   ```

6. **iOS Version Handling**:
   ```swift
   if #available(iOS 13.0, *) {
     // Modern API
   } else {
     // iOS 12 fallback
   }
   ```

### Naming Conventions

- **Classes**: `PascalCase` (e.g., `DeviceTestViewController`)
- **Methods/Variables**: `camelCase` (e.g., `configureCell()`)
- **Constants**: `PascalCase` within enum (e.g., `Layout.padding`)
- **Files**: Match primary class name

---

## Development Notes

### iOS 12 Compatibility

- **No SceneDelegate**: App uses classic `AppDelegate` with `var window: UIWindow?`
- **SF Symbols Fallback**: Custom images provided for iOS 12 (successImage, failedImage)
- **Color APIs**: Check `traitCollection.userInterfaceStyle` availability
- **Safe Area**: Check `safeAreaLayoutGuide` availability (iOS 11+)

### UI Implementation

- **Programmatic Only**: All UI is code-based, no Interface Builder
- **Auto Layout**: Pure NSLayoutConstraint with anchors
- **No Storyboards**: `Base.lproj` exists but is empty
- **Dynamic Type**: Support for accessibility text sizes

### Hot Reload

InjectionIII support is built-in for DEBUG builds:
1. Install InjectionIII app
2. Run app in simulator
3. Save file → automatic injection and refresh

### Assets

| Asset | Usage |
|-------|-------|
| `MoneyMateHero` | Landing screen hero image |
| `cpuImage` | Test cell icon |
| `successImage` | Status indicator (iOS 12) |
| `failedImage` | Status indicator (iOS 12) |
| `LaunchImage` | Launch screen |

---

## Important Notes for AI Agents

1. **Preserve iOS 12 Compatibility**: Do NOT add SceneDelegate or use iOS 13+ only APIs without fallbacks

2. **SwiftFormat Compliance**: Run `swiftformat .` before committing changes

3. **Test Targets**: Unit tests target iOS 26.1, main app targets iOS 12.0

4. **Core Data**: Model exists but is minimally used; persistent container is configured

5. **Language**: Some UI text is in Indonesian ("Mulai Tes", "Dalam Pengecekan", "ULANGI")

6. **Navigation**: Uses `UINavigationController` with programmatic push/pop

7. **Cell Registration**: Table cells use programmatic registration, not storyboard prototypes

8. **Image Fallbacks**: When using SF Symbols, always provide iOS 12 fallback images

9. **Status Indicators**: Cell status is calculated via `indexPath.row % 3` (demo logic)

10. **Bundle ID**: Use `co.id.LangitMerah.Tester-One` for any new targets

---

## File Checklist for Modifications

When adding new features, ensure:
- [ ] SwiftFormat passes (`swiftformat --lint .`)
- [ ] iOS 12 compatibility maintained
- [ ] Dark mode support added (iOS 13+)
- [ ] Unit tests updated (if applicable)
- [ ] MARK comments for organization
- [ ] Access control modifiers explicit
- [ ] Assets added to `Assets.xcassets`

---

## License

MIT License (see `LICENSE` file)
