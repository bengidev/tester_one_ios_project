# Data Source Strategy by iOS Version

## Goal
Choose list data-source architecture based on deployment target and complexity.

## Decision matrix
| Context | Recommended approach |
|---|---|
| iOS 13+ only, complex insert/delete/reorder | Diffable data source |
| iOS 12+ support required | Classic data source with stable IDs |
| Hybrid rollout | Adapter layer wrapping classic + diffable implementations |

## iOS 13+ path: Diffable
- Use snapshots for state transitions.
- Keep item identifiers stable and hashable.
- Apply snapshots incrementally for smooth transitions.

## iOS 12+ path: Classic
- Keep source-of-truth arrays/maps in controller/view-model.
- Use targeted row/item updates over broad reloads.
- Maintain ID→indexPath mapping for reliable updates.

## Good vs bad
- Good: strategy chosen explicitly per deployment constraints.
- Bad: forcing diffable-only design when iOS 12 compatibility is required.

## Checklist
- [ ] IDs are stable and deterministic
- [ ] Local updates avoid full reloads
- [ ] Data source strategy documented in feature PR
