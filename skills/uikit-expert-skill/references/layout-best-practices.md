# UIKit Layout Best Practices

## Overview
Use Auto Layout intent-first design. Avoid frame-repair loops.

## Principles
- Constraint ownership must be single-source.
- Safe area boundaries define screen edges.
- Insets represent spacing intent better than spacer placeholder views.

## Migration pattern (legacy cleanup)
- Replace spacer header/footer views with `contentInset`/`scrollIndicatorInsets`.
- Remove repeated width-fix frame mutation in `viewDidLayoutSubviews`.
- Invalidate layout only when geometry input changed.

## Good pattern
```swift
NSLayoutConstraint.activate([
  tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
  tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
  tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
  tableView.bottomAnchor.constraint(equalTo: footer.topAnchor)
])

tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
```

## Bad pattern
```swift
override func viewDidLayoutSubviews() {
  super.viewDidLayoutSubviews()
  tableHeader.frame.size.width = tableView.bounds.width // every pass
  tableView.tableHeaderView = tableHeader
}
```

## iOS 12+ note
All above patterns are compatible with iOS 12; modern APIs are optional enhancements.

## Checklist
- [ ] Ambiguous constraints eliminated
- [ ] Rotation/size-class changes stable
- [ ] No repeated frame-repair loops left

## Advanced scenarios
- **Dynamic Type stress:** validate AX categories where labels may require 3–5 lines and still keep tap targets >= 44pt.
- **Rotation races:** avoid layout-invalidating loops by diffing width before recompute.
- **Hybrid stacks:** combine `UIStackView` macro-layout with fine-grained constraints for priority conflicts.

## Review rubric
- **Excellent:** deterministic state flow, targeted updates, clear ownership, and measurable performance safeguards.
- **Acceptable:** works correctly but has minor over-updates or weak fallback notes.
- **Needs work:** broad reload churn, unclear ownership, or fragile availability/fallback handling.

## See also
- `performance-patterns.md`
- `list-patterns.md`
- `view-structure.md`
