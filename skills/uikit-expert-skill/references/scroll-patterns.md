# UIKit Scroll Patterns

## Overview
Keep scroll behavior deterministic and lightweight.

## Programmatic scroll rules
- Confirm target exists before scrolling.
- Ensure layout is current if index just changed.
- Avoid doing structural reload right before animated scroll unless required.

## Safe sequence
1. Update model
2. Apply targeted updates
3. `layoutIfNeeded()` if needed
4. Scroll to target row/item

## Good pattern
```swift
func scrollToLastItem() {
  guard !items.isEmpty else { return }
  let target = IndexPath(item: items.count - 1, section: 0)
  collectionView.layoutIfNeeded()
  collectionView.scrollToItem(at: target, at: .bottom, animated: true)
}
```

## Bad pattern
- Heavy work in `scrollViewDidScroll` every tick.
- Triggering nested reload/invalidation while actively dragging.

## Checklist
- [ ] Scroll delegate methods are lightweight
- [ ] No jitter from repeated state flips
- [ ] Scroll-to-target success rate stable

## Advanced scenarios
- **Thresholded chrome updates:** only toggle nav/header states when threshold boundaries are crossed.
- **Jump-to-item reliability:** if target not yet materialized, perform update/layout pass then retry once.
- **Pagination safety:** gate repeated load-more triggers with in-flight token and bottom-distance threshold.

## Review rubric
- **Excellent:** deterministic state flow, targeted updates, clear ownership, and measurable performance safeguards.
- **Acceptable:** works correctly but has minor over-updates or weak fallback notes.
- **Needs work:** broad reload churn, unclear ownership, or fragile availability/fallback handling.

## See also
- `list-patterns.md`
- `performance-patterns.md`
- `animation-basics.md`
