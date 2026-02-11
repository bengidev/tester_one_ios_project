# UIKit Performance Patterns

## Overview
Optimize the biggest bottlenecks first: update fan-out, layout churn, rendering cost.

## High-value optimizations
1. Replace `reloadData()` with targeted reloads.
2. Invalidate layouts only on meaningful input change.
3. Set `shadowPath` for stable shadows.
4. Cache expensive text/height measurements.
5. Keep heavy work off hot callbacks.

## Threshold gating pattern
```swift
let shouldShowTitle = offsetY < -24
if shouldShowTitle != isTitleVisible {
  isTitleVisible = shouldShowTitle
  updateTitleUI()
}
```

## Shadow path pattern
```swift
if shadowContainer.bounds != lastShadowBounds {
  lastShadowBounds = shadowContainer.bounds
  shadowContainer.layer.shadowPath = UIBezierPath(
    roundedRect: shadowContainer.bounds,
    cornerRadius: 12
  ).cgPath
}
```

## Anti-patterns
- Broad relayout in every `viewDidLayoutSubviews` pass
- Recreating formatters/renderers in cells
- Heavy parsing/measurement inside scroll callbacks

## Checklist
- [ ] Hot path work measured and reduced
- [ ] Caches keyed by real invalidation inputs
- [ ] Smoothness acceptable on iOS 12 class devices

## Advanced scenarios
- **Main-thread budget:** keep per-frame UI work minimal; move parsing/formatting/image decode off hot path.
- **Measurement cache policy:** key by width + content size category + semantic style token, invalidate surgically.
- **Regression traps:** treat broad reload re-introductions as performance regressions during review.

## Review rubric
- **Excellent:** deterministic state flow, targeted updates, clear ownership, and measurable performance safeguards.
- **Acceptable:** works correctly but has minor over-updates or weak fallback notes.
- **Needs work:** broad reload churn, unclear ownership, or fragile availability/fallback handling.

## See also
- `layout-best-practices.md`
- `list-patterns.md`
- `image-optimization.md`
