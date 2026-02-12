# Task Tracker Template

## Task: BetaTest Sequential Chain Processing + Per-Cell Customization

**Created:** 2026-02-12  
**Priority:** 1

### Objective
Replace batch/parallel result updates with chained sequential updates per card, enable per-cell customization parameters, and expose main-thread callback hooks after each step.

### Success Criteria
- [x] Processing runs sequentially cell-by-cell (loading -> result -> next).
- [x] Per-cell config can be updated without touching all cells.
- [x] A callback fires after each cell process completes (main thread).
- [x] Transition feels smooth (no hard snap for visible cells).
- [x] Build/test-compile validates via CLI without manual simulator run.

### Attempt 1: Sequential Controller + Cell Transition API

**Approach:**
- Refactor `BetaTestViewController.beginProcessing()` into recursive/chain execution.
- Expand `BetaTestItem` with `Content` + `RunPlan` for per-cell params.
- Add `onProcessStepCompleted` callback and per-item update APIs.
- Add animated state transition method in `BetaTestCollectionViewCell`.

**Result:** ⬜ In Progress (awaiting Beng manual UI validation)

**Notes:**
- Uses `UIView.transition(... .transitionCrossDissolve ...)` for visible-cell state change.
- Keeps `processDuration` as fallback, with per-item `RunPlan.loadingDuration` override.

---

> Track tasks with multiple attempts, success/failure states, and fallback strategies.

---

## Task Entry Format

### Task: [Task Name]

**Created:** [Date]  
**Priority:** [Number] (Higher will be prioritized)

#### Objective
[Clear description of what needs to be accomplished]

#### Success Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3
.
.
.
N. [Criterion N]

---

## Attempt Log

### Attempt 1: [Strategy Name]

**Approach:**
[Description of the method/approach tried]

**Steps:**
1. [Step 1]
2. [Step 2]
3. [Step 3]
.
.
.
N. [Step N]

**Result:** ⬜ Success / ❌ Failed

**If Failed:**
- **Error/Issue:** [What went wrong]
- **Root Cause:** [Why it failed]
- **Next Strategy:** [What to try differently]

**Notes:**
[Any observations, learnings, or adjustments needed]

---

### Attempt N: [Strategy Name]

**Approach:**
[Approach description]

**Steps:**
1. [Step 1]
2. [Step 2]
3. [Step 3]
.
.
.
N. [Step N]

**Result:** ⬜ Success / ❌ Failed

**If Failed:**
- **Error/Issue:** [What went wrong]
- **Root Cause:** [Why it failed]
- **Escalation Required:** ⬜ Yes / ⬜ No

**Notes:**
[Any observations, learnings, or adjustments needed]

---

## Summary

**Final Status:** ⬜ Completed / ❌ Failed / 🔄 In Progress / ⏸️ Blocked

**Completed On:** [Date]

### Key Learnings
1. [Learning 1]
2. [Learning 2]
3. [Learning 3]
.
.
.
N. [Learning N]

### Reusable Solution
[Document the successful approach for future similar tasks]

---

## Quick Reference: Strategies

When a task fails, consider these alternative approaches in order:

1. **Simplify** - Reduce scope or complexity
2. **Decompose** - Break into smaller sub-tasks
3. **Alternative Tool** - Try different library/framework/tool
4. **Different Angle** - Approach from different architectural perspective
5. **Manual Workaround** - Temporary manual solution
6. **Escalate** - Seek help from senior/team lead

---

# Active Tasks

## Task: Polish Transition/Animation for DeltaTestTableViewCell Self-Sizing

**Created:** 2026-02-06  
**Priority:** 1

### Objective
Polish transition/animation effect whenever the cell changes due to self-sizing (text size changes). Animation should affect both cell form AND text together. Must maintain iOS 12.0 compatibility with anchor-constraint system.

### Success Criteria
- [ ] Cell transition animates smoothly when action section appears/disappears
- [ ] Text animates alongside cell size changes (not just snaps)
- [ ] Self-sizing still works normally (text can wrap, cell expands)
- [ ] iOS 12.0 compatible (no iOS 13+ APIs)
- [ ] Anchor-constraint system preserved
- [ ] Build succeeds without errors

---

### Attempt 1: Coordinated Two-Phase Animation

**Approach:**
Implement coordinated animation where text, icon, and action section fade together during cell height changes. Use two-phase animation (fade out → apply state → fade in) with subtle scale effect.

**Steps:**
1. Modified `setActionSectionState(_:animated:)` to detect height changes vs content-only changes
2. Created `animateCellTransition(to:duration:)` for height-changing transitions
   - Phase 1 (35%): Fade text to 0.7, action to 0, icon to 0.8, scale card to 0.995
   - Phase 2 (65%): Apply state, fade all back to 1.0, restore scale
