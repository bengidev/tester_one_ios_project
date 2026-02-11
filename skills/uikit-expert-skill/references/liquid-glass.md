# UIKit Material / Glass Patterns

## Overview
Translate modern glass aesthetics into performant UIKit material layers.

## Building blocks
- `UIVisualEffectView` + `UIBlurEffect`
- Optional vibrancy for emphasis
- Rounded masking + semantic foreground colors

## Good pattern
```swift
let blur = UIBlurEffect(style: .systemThinMaterial)
let glass = UIVisualEffectView(effect: blur)
glass.layer.cornerRadius = 16
glass.clipsToBounds = true
```

## Bad pattern
- Deep blur nesting in scrolling cells.
- Low-contrast text over blur with no contrast audit.

## Compatibility strategy
- iOS 12: use supported blur styles and static overlays.
- iOS 13+: dynamic colors/material refinements.

## UIKit ↔ SwiftUI parity
- Material stack here maps to SwiftUI `.background(.ultraThinMaterial)` style intent.

## Checklist
- [ ] Contrast passes accessibility expectations
- [ ] Blur count minimized in reusable content
- [ ] Performance checked in scrolling contexts

## Advanced scenarios
- **Hierarchy discipline:** use one material plane per semantic layer (background / card / controls), avoid stacking same-depth blurs.
- **Snapshot tests:** freeze representative light/dark screenshots to catch accidental contrast regressions.
- **Fallback parity:** ensure non-material iOS 12 path keeps similar affordance boundaries and button prominence.

## Review rubric
- **Excellent:** deterministic state flow, targeted updates, clear ownership, and measurable performance safeguards.
- **Acceptable:** works correctly but has minor over-updates or weak fallback notes.
- **Needs work:** broad reload churn, unclear ownership, or fragile availability/fallback handling.

## See also
- `layout-best-practices.md`
- `performance-patterns.md`
- `modern-apis.md`
