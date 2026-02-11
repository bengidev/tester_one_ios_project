# Accessibility Engineering (UIKit)

## Goal
Ship UIKit screens that remain usable with VoiceOver, Dynamic Type, and assistive interaction patterns.

## Core rules
- Every interactive control has meaningful `accessibilityLabel`.
- Add `accessibilityHint` only when action is not obvious.
- Set accurate `accessibilityTraits` (`.button`, `.selected`, `.header`, etc.).
- Keep tappable controls at least 44x44pt.

## Focus management
- After insert/delete/reload, restore focus to nearest logical element.
- Avoid reloading entire lists when local updates are sufficient (reduces focus loss).

## Dynamic Type checklist
- `adjustsFontForContentSizeCategory = true`
- Multi-line labels for variable-length content
- Verify largest accessibility content sizes

## Good vs bad
- Good: explicit labels/hints/traits + stable focus flow.
- Bad: icon-only actions without text/label and focus jumps after updates.

## Verification checklist
- [ ] VoiceOver can discover and activate all primary actions
- [ ] Focus order follows visual/semantic order
- [ ] Dynamic Type does not truncate critical content
- [ ] Touch targets remain >= 44pt
