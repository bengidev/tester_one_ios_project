# UIKit Animation Transitions

## Overview
Transition data and UI in lockstep to avoid glitches.

## Transition model
1. Update model
2. Apply batch UI ops
3. Reload only affected rows/items
4. Reconcile focus/accessibility

## Table/collection patterns
### UICollectionView
```swift
collectionView.performBatchUpdates {
  model.toggleExpanded(id: id)
  collectionView.reloadItems(at: [indexPath])
}
```

### UITableView
```swift
tableView.beginUpdates()
model.remove(id: id)
tableView.deleteRows(at: [indexPath], with: .automatic)
tableView.endUpdates()
```

## Good vs bad
- Good: targeted updates with stable IDs.
- Bad: `reloadData()` after local change (causes unnecessary churn/scroll jumps).

## Screen transitions
- Prefer native push/present unless custom transition is a real requirement.
- Keep one owner for presentation + dismissal + result callback.

## UIKit ↔ SwiftUI parity
- `performBatchUpdates` ↔ list diff + view identity updates
- push/present flows ↔ `NavigationStack` + `.sheet`

## Checklist
- [ ] Data mutation and UI mutation stay consistent
- [ ] No stale index assumptions after deletion/reorder
- [ ] Focus behavior validated after transition

## Advanced scenarios
- **Partial data refresh:** when backend returns only changed IDs, map IDs→indexPaths and reload only those items.
- **Concurrent edits:** guard against index invalidation by recomputing index paths after model mutation, not before.
- **Focus retention:** restore VoiceOver focus to semantically nearest item after insert/delete transitions.

## Review rubric
- **Excellent:** deterministic state flow, targeted updates, clear ownership, and measurable performance safeguards.
- **Acceptable:** works correctly but has minor over-updates or weak fallback notes.
- **Needs work:** broad reload churn, unclear ownership, or fragile availability/fallback handling.

## See also
- `list-patterns.md`
- `sheet-navigation-patterns.md`
- `animation-advanced.md`
