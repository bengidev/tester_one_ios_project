# UIKit Image Optimization

## Overview
Optimize decoding, sizing, and assignment to protect scroll performance.

## Pipeline
1. Fetch/receive image data
2. Downsample to target render size
3. Decode off-main when possible
4. Cache by URL + target size
5. Assign with identity guard

## Good pattern
```swift
override func prepareForReuse() {
  super.prepareForReuse()
  imageTask?.cancel()
  representedID = nil
  thumbnailView.image = placeholder
}

func configure(with item: Item) {
  representedID = item.id
  imageTask = loader.load(item.imageURL, targetSize: thumbnailView.bounds.size) { [weak self] image in
    guard let self, self.representedID == item.id else { return }
    self.thumbnailView.image = image
  }
}
```

## Bad pattern
- Decode full 4K image in cell callback for tiny thumbnail.
- Assign async result without checking current represented model.

## UIKit ↔ SwiftUI parity
- Cell reuse guard here mirrors `AsyncImage` phase identity concerns in SwiftUI lists.

## Checklist
- [ ] Reuse cancellation implemented
- [ ] Downsampling size matches display scale
- [ ] Memory spikes during fast scroll are acceptable

## Advanced scenarios
- **Progressive display:** show low-res placeholder first, then swap to final downsampled asset when ready.
- **Memory pressure response:** clear non-critical caches on memory warning and repopulate lazily.
- **Preheating windows:** prefetch near-visible rows/items to smooth rapid scrolling.

## Review rubric
- **Excellent:** deterministic state flow, targeted updates, clear ownership, and measurable performance safeguards.
- **Acceptable:** works correctly but has minor over-updates or weak fallback notes.
- **Needs work:** broad reload churn, unclear ownership, or fragile availability/fallback handling.

## See also
- `performance-patterns.md`
- `list-patterns.md`
- `view-structure.md`
