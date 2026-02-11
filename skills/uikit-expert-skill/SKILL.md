---
name: uikit-expert-skill
description: Write, review, and modernize UIKit code for legacy-to-modern iOS apps (iOS 12+ through latest). Use when building UIKit screens, refactoring massive view controllers, optimizing table/collection rendering, improving animation/layout/state patterns, applying modern APIs with iOS 12-safe fallbacks, and planning incremental UIKit↔SwiftUI migration with measurable quality gates.
---

# UIKit Expert Skill

## Overview
Use this skill as the UIKit-specific counterpart to `swiftui-expert-skill`.

It is optimized for:
- legacy UIKit projects (including iOS 12 target support)
- mixed UIKit/SwiftUI migration contexts
- performance-sensitive list and card-heavy interfaces

## Workflow Decision Tree

### 1) Review existing UIKit screen
- Validate lifecycle usage and ownership boundaries.
- Check layout correctness (safe area, constraints, self-sizing).
- Check update strategy (`reloadData` overuse, invalidation churn).
- Check rendering hotspots (shadow, blur, repeated measurement, image decode).
- Check accessibility and Dynamic Type behavior.

### 2) Refactor existing UIKit implementation
- Replace fragile layout hacks with anchor/inset-driven layout.
- Move broad updates to targeted row/item updates.
- Extract reusable view/cell components.
- Add async/state guards to prevent stale completion writes.
- Add availability-gated modern APIs with equivalent iOS 12 fallbacks.

### 3) Build new UIKit feature
- Define explicit state model and ownership.
- Build with Auto Layout anchors and safe area.
- Choose table/collection patterns with stable identity.
- Implement loading/error/success state rendering.
- Add focused animation and performance constraints from day one.

## Quality bar
For recommendations and edits, always include:
- Good vs bad pattern comparison
- Why the change matters (correctness/perf/maintainability)
- iOS 12 compatibility note when using newer APIs
- Validation checklist

## Reference map
- `references/state-management.md`
- `references/view-structure.md`
- `references/modern-apis.md`
- `references/layout-best-practices.md`
- `references/list-patterns.md`
- `references/performance-patterns.md`
- `references/scroll-patterns.md`
- `references/animation-basics.md`
- `references/animation-transitions.md`
- `references/animation-advanced.md`
- `references/image-optimization.md`
- `references/sheet-navigation-patterns.md`
- `references/text-formatting.md`
- `references/liquid-glass.md`

- `references/uikit-antipatterns.md`
- `references/legacy-uikit-to-modern-uikit.md`
- `references/uikit-to-swiftui-incremental.md`
- `references/performance-benchmarks.md`
- `references/testing-guidance.md`

- `references/data-source-strategy-by-ios-version.md`
- `references/prefetching-and-cancellation.md`
- `references/responsiveness-budget.md`
- `references/api-availability-matrix.md`
- `references/legacy-vs-modern-list-migration.md`

- `references/accessibility-engineering.md`
- `references/instruments-playbook.md`
- `references/state-machine-templates.md`
- `references/case-studies.md`
## Scope boundary
- Use this skill for UIKit implementation details.
- Use `swiftui-expert-skill` for SwiftUI-first implementation details.
- In mixed code, map concepts between skills but keep final recommendations framework-specific.
