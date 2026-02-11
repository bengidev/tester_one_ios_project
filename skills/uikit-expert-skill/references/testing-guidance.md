# UIKit Testing Guidance by Topic

## State management
- Unit-test state transition functions (`idle/loading/success/failed`).
- Test stale token completion ignored.

## List updates
- UI test retry/update path uses correct row/item after reorder.
- Validate no scroll jump on local state update.

## Layout
- Snapshot or UI tests for small/large devices + Dynamic Type.
- Rotation tests for width-change stability.

## Accessibility
- Verify labels/traits on interactive controls.
- Validate focus order after insert/delete transitions.

## Performance smoke tests
- Rapid scrolling in list-heavy screen.
- Repeated retry/actions do not cause duplicated animations or stale states.
