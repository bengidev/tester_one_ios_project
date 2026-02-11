# UIKit View Structure

## Overview
Keep controllers orchestration-focused; push rendering and styling into reusable units.

## Structural boundaries
- ViewController: lifecycle + navigation + state transitions
- Reusable view/cell: UI composition + configure API
- ViewModel/service: domain logic and side effects

## Extraction heuristics
Extract when:
- setup method is too long/multi-concern
- same UI pattern appears in multiple screens
- cell configuration includes business branching

## Good pattern
```swift
struct HeaderModel {
  let title: String
  let subtitle: String
}

final class HeaderView: UIView {
  func configure(with model: HeaderModel) {
    titleLabel.text = model.title
    subtitleLabel.text = model.subtitle
  }
}
```

## Bad pattern
- 300-line `viewDidLoad` with layout + business + networking
- Controller mutating deep subview internals everywhere

## UIKit ↔ SwiftUI parity
- Extracted reusable views/cells mirror SwiftUI subview extraction for clarity/perf.

## Checklist
- [ ] Controllers remain readable and testable
- [ ] Reusable components have clear configure contracts
- [ ] Business rules not embedded in view classes

## Advanced scenarios
- **Feature decomposition:** break giant VC into section controllers/composite views when screen exceeds clear cognitive boundary.
- **Configuration objects:** use immutable view models for cells/subviews to improve testability and diffability.
- **Action routing:** centralize intent routing in VC/coordinator instead of deep nested closure chains.

## Review rubric
- **Excellent:** deterministic state flow, targeted updates, clear ownership, and measurable performance safeguards.
- **Acceptable:** works correctly but has minor over-updates or weak fallback notes.
- **Needs work:** broad reload churn, unclear ownership, or fragile availability/fallback handling.

## See also
- `state-management.md`
- `layout-best-practices.md`
- `list-patterns.md`
