# UIKit Anti-Patterns Catalog

## 1) Massive View Controller
### Smell
- Hundreds of lines in `viewDidLoad`.
- Business logic mixed with layout and navigation.

### Risk
- Hard to test, fragile changes, regressions.

### Fix recipe
1. Extract reusable views/cells.
2. Move business logic to view model/service.
3. Keep VC as orchestration + render dispatcher.

---

## 2) Index-Based Identity
### Smell
- Cell actions rely on stored index values.

### Risk
- Wrong item updates after insert/delete/reorder.

### Fix recipe
1. Use stable model IDs.
2. Resolve indexPath at tap time from current cell.
3. Guard async completion by represented model ID.

---

## 3) Reload-Data Everywhere
### Smell
- `reloadData()` for local state changes.

### Risk
- Jank, scroll jumps, unnecessary CPU/layout churn.

### Fix recipe
1. Replace with `reloadRows` / `reloadItems`.
2. Use batch updates for structural mutations.
3. Reserve `reloadData()` for full dataset replacement.

---

## 4) Layout Repair Loop
### Smell
- Repeated frame fixes in `viewDidLayoutSubviews`.

### Risk
- Layout thrash and unstable UI.

### Fix recipe
1. Express intent in constraints/insets.
2. Invalidate only when width/trait input changed.
3. Remove header/footer spacer hacks when insets suffice.

---

## 5) Stale Async UI Writes
### Smell
- Async completion always updates UI regardless of current operation.

### Risk
- Old responses overwrite new state.

### Fix recipe
1. Track operation token/UUID.
2. Ignore completion when token is stale.
3. Cancel in-flight work on restart/navigation if needed.
