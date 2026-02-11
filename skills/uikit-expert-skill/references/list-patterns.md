# UIKit List Patterns

## Overview
Design list updates around stable identity and minimal churn.

## Identity rules
- Persist stable model ID.
- Never treat array index as long-term identity.
- Resolve current indexPath when user taps control in reused cell.

## Update strategy matrix
| Change type | Preferred update |
|---|---|
| One row/item state | `reloadRows` / `reloadItems` |
| Insert/delete/reorder | batch updates |
| Full dataset swap | `reloadData` |

## Good pattern
```swift
let changed = changedIDs.compactMap(indexPathForID)
collectionView.performBatchUpdates {
  collectionView.reloadItems(at: changed)
}
```

## Bad pattern
```swift
// Minor change, major cost
collectionView.reloadData()
```

## Reuse safety
- Reset transient UI in `prepareForReuse`
- Guard async callbacks by represented ID
- Keep `configure(with:)` idempotent

## Checklist
- [ ] Local updates avoid global reloads
- [ ] No wrong-row mutation from stale callback
- [ ] Batch updates keep model/UI synchronized

## Advanced scenarios
- **Retry-in-cell workflows:** route actions by resolved indexPath at tap time, then guard completion by stable item ID.
- **Bulk updates:** group related insert/delete/reload operations in one batch to avoid intermediate invalid states.
- **Selection persistence:** remap selected IDs after reorder or reload to preserve user context.

## Review rubric
- **Excellent:** deterministic state flow, targeted updates, clear ownership, and measurable performance safeguards.
- **Acceptable:** works correctly but has minor over-updates or weak fallback notes.
- **Needs work:** broad reload churn, unclear ownership, or fragile availability/fallback handling.

## See also
- `state-management.md`
- `performance-patterns.md`
- `scroll-patterns.md`
