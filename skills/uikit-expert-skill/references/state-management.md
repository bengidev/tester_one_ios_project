# UIKit State Management

## Overview
Model UI as explicit state transitions, not scattered callback mutations.

## Ownership model
- ViewController: state owner + render coordinator
- ViewModel/service: async/business logic
- Cells/views: pure rendering + user intent callbacks

## Screen state pattern
```swift
enum ScreenState {
  case idle
  case loading
  case loaded([Item])
  case failed(Error)
}

private var state: ScreenState = .idle {
  didSet { render(state) }
}
```

## Async safety
- Use operation token/UUID for in-flight tasks.
- Ignore stale completion if token no longer current.
- Cancel or invalidate outdated work when user restarts flow.

## Good vs bad
- Good: `render(state:)` updates only affected components.
- Bad: direct UI mutation from multiple independent async closures.

## UIKit ↔ SwiftUI parity
- State enum + render loop mirrors SwiftUI single source-of-truth rendering intent.

## Checklist
- [ ] One source of truth per concern
- [ ] Stale callbacks cannot overwrite fresh state
- [ ] State transitions are testable and logged when needed

## Advanced scenarios
- **Concurrent task arbitration:** latest-intent-wins tokening prevents older responses from overwriting newer state.
- **Partial render updates:** split render functions by section to reduce unnecessary work for local state changes.
- **Error recovery:** define retry strategy per state (`failed` -> `loading` -> `loaded/failed`) explicitly.

## Review rubric
- **Excellent:** deterministic state flow, targeted updates, clear ownership, and measurable performance safeguards.
- **Acceptable:** works correctly but has minor over-updates or weak fallback notes.
- **Needs work:** broad reload churn, unclear ownership, or fragile availability/fallback handling.

## See also
- `view-structure.md`
- `list-patterns.md`
- `sheet-navigation-patterns.md`
