# BetaTest Adaptive Mosaic Layout (iOS 12)

## Goal
Provide a structured but dynamic 2-column layout where a big card can expand to absorb overlap with stacked cards in the opposite column.

## Core Rule
If the next stacked card would cross the big card bottom boundary, expand big card height to that next card boundary.

- `expandBy = smallNextBottom - oldBigBottom`
- `newBigBottom = oldBigBottom + expandBy`

## Implementation
- `BetaTestAdaptiveMosaicLayout` (`UICollectionViewLayout`)
- Frame cache built in `prepare()`
- Rect-filtered attributes in `layoutAttributesForElements(in:)`
- Width-change invalidation

## Strategy
Use `BetaTestLayoutStrategy`:
- `.uniformGrid` (existing)
- `.adaptiveMosaic` (new)

## Responsive / Accessibility
- 2 columns by default
- 1-column fallback when width is too narrow (`singleColumnBreakpoint`)
- Text measured from Dynamic Type-aware card height estimator

## Tuning Knobs
- `rowUnit`
- `minimumItemHeight`
- `singleColumnBreakpoint`
- `bigItemMinimumSpan`, `bigItemMaximumSpan`
- `overlapTolerance`
