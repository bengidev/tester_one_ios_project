# BetaTest Module (UIKit, iOS 12+)

## Purpose
`BetaTest` is now structured as a standalone, host-injectable feature module that can be transplanted into a production app.

## Non-Technical Guide (PM/QA/Design)

### What this module does
- Shows a list of test cards (for example: CPU, camera, network checks).
- Runs those checks in sequence and updates each card status.
- Supports retry when an item fails.
- Lets product teams control texts, callbacks, and images from the host app.

### Why this is useful
- Reusable: can be moved into another app with minimal rework.
- Customizable: host app chooses labels, images, and run behavior.
- Predictable: item flow and retry behavior are consistent.
- Compatible: designed for iOS 12+ while still working on latest iOS.

### What teams can customize without touching internals
- Screen text (title/buttons).
- Per-item title and retry label.
- Per-state icons (`initial`, `failed`, `success`).
- Status badge image.
- What each test item actually does when executed.

### Typical rollout flow
1. Product/QA define item list and expected pass/fail behavior.
2. Design provides icon resources for `initial`, `failed`, and `success` states (assets or any other image source).
3. Engineering maps each item to a real execution handler.
4. QA validates first-run + retry path and confirms visual states.

### Ownership boundary (important)
- BetaTest module: UI flow, state transitions, and rendering rules.
- Host app: real test logic, environment-specific behavior, branding resources, and analytics wiring.

## Design constraints
- iOS 12.0+
- Programmatic UI inside the BetaTest module only (no Storyboard dependency in module internals)
- Auto Layout via anchor constraints
- Dynamic multiline card content
- Masonry-like feed behavior (Instagram Explore style)

## Public entrypoint
```swift
let vc = BetaTestModule.makeViewController(
  configuration: .init(
    items: [
      .init(
        title: "CPU",
        initialIconImage: UIImage(named: "fingerInitialImage"),
        failedIconImage: UIImage(named: "fingerFailedImage"),
        successIconImage: UIImage(named: "fingerSuccessImage"),
        statusImage: UIImage(named: "successImage"),
        executionHandler: { phase, complete in
          let result: BetaTestCardState
          switch phase {
          case .initial:
            result = .failed
          case .retry:
            result = .success
          }
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            complete(result)
          }
        }
      )
    ],
    layoutStrategy: .adaptiveMosaic,
    screen: .init(),
    onProcessingEvent: { event in
      // Optional host callback wiring at module initialization
    },
    onRetryCompleted: { result in
      // Optional host retry callback
    }
  )
)
```

## Module surface
- `BetaTestModule`
  - `makeViewController(configuration:)`
- `BetaTestModuleConfiguration`
  - `Module`
  - `Item`
  - `Screen`

## Internals
- `BetaTestViewController`: orchestration + state transitions
- `BetaTestCollectionViewCell`: dynamic self-sizing card
- `BetaTestAdaptiveMosaicLayout`: waterfall/masonry-like layout with overlap absorption
- No debug harness is exposed in the production contract.

## Item Configuration Contract
- `title` (required): card title text.
- `initialIconImage` (optional): icon shown in `.initial` and `.loading`.
- `failedIconImage` (optional): icon shown in `.failed`.
- `successIconImage` (optional): icon shown in `.success`.
- `statusImage` (optional): trailing status image used for success/failed status badge.
- `retryButtonTitle` (optional): retry badge title, defaults to `Ulangi`.
- `executionHandler` (required): async closure returning `BetaTestCardState` exactly once.

## Icon Rendering Rules
- Icon state precedence is explicit per card state:
  - `.initial`/`.loading`: `initialIconImage`, then `failedIconImage`, then `successIconImage`.
  - `.failed`: `failedIconImage`, then `initialIconImage`, then `successIconImage`.
  - `.success`: `successIconImage`, then `initialIconImage`, then `failedIconImage`.
- If configured images are missing or unusable, module fallback image is used.
- In failed state, retry badge and status badge do not overlap: when retry badge is visible, trailing status image is hidden.

## Host boundary
- Environment-driven automation (for screenshots/state capture) stays in host app code (`AppDelegate`), not inside BetaTest internals.
- Host apps override labels/titles through `BetaTestModuleConfiguration.Screen` and `BetaTestModuleConfiguration.Item`.
- Host apps provide per-item execution behavior with `BetaTestModuleConfiguration.Item.executionHandler`.
- Host apps can customize the status badge image per item through `statusImage`.
- Item cards always start in `.initial` UI state and transition based on execution results provided by host handlers.
- Host apps can provide different icon images for `initial`, `failed`, and `success` states per item (for example: `UIImage(named:)`, downloaded images, or generated images).

## Production implantation strategy
1. Keep `BetaTestModuleConfiguration.Item` as host-facing DTO.
2. Implement real checks directly per item via `executionHandler`:
   - hardware checks
   - network checks
   - async service calls
3. Wire host callbacks during module initialization (`onProcessingEvent`, `onRetryCompleted`, `onContinueButtonTapped`, `onRetryButtonTapped`).
4. Keep theming in `BetaTestTheme` and map colors from design tokens.

## Host implant readiness checklist (Stage 7)
- [x] End-to-end run path verified (`start -> processing -> finish`) through module tests.
- [x] Failure + retry path verified (`failed -> retry -> success`) through module tests.
- [x] Host event surface is available for orchestration/analytics (`onProcessingEvent`, `onRetryCompleted`).
- [x] Layout structure remains concept-safe (no structural redesign required for host implant).
- [x] Script-level simulator selection hardened for reliable CI/local execution (`run-tests.sh`, `run-simulator.sh`).

## Notes
- Card height is driven by multiline title content and measured via Auto Layout sizing cell.
- Layout is adaptive and remains anchor-constraint-driven across iPhone sizes.
