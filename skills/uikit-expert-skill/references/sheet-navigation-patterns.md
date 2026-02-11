# UIKit Sheet and Navigation Patterns

## Overview
Define ownership clearly: presentation, dismissal, and result propagation.

## Ownership model
- Presenter decides push vs modal.
- Presented controller emits result via callback/delegate.
- Single dismissal owner prevents duplicate completion behavior.

## Good pattern
```swift
let vc = EditDeviceViewController()
vc.onSave = { [weak self] device in
  self?.apply(device)
  self?.dismiss(animated: true)
}
present(vc, animated: true)
```

## Bad pattern
- Global notification for local flow completion.
- Multiple layers independently calling dismiss.

## iOS 12 compatibility notes
- Make modal presentation style explicit where behavior differences matter.
- Avoid assuming newer sheet detent APIs exist.

## Checklist
- [ ] One canonical completion path
- [ ] Cancel path and save path both deterministic
- [ ] Navigation stack remains consistent after flow ends

## Advanced scenarios
- **Nested modals:** avoid when possible; if required, define explicit unwind order and ownership.
- **Result propagation:** prefer typed callback payloads over loosely-typed notifications for local flows.
- **Cancellation semantics:** define whether cancel is silent discard or emits explicit cancellation result.

## Review rubric
- **Excellent:** deterministic state flow, targeted updates, clear ownership, and measurable performance safeguards.
- **Acceptable:** works correctly but has minor over-updates or weak fallback notes.
- **Needs work:** broad reload churn, unclear ownership, or fragile availability/fallback handling.

## See also
- `state-management.md`
- `animation-transitions.md`
- `modern-apis.md`
