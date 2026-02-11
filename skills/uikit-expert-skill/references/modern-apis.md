# UIKit Modern APIs (Legacy-Compatible)

## Overview
Adopt modern UIKit APIs with explicit iOS 12 fallback parity.

## Availability contract
```swift
if #available(iOS 13.0, *) {
  // modern API path
} else {
  // equivalent fallback path
}
```

## Migration table
| Concern | Modern path | iOS 12 fallback |
|---|---|---|
| Nav bar styling | `UINavigationBarAppearance` | `barTintColor`, `titleTextAttributes`, shadow/background image |
| Colors | dynamic semantic colors | static palette mapped to light/dark assumptions |
| Activity indicator | `.medium` / `.large` | `.gray` / `.white` |

## Good vs bad
- Good: fallback has equivalent behavior and visual intent.
- Bad: fallback branch compiles but degrades UX drastically.

## Checklist
- [ ] No modern symbol leaked into old branch
- [ ] Fallback branch manually tested
- [ ] Behavior parity documented when differences are unavoidable

## Advanced scenarios
- **Feature flags + availability:** combine runtime feature toggles with `#available` so rollout can be controlled safely.
- **Parity notes in PRs:** document intentional behavior deltas where fallback cannot perfectly match modern path.
- **Compile guard hygiene:** keep modern symbols scoped inside availability blocks to avoid accidental linkage issues.

## Review rubric
- **Excellent:** deterministic state flow, targeted updates, clear ownership, and measurable performance safeguards.
- **Acceptable:** works correctly but has minor over-updates or weak fallback notes.
- **Needs work:** broad reload churn, unclear ownership, or fragile availability/fallback handling.

## See also
- `layout-best-practices.md`
- `liquid-glass.md`
- `state-management.md`
