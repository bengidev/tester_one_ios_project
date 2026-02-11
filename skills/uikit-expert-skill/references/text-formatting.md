# UIKit Text Formatting

## Overview
Use locale-correct formatting and reusable formatter instances.

## Preferred formatters
- `NumberFormatter` (currency, decimal, percent)
- `DateFormatter` (human-readable dates)
- `DateComponentsFormatter` (durations)

## Good pattern
```swift
enum Formatters {
  static let currency: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .currency
    return f
  }()
}

priceLabel.text = Formatters.currency.string(from: price as NSNumber)
```

## Bad pattern
- New formatter allocated per cell render.
- String concatenation with hardcoded separators.

## Dynamic Type and accessibility
- `adjustsFontForContentSizeCategory = true`
- Validate long localized strings and large font categories

## Checklist
- [ ] Locale-safe formatting everywhere user-facing
- [ ] Formatter reuse in place
- [ ] Text remains readable at large sizes

## Advanced scenarios
- **Formatter pools:** maintain shared formatter instances per locale/config to avoid reconfiguration churn.
- **Bidirectional text:** verify punctuation/number rendering in RTL locales.
- **Precision policy:** keep rounding/precision rules centralized to prevent inconsistent labels across screens.

## Review rubric
- **Excellent:** deterministic state flow, targeted updates, clear ownership, and measurable performance safeguards.
- **Acceptable:** works correctly but has minor over-updates or weak fallback notes.
- **Needs work:** broad reload churn, unclear ownership, or fragile availability/fallback handling.

## See also
- `view-structure.md`
- `performance-patterns.md`
- `modern-apis.md`
