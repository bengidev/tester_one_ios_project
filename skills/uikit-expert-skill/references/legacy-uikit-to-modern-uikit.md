# Legacy UIKit → Modern UIKit Playbook

## Goal
Modernize without regressions on iOS 12+ baseline.

## Sequence
1. **Stabilize state ownership** (single source of truth, render path).
2. **Replace reload churn** (`reloadData` -> targeted updates).
3. **Replace layout hacks** (spacers/frame fixes -> constraints/insets).
4. **Optimize rendering** (`shadowPath`, measurement cache, image pipeline).
5. **Adopt modern APIs with fallbacks** (`#available` + parity branch).

## Rollback points
- After each step, snapshot behavior and keep small commits.
- Revert step-local commit if visual parity breaks.

## PR checklist
- [ ] iOS 12 branch behavior preserved
- [ ] New API usage availability-gated
- [ ] Scroll/list performance improved or unchanged
- [ ] Accessibility not regressed
