# Legacy vs Modern List Migration

## Goal
Migrate list architecture safely while preserving behavior and iOS 12 support.

## Legacy baseline
- Classic data source + delegate
- Manual insert/delete/reload operations
- Stable ID mapping for local updates

## Modern option (iOS 13+)
- Diffable data source snapshots
- Cleaner mutation semantics for complex changes

## Migration paths
### Path A: Keep iOS 12 support (recommended now)
- Maintain classic data source as primary.
- Introduce helper abstractions for update operations.
- Optionally add diffable-only path behind availability if payoff is clear.

### Path B: iOS 13+ only future
- Adopt diffable fully and simplify update logic.

## Good vs bad
- Good: migrate incrementally with measurable wins.
- Bad: rewrite list layer without clear performance/maintenance benefit.

## Checklist
- [ ] Stable ID behavior preserved
- [ ] Retry/selection/scroll position behavior preserved
- [ ] iOS 12 path remains first-class while target includes 12
