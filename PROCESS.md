# UI Layout Debugging Process - AlphaTestTableViewCell

> Tracking document for layout constraint iterations and learnings.
> Pattern inspired by [Ralph](https://github.com/snarktank/ralph).

---

## Current Status

**Feature:** Fix AlphaTestTableViewCell layout constraints  
**Goal:** Make card height adapt to content (icon-based default, expands for multi-line titles)  
**State:** ✅ COMPLETED - Layout working correctly with multi-line text support  

---

## Attempted Approaches

### Attempt 1: Fixed Constraints with Minimum Height ❌

**Approach:**
```swift
// Fixed titleLabel to card edges
titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: padding)
titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -padding)
cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight)
```

**Result:** ❌ FAILED  
**Issue:** Constraint conflict - system sets cell height to 91pt, but minHeight (68.52pt) + padding exceeds available space.

**Log:**
```
UIView-Encapsulated-Layout-Height == 91
AlphaTestCell.cardView.height >= 68.52  <-- CONFLICT
```

---

### Attempt 2: TitleLabel Drives Card Height ✅

**Approach:**
```swift
// TitleLabel pushes card height
titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: padding)
titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -padding)

// Views center to cardView.centerYAnchor
iconImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
actionStackView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
```

**Result:** ✅ BUILD SUCCEEDED  
**Expected:**
- Short text: Card compact, centered content
- Long text: Card expands with titleLabel

**Runtime Testing:**
- [ ] Single line text
- [ ] Multi-line text
- [ ] Very long text (3+ lines)

---

### Attempt 3: Icon-Based Default, Title Can Expand ❌

**Approach:**
```swift
// Icon size + padding = default card height
let iconBasedHeight = iconSize + (verticalPadding * 2)
cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: iconBasedHeight)

// Title can expand beyond
```

**Result:** ❌ FAILED  
**Issue:** Still conflicts with system-set cell height (91pt vs 68.52pt min).

---

### Attempt 4: Priority-Based Constraints ❌

**Approach:**
```swift
titleLabel.topAnchor.constraint(greaterThanOrEqualTo: cardView.topAnchor, constant: padding)
titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -padding)
titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor).priority(.defaultHigh)
```

**Result:** ❌ FAILED  
**Issue:** Constraint ambiguity - UILabel with `numberOfLines = 0` needs explicit vertical constraints, not inequalities with centerY.

---

### Attempt 5: Simplified Approach ✅

**Approach:**
```swift
// No height constraints - let titleLabel drive card height
titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: verticalPadding)
titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -verticalPadding)

// All views center to cardView.centerYAnchor
iconImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
actionStackView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
```

**Changes Made:**
- Icon size: 13% → 12% of screen width
- verticalPadding: 3% → 4% of screen width
- Removed all `height >=` constraints
- Fixed titleLabel top/bottom to card edges

**Result:** ✅ BUILD SUCCEEDED  
**Runtime Issue:** Single line cards looked squished (too short for large icon)

---

### Attempt 6: Hybrid with Priority ✅

**Approach:**
```swift
// Larger icon (15%), closer to edge (2% padding)
let iconSize = Layout.screenWidth * 0.15
iconImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 0.02)

// Minimum height with HIGH priority (not required)
cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0.23)
  .priority(.defaultHigh)  // Allows system override if needed

// Button hugging priority (proper sizing)
actionButton.setContentHuggingPriority(.required, for: .horizontal)
actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
```

**Changes Made:**
- Icon size: 12% → 15% (larger)
- Icon padding: 3% → 2% (closer to edge)
- Added min card height: 23% with `.priority(.defaultHigh)`
- Button content hugging: required (prevents "U...GI" truncation)
- Action stack hugging: required

**Result:** ✅ WORKING
- Single line: Card at min height (icon fits properly)
- Multi-line: Card expands with titleLabel
- Button: Shows "ULANGI" fully (no truncation)

---

## Key Learnings

### Learning 1: System Cell Height
```
UIView-Encapsulated-Layout-Height' UITableViewCellContentView.height == 91
```
TableView sets explicit cell height (91pt in this case). Any `cardView.height >=` constraint must respect this or conflict.

**Implication:** Cannot use `cardView.height >=` with values that exceed available space after padding.

---

### Learning 2: UILabel Multi-Line Constraints

UILabel with `numberOfLines = 0` needs:
- **Either** explicit top + bottom (fixed)
- **Or** explicit height
- **Not** just centerY + >= top/bottom (ambiguous)

**Best Practice:** For expanding labels:
```swift
titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: padding)
titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -padding)
```

This makes the label's intrinsic height drive the superview's height.

---

### Learning 3: TableView Automatic Dimension

```swift
tableView.rowHeight = UITableView.automaticDimension
tableView.estimatedRowHeight = 64
```

Cell height = system calculation OR content-driven if properly constrained.  
Conflict occurs when constraints demand more height than system provides.

---

### Learning 4: Swift Warnings as Errors

This project has `SWIFT_TREAT_WARNINGS_AS_ERRORS = YES`.

**Gotcha:** Unused variables cause build failures!
```swift
// This will fail the build:
let iconBasedHeight = iconSize + (verticalPadding * 2)  // Never used
// error: initialization of immutable value 'iconBasedHeight' was never used
```

**Fix:** Remove unused variables or prefix with `_`:
```swift
_ = iconSize + (verticalPadding * 2)  // Explicitly ignore
```

---

### Learning 5: Priority-Based Height Constraints

When system sets explicit cell height, use `.priority(.defaultHigh)` instead of `.required`:

```swift
// ❌ FAILS: Required conflicts with system height constraint
cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
  .priority(.required)

// ✅ WORKS: High priority allows flexibility
cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
  .priority(.defaultHigh)
```

**Use case:** Minimum height for single-line cells that doesn't conflict with system.

---

### Learning 6: Content Hugging for Buttons

Button text was being truncated ("U...GI" instead of "ULANGI"):

```swift
// ❌ WRONG: Button gets compressed by other views
// Result: "U...GI" truncation

// ✅ CORRECT: Button sizes to fit its content
button.setContentHuggingPriority(.required, for: .horizontal)
button.setContentCompressionResistancePriority(.required, for: .horizontal)
```

**Key insight:** Views with text need proper hugging/compression priorities to display fully.

---

### Learning 7: Balancing Label Compression

Don't over-specify compression resistance on labels:

```swift
// ❌ WRONG: Pushes other views too aggressively
label.setContentCompressionResistancePriority(.required, for: .horizontal)
// Result: Button gets crushed, icon too close to edge

// ✅ CORRECT: Use graduated priorities
label.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
button.setContentCompressionResistancePriority(.defaultHigh + 2, for: .horizontal)
// Button slightly higher priority than label
```

---

### Learning 8: clipsToBounds and Corner Radius

When using corner radius with visual elements that extend near edges:

```swift
// ❌ WRONG: clipsToBounds clips subviews that extend near edges
view.clipsToBounds = true
view.layer.cornerRadius = 20
// Result: Icon gets clipped on left edge

// ✅ CORRECT: Let parent layer handle clipping or use masks
view.layer.cornerRadius = 20
// clipsToBounds removed - child views render fully
```

**Context:** In AlphaTestTableViewCell, the icon sits close to the left edge. With `clipsToBounds = true` on `borderView` and `cardView`, the circular icon was being clipped on the left side.

---

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| Icon size: 13% | Sweet spot for visibility without overwhelming |
| Icon padding: 1.2% | Close to left edge but not clipped |
| Card padding: 1.5% (thinPadding) | Consistent padding around content |
| No minHeightConstraint | Let icon + padding define natural minimum |
| Button priority: `.defaultHigh + 2` | Higher than label to show "ULANGI" fully |
| Label priority: `.defaultHigh + 1` | High but allows button to take space if needed |
| Remove `clipsToBounds` | Prevents icon clipping on left edge |
| `.required` vertical compression on label | Ensures multi-line text expands properly |

---

## Current Implementation (Attempt 7 - Final)

**File:** `Tester One/AlphaTestTableViewCell.swift`

```swift
private func setupConstraints() {
    let contentPadding = Layout.screenWidth * 0.03
    let iconLeadingPadding = Layout.screenWidth * 0.012
    let thinPadding = Layout.screenWidth * 0.015
    let stackSpacing = Layout.screenWidth * 0.015
    let borderWidth: CGFloat = 3
    let verticalPadding = Layout.screenWidth * 0.01
    let horizontalPadding = Layout.screenWidth * 0.025

    NSLayoutConstraint.activate([
        // MARK: Base View (shadow + outer frame)
        baseView.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor, constant: horizontalPadding),
        baseView.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
        baseView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalPadding),
        baseView.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor, constant: -verticalPadding),

        // MARK: Border View (green half-circle frame)
        borderView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
        borderView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
        borderView.topAnchor.constraint(equalTo: baseView.topAnchor),
        borderView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor),

        // MARK: Card View (white inner content area)
        cardView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: borderWidth),
        cardView.trailingAnchor.constraint(
            equalTo: borderView.trailingAnchor, constant: -borderWidth),
        cardView.topAnchor.constraint(equalTo: borderView.topAnchor, constant: borderWidth),
        cardView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -borderWidth),

        // MARK: Icon Image View
        iconImageView.leadingAnchor.constraint(
            equalTo: cardView.leadingAnchor, constant: iconLeadingPadding),
        iconImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

        // MARK: Title Label - drives card height
        titleLabel.leadingAnchor.constraint(
            equalTo: iconImageView.trailingAnchor, constant: stackSpacing),
        titleLabel.trailingAnchor.constraint(
            equalTo: actionStackView.leadingAnchor, constant: -stackSpacing),
        titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: thinPadding),
        titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -thinPadding),

        // MARK: Action Stack View
        actionStackView.trailingAnchor.constraint(
            equalTo: cardView.trailingAnchor, constant: -contentPadding),
        actionStackView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

        // MARK: Status Image View
        statusImageView.widthAnchor.constraint(equalToConstant: Layout.screenWidth * 0.06),
        statusImageView.heightAnchor.constraint(equalToConstant: Layout.screenWidth * 0.06),
    ])
}
```

**Content Priorities:**
```swift
// titleLabel
label.setContentCompressionResistancePriority(.required, for: .vertical)
label.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)

// actionButton
button.setContentHuggingPriority(.defaultHigh + 2, for: .horizontal)
button.setContentCompressionResistancePriority(.defaultHigh + 2, for: .horizontal)

// actionStackView
stack.setContentHuggingPriority(.defaultHigh, for: .horizontal)
```

**View Configuration:**
```swift
// borderView and cardView - NO clipsToBounds
view.layer.cornerRadius = Layout.screenWidth * 0.08
// clipsToBounds removed to prevent icon clipping
```

---

## Open Questions (All Resolved)

1. ✅ **Q:** Will short text cells look too compressed?  
   **A:** No - icon size (13%) + padding provides natural minimum height.

2. ✅ **Q:** Should iconImageView have minimum top/bottom constraints?  
   **A:** Not needed - centerY + card padding keeps it properly positioned.

3. ✅ **Q:** How does this work with tableView reload/scroll?  
   **A:** Works correctly - cells resize properly on reuse.

---

## Next Steps (Completed)

1. ✅ Simplify constraints (Attempt 5 - Done)
2. ✅ Fix build errors (unused variable - Done)
3. ✅ Test on simulator with various text lengths
4. ✅ Fix icon clipping (remove clipsToBounds - Done)
5. ✅ Fix button truncation (balanced priorities - Done)
6. ✅ Fix ambiguous layout (proper horizontal compression - Done)
7. ✅ Final verification and documentation

---

## Files Modified

- `Tester One/AlphaTestTableViewCell.swift` - Final working constraint setup
  - Removed `clipsToBounds` from `borderView` and `cardView`
  - Balanced content priorities between label and button
  - Removed problematic `minHeightConstraint`
  - Added proper MARK comments for organization
- `Tester One/AutoLayoutDebugger.swift` - Runtime constraint debugging
- `Tester One/AppDelegate.swift` - Temporary navigation change (reverted)
- `PROCESS.md` - This file (comprehensive debugging log)
- `progress.txt` - Append-only log
- `AGENTS.md` - Updated with layout debugging patterns

### Attempt 7: Final Working Solution ✅

**Approach:**
```swift
// Key fixes:
// 1. Removed clipsToBounds from borderView/cardView (was clipping icon)
// 2. Balanced content priorities between label and button
// 3. Removed problematic minHeightConstraint

// titleLabel - high but not required horizontal compression
label.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)

// actionButton - slightly higher priority to show "ULANGI" fully  
button.setContentHuggingPriority(.defaultHigh + 2, for: .horizontal)
button.setContentCompressionResistancePriority(.defaultHigh + 2, for: .horizontal)

// Constraints - titleLabel drives card height
titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: thinPadding)
titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -thinPadding)
```

**Changes Made:**
- Removed `clipsToBounds = true` from borderView and cardView
- Removed minHeightConstraint entirely - let icon size + padding define min height naturally
- Balanced priorities: Button (.defaultHigh + 2) > Label (.defaultHigh + 1)
- Icon size: 13% of screen width (sweet spot for visibility)

**Result:** ✅ FULLY WORKING
- Single line: Card compact with proper icon centering
- Multi-line: Card expands to show full title text
- Button: "ULANGI" fully visible on all cells
- No constraint conflicts or ambiguous layouts

**Screenshot Verification:**
- Multi-line cells expand properly ("Touchscreen Responsiveness", "Charging Port...")
- Single-line cells maintain proper height
- Icons no longer clipped on left edge

---

## References

- [Ralph Pattern](https://github.com/snarktank/ralph)
- Auto Layout Guide: [Working with Self-Sizing Table View Cells](https://developer.apple.com/documentation/uikit/uiview/1622600-intrinsiccontentsize)
- [ios-simulator-mcp](https://github.com/joshuayoes/ios-simulator-mcp) - MCP server for iOS Simulator interaction
  - Used for: Taking screenshots, launching apps, simulating taps
  - Alternative to Xcode UI tests for quick visual verification
