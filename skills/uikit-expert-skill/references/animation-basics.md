# UIKit Animation Basics

## Overview
Build animations that communicate state change, not decoration noise.

## API selection guide
| Need | API |
|---|---|
| Simple one-shot animation | `UIView.animate` |
| Interruptible/interactive | `UIViewPropertyAnimator` |
| Layer-specific visual effect | Core Animation (`CABasicAnimation`) |

## Core rules
1. Keep UI updates on main thread.
2. Prefer transform/alpha animation over constraint churn.
3. If constraints change, animate `layoutIfNeeded()`.
4. Keep durations short unless storytelling UX explicitly needs longer.

## Good patterns
```swift
UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseOut]) {
  self.ctaButton.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
}
```

```swift
self.topConstraint.constant = 20
UIView.animate(withDuration: 0.3) {
  self.view.layoutIfNeeded()
}
```

## Bad patterns
```swift
// Too slow and visually noisy for routine interaction
UIView.animate(withDuration: 1.5, delay: 0.7, options: [.repeat, .autoreverse]) { ... }
```

## Common pitfalls
- Starting multiple overlapping animations on reused views.
- Mutating data source state only in completion block.
- Animating hidden/removed views without verifying hierarchy state.

## UIKit ↔ SwiftUI parity
- `UIView.animate` ↔ `withAnimation` / `.animation(value:)`
- Constraint animation + `layoutIfNeeded()` ↔ layout-driven animation in view tree

## Checklist
- [ ] Duration/easing matches interaction purpose
- [ ] Completion path deterministic under interruption
- [ ] Reduced Motion considered for decorative motion

## Advanced scenarios
- **Interactive cancellation:** if users can tap repeatedly, stop/reverse existing animation before starting a new one.
- **Constraint + transform mix:** prefer one primary system; if mixed, apply transform on leaf nodes and constraints on containers.
- **Accessibility:** if `UIAccessibility.isReduceMotionEnabled`, shorten or remove non-essential movement and keep alpha-only transitions.

## Review rubric
- **Excellent:** deterministic state flow, targeted updates, clear ownership, and measurable performance safeguards.
- **Acceptable:** works correctly but has minor over-updates or weak fallback notes.
- **Needs work:** broad reload churn, unclear ownership, or fragile availability/fallback handling.

## See also
- `animation-transitions.md`
- `animation-advanced.md`
- `performance-patterns.md`
