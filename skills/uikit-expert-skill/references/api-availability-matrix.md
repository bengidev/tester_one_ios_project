# API Availability Matrix (UIKit-focused)

## Goal
Make version decisions explicit and safe.

| Feature/Area | Preferred API | Min iOS | Fallback for iOS 12 |
|---|---|---:|---|
| Nav bar styling | `UINavigationBarAppearance` | 13 | `barTintColor`, title attrs, shadow/background image |
| Diffable data source | `UICollectionViewDiffableDataSource` | 13 | classic data source + stable ID mapping |
| Dynamic colors | semantic dynamic colors | 13 | static mapped color palette |
| Activity indicator style | `.medium/.large` | 13 | `.gray/.white` |
| SwiftUI hosting | `UIHostingController` | 13 | UIKit screen path |

## Usage rule
- Gate modern path with `#available`.
- Ensure fallback path is behaviorally equivalent.
- Document intentional differences when unavoidable.
