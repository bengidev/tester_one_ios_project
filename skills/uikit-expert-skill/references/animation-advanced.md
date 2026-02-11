# UIKit Animation Advanced

## Overview
Use advanced animation for interaction-critical experiences only.

## Tools
- `UIViewPropertyAnimator`: interruptible, reversible, scrubbed animation
- `UIView.animateKeyframes`: staged choreography
- `UIPercentDrivenInteractiveTransition`: gesture-coupled controller transitions

## Decision guide
| Scenario | Preferred approach |
|---|---|
| User can quickly retrigger | property animator with cancellation |
| Multi-step timing | keyframes |
| Gesture-driven dismissal | percent-driven transition |

## Example: interruptible panel
```swift
private var animator: UIViewPropertyAnimator?

func setExpanded(_ expanded: Bool) {
  animator?.stopAnimation(true)
  animator = UIViewPropertyAnimator(duration: 0.35, dampingRatio: 0.9) {
    self.panelTop.constant = expanded ? 24 : 260
    self.view.layoutIfNeeded()
  }
  animator?.startAnimation()
}
```

## Example: keyframes
```swift
UIView.animateKeyframes(withDuration: 0.7, delay: 0) {
  UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.4) {
    self.icon.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
  }
  UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6) {
    self.icon.transform = .identity
  }
}
```

## Pitfalls
- Async delay chains as implicit state machine.
- Multiple animators competing over same constraints.
- Completion blocks mutating state after view is gone.

## Checklist
- [ ] Interruption path keeps valid final state
- [ ] Gesture cancellation and completion both tested
- [ ] Animator references cleaned up to avoid leaks

## Advanced scenarios
- **Gesture scrubbing:** bind pan progress to animator `fractionComplete` and resolve using velocity on end.
- **State preemption:** when a new intent arrives mid-animation, commit to canonical end-state before launching next transition.
- **Transition coordinator:** use transition coordinator callbacks for synchronized chrome animations during push/pop.

## Review rubric
- **Excellent:** deterministic state flow, targeted updates, clear ownership, and measurable performance safeguards.
- **Acceptable:** works correctly but has minor over-updates or weak fallback notes.
- **Needs work:** broad reload churn, unclear ownership, or fragile availability/fallback handling.

## See also
- `animation-basics.md`
- `animation-transitions.md`
- `state-management.md`
