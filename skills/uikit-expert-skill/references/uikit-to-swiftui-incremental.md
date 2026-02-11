# UIKit → SwiftUI Incremental Migration

## Goal
Introduce SwiftUI without destabilizing legacy flows.

## Strategy
1. Keep navigation ownership in UIKit first.
2. Embed isolated SwiftUI surfaces via `UIHostingController`.
3. Share domain/state layer; avoid duplicate business logic.
4. Migrate leaf screens before core routing screens.

## Pattern
- UIKit VC presents/pushes hosting controller.
- SwiftUI view receives explicit input and emits typed callbacks.
- UIKit handles side effects and navigation until migration is complete.

## Compatibility note
- SwiftUI requires iOS 13+, keep UIKit path for iOS 12 devices.

## Checklist
- [ ] Fallback UIKit screen exists for iOS 12
- [ ] Feature parity between SwiftUI and UIKit paths
- [ ] Analytics/events consistent across both paths
