# UIKit Performance Targets & Verification

## Suggested targets
- Single-item state change: no full `reloadData()`.
- Scroll callback work: O(1), no heavy parsing/layout.
- Thresholded UI toggles: update only on boundary crossing.
- Stable shadowed view: `shadowPath` set and updated only on bounds change.

## Verification steps
1. Inspect changed code paths for global reloads/invalidation.
2. Profile scrolling with Instruments (Time Profiler + Core Animation).
3. Validate no repeated expensive allocations in cell config.
4. Test dynamic type and rotation for layout churn.

## Regression guard list
- [ ] No new broad reload calls in hot interactions
- [ ] No frame-repair loops added in layout lifecycle
- [ ] No stale async completion writes to visible UI
