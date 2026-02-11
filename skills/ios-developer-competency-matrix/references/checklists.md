# iOS Developer Competency Matrix — Checklists

## Concurrency & threading
- Prefer `async throws` functions over callbacks.
- Ensure UI work runs on main actor:
  - `@MainActor` on view models that publish UI state
  - `await MainActor.run { ... }` for isolated updates
- Avoid shared mutable state; consider `actor`.
- Cancellation: store `Task` handles when you need to cancel on disappear.

## ARC / memory
- Any escaping closure capturing self? Consider `[weak self]`.
- Delegates should be `weak`.
- Watch for retain cycles with:
  - `Combine` sinks storing cancellables
  - `Timer` / `CADisplayLink`
  - async tasks capturing `self`

## SwiftUI state choices
- `@State`: local view-owned value
- `@Binding`: value owned by parent
- `@StateObject`: reference type owned by this view (created here)
- `@ObservedObject`: reference owned elsewhere (injected)
- `@Environment` / `@EnvironmentObject`: global-ish dependencies

## MVVM boundary reminders
- View:
  - renders state
  - forwards intents (button taps) to VM
- ViewModel:
  - owns state (loading/data/error)
  - calls services/repositories
  - maps domain errors → UI state
- Services/repositories:
  - do networking/persistence
  - return domain models or typed errors

## Networking layer sanity
- `URLRequest` construction centralized.
- Decode errors are distinguishable from transport errors.
- Use `Decodable` models close to API; map to domain models if needed.

## Persistence selection
- UserDefaults: user preferences only
- Keychain: tokens/passwords/secrets
- SwiftData/Core Data: relational data, offline-first caches

## Testing
- Unit tests:
  - pure functions, reducers, view model state transitions
- UI tests:
  - critical flows, login, purchase, onboarding (as applicable)
- Snapshot:
  - only if team commits to maintaining baselines

## CI/CD
- Prefer SPM.
- Ensure `xcodebuild test` works headless.
- Fastlane only when it reduces repetitive release pain.

## App Store readiness
- Permissions strings present and honest.
- Privacy disclosures match actual data usage.
- No dead ends / placeholder screens.
- Accessibility basics: labels, dynamic type, contrast.