3. Created `animateContentTransition(to:duration:)` for same-height changes (quick fade)
4. Created `applyState(_:)` helper for immediate state application
5. Updated `configure(title:animated:)` with optional animation support
6. Updated `prepareForReuse()` to reset animation states

**Changes Made:**
- `DeltaTestTableViewCell.swift` - Complete animation system overhaul

**Result:** ❌ Failed

**If Failed:**
- **Error/Issue:** Text didn't animate when cell size changed from compact to tall (or vice versa). Animation only triggered on ULANGI button tap, not automatically following text size changes.
- **Root Cause:** Animation was tied to action section state changes (hidden/loading/success/failed), not to actual cell height changes from text wrapping. No mechanism to detect and animate label intrinsic content size changes.
- **Next Strategy:** Add animation that triggers when text content causes height change, coordinate with table view's row height animation, animate text alpha during the transition.

**Notes:**
- Build succeeded ("** BUILD SUCCEEDED **")
- All anchor constraints preserved - no constraint system changes
- Uses only iOS 12.0 compatible APIs (UIView.animate available since iOS 4.0)
- Self-sizing logic untouched - label still has compression resistance priorities
- Animation duration: 0.3s for height changes, 0.15s for content-only
- **FAILURE:** Animation not triggered by text-driven height changes

---

### Attempt 2: Height Detection in layoutSubviews

**Approach:**
Track previous bounds height in `layoutSubviews` and detect when cell height changes due to text wrapping. When detected, animate content (text scale + alpha) to create smooth transition.

**Steps:**
1. Added `previousBoundsHeight` property to track cell height across layout passes
2. Modified `layoutSubviews()` to compare current vs previous height
3. Created `animateContentForHeightChange(previousHeight:newHeight:)` method
   - Detects expanding (tall) vs contracting (compact) transitions
   - Expanding: text starts at alpha 0.6 with 0.98 scale, animates to normal
   - Contracting: text starts at alpha 0.7 with 0.99 scale, animates to normal
   - Duration: 0.25s with ease-out curve
4. Updated `prepareForReuse()` to reset height tracking to 0
5. Simplified `configure(title:)` to just set text and call `setNeedsLayout()`

**Changes Made:**
- `DeltaTestTableViewCell.swift` - Added height tracking and automatic animation

**Result:** ❌ Failed

**If Failed:**
- **Error/Issue:** Text appears "flashy" during animation - layoutSubviews detection happens AFTER layout, causing visual flash
- **Root Cause:** `layoutSubviews()` is called after the system has already laid out the cell at new height. The height comparison detects change too late, causing content to snap to new size then animate, creating flash effect.
- **Next Strategy:** Predict height change BEFORE layout by calculating text size in advance, then coordinate animation with text change rather than reacting to layout.

**Notes:**
- Build succeeded
- Animation now triggers automatically when text causes height change
- iOS 12.0 compatible (uses UIView.animate)
- Anchor constraints unchanged
- Text animates with scale + alpha during height transitions

---

### Attempt 3: Predictive Height Animation

**Approach:**
Instead of detecting height change AFTER layout (which causes flash), predict height change BEFORE layout by calculating text size using `boundingRect`. When height will change, animate text fade-out → text change → fade-in.

**Steps:**
1. Removed `previousBoundsHeight` tracking (reactive approach)
2. Modified `configure(title:animated:)` with predictive height calculation
3. Added `heightForText(_:width:)` method using NSString `boundingRect`
4. Compare current vs predicted height before setting text
5. If heights differ and animation requested:
   - Animate text alpha to 0.5, icon to 0.7 (fade out)
   - Set new text
   - Animate back to alpha 1.0 (fade in)
6. Updated `DeviceTestViewController.configureCell` to use `animated: true`

**Changes Made:**
- `DeltaTestTableViewCell.swift` - Predictive animation with cross-fade
- `DeviceTestViewController.swift` - Enable animation in cell configuration

**Result:** ❌ Failed

**If Failed:**
- **Error/Issue:** Dynamic text still appears "flashy" during transitions - the cross-fade creates a visible flash effect
- **Root Cause:** Two-phase fade (out → text change → in) creates momentary transparency that looks like a flash. Predictive height calculation is correct but animation approach is wrong.
- **Next Strategy:** Focus on text effect specifically - use text transition effects (cross-dissolve on label itself) rather than alpha fade, or use CATextLayer content transition.

**Notes:**
- Build succeeded
- Animation triggers BEFORE layout, preventing flash
- Two-phase fade: out (0.25s) → text change → in (0.25s)
- iOS 12.0 compatible (uses NSString.boundingRect, UIView.animate)
- Anchor constraints unchanged

