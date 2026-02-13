# BetaTest Module (UIKit, iOS 12+)

## Purpose
`BetaTest` is now structured as a standalone, host-injectable feature module that can be transplanted into a production app.

## Design constraints
- iOS 12.0+
- Programmatic UI only (no Storyboard dependency)
- Auto Layout via anchor constraints
- Dynamic multiline card content
- Masonry-like feed behavior (Instagram Explore style)

## Public entrypoint
```swift
let vc = BetaTestModule.makeViewController(
  configuration: .init(
    items: [...],
    layoutStrategy: .adaptiveMosaic,
    screen: .init()
  )
)
```

## Module surface
- `BetaTestModule`
  - `makeViewController(configuration:executionProvider:)`
- `BetaTestModuleConfiguration`
  - `Module`
  - `Item`
  - `Screen`
- `BetaTestExecutionProviding`
  - host can inject real execution pipeline for production

## Internals
- `BetaTestViewController`: orchestration + state transitions
- `BetaTestCollectionViewCell`: dynamic self-sizing card
- `BetaTestAdaptiveMosaicLayout`: waterfall/masonry-like layout with overlap absorption

## Production implantation strategy
1. Keep `BetaTestModuleConfiguration.Item` as host-facing DTO.
2. Replace `BetaTestDefaultExecutionProvider` with real implementation:
   - hardware checks
   - network checks
   - async service calls
3. Keep `onProcessingEvent` callback wiring in host layer for analytics and logging.
4. Keep theming in `BetaTestTheme` and map colors from design tokens.

## Notes
- Card height is driven by multiline title content and measured via Auto Layout sizing cell.
- Layout is adaptive and remains anchor-constraint-driven across iPhone sizes.