---

### Attempt 4: Text-First Cross-Dissolve

**Approach:**
Focus specifically on text transition effect rather than cell-wide animation. Use UIView.transition with cross-dissolve on the titleLabel itself for smooth text content changes.

**Steps:**
1. Remove predictive height calculation (overly complex)
2. Use UIView.transition with .transitionCrossDissolve on titleLabel
3. Let label handle its own animation - simpler and smoother
4. Keep anchor constraints intact
5. Test for flash-free transitions

**Changes Made:**
- `DeltaTestTableViewCell.swift` - Simplified text-focused animation

**Result:** ❌ Failed

**If Failed:**
- **Error/Issue:** Created unwanted gap in UI (see image1.png in Screenshoots). Cross-dissolve on label interfered with layout, causing visual gap during transition.
- **Root Cause:** `UIView.transition` with `.transitionCrossDissolve` on the label directly may trigger layout changes or snapshot rendering that creates gaps.
- **Next Strategy:** Animate only the text color alpha, keeping label frame and layout completely stable.

**Notes:**
- Build succeeded
- Simplified approach - removed complex height calculation
- Uses UIView.transition with .transitionCrossDissolve directly on titleLabel
- iOS 12.0 compatible (UIView.transition available since iOS 4.0)
- Anchor constraints unchanged
- Animation duration: 0.25s for text transitions

---

### Attempt 5: Preserve Layout During Text Transition

**Approach:**
Instead of animating the label directly (which may cause layout gaps), snapshot the text appearance and cross-fade snapshots, or use a container view approach that doesn't affect the cell's layout constraints.

**Steps:**
1. Revert to direct text setting without UIView.transition on label
2. Use a snapshot-based approach or container view for animation
3. Ensure layout constraints remain stable during text changes
4. Test against image1.png reference

**Changes Made:**
- `DeltaTestTableViewCell.swift` - Layout-preserving text animation

**Result:** ❌ Failed

**If Failed:**
- **Error/Issue:** Gap still appears in UI during text animation. Text color fade creates visual gap/layout shift.
- **Root Cause:** Even animating just textColor can cause layout recalculation or visual artifacts when combined with cell height changes.
- **Next Strategy:** Don't animate text changes at all - instead animate the cell container or use CATransition on the label's layer without affecting layout.

**Notes:**
- Build succeeded
- Uses text color alpha animation instead of UIView.transition on label
- Two-phase: fade text color to 30% (0.12s) → change text → fade to full (0.18s)
- Layout constraints remain stable - only text color changes, not frame
- iOS 12.0 compatible (UIView.animate, withAlphaComponent)
- Anchor constraints unchanged
- **FAILURE:** Gap still present - text color animation approach doesn't solve layout issue

---

### Key Implementation Details

| Aspect | Implementation |
|--------|----------------|
| Height Change Animation | Two-phase: fade out (35%) → apply state → fade in (65%) |
| Content-Only Animation | Quick cross-dissolve with coordinated text fade |
| Scale Effect | Card briefly contracts to 0.995x during height change (anticipation) |
| Text Animation | Alpha transitions 1.0 → 0.7 → 1.0 during height changes |
| iOS Version | 12.0+ compatible (UIView.animate) |
| Constraints | All NSLayoutAnchor constraints preserved |
| Self-Sizing | Unchanged - label still drives cell height |

### Files Modified
- `Tester One/DeltaTestTableViewCell.swift` - Animation system implementation

---

### Attempt 6: Single Cell Focus with Long Text

**Approach:**
Focus on single cell implementation with longer text to isolate the animation issue. Create a dedicated test case that demonstrates smooth text transition without gaps or flash.

**Steps:**
1. Create simplified single-cell test scenario with long text
2. Use snapshot-based animation approach:
   - Snapshot current label appearance
   - Change text
   - Cross-fade from snapshot to new text
3. Ensure no layout passes during animation
4. Test with long text that causes multiple line wraps
5. Verify against reference image (image1.png)

**Changes Made:**
- `Tester One/DeltaTestTableViewCell.swift` - Snapshot-based text animation
- Focus on single cell with long text for testing

**Result:** ⬜ Pending Review

**Notes:**
- Build succeeded
- Uses snapshot-based animation: `snapshotView(afterScreenUpdates:)`
- Creates snapshot of current label, positions over label, changes text with label alpha=0
- Cross-fades from snapshot to new text (0.25s, easeInOut)
- Snapshot removed after animation completes
- Layout constraints untouched during animation - snapshot is a separate view
- iOS 12.0 compatible (`snapshotView` available since iOS 7.0)
- `prepareForReuse()` cleans up any lingering snapshots
- Focus on single cell with long text transitions
