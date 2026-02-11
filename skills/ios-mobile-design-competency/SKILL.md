---
name: ios-mobile-design-competency
description: Master Apple-standard iOS UI design and implementation across SwiftUI and UIKit. Use when designing or reviewing iOS screens to follow Human Interface Guidelines (HIG), build adaptive layouts, choose navigation patterns (NavigationStack/TabView/sheets or UINavigationController/UITabBarController), integrate SF Symbols/system typography/semantic colors, ensure Dark Mode + high-contrast support, and implement accessibility (VoiceOver, Dynamic Type, touch targets).
---

# iOS Mobile Design Competency

Use this skill to *design and implement polished, native iOS UI* that matches Apple conventions and stays compliant across:
- **SwiftUI** (declarative)
- **UIKit** (imperative)

## Operating rules (fast)

- Prefer **system defaults** first: semantic colors, dynamic type styles, SF Symbols.
- Respect **safe areas** and **touch targets (>= 44x44pt)**.
- Validate **Dark Mode** and **Dynamic Type** early (not at the end).
- Treat **accessibility** as a feature, not a pass.

## Workflow

### 1) Clarify the UI contract
Capture, in 5 bullets:
- Screen purpose + primary action
- Information hierarchy (what’s most important?)
- Navigation entry/exit (push? tab? modal?)
- States (loading/empty/error)
- Accessibility expectations (labels, headings, focus order)

### 2) Pick the framework layer
- Use **SwiftUI** when you can (new screens, rapid iteration, composable UI).
- Use **UIKit** when needed (legacy app sections, fine-grained control, advanced collection layouts, specific integrations).
- Mixed is fine: embed via **UIHostingController** or **UIViewControllerRepresentable**.

### 3) Layout implementation checklist
**SwiftUI**
- Compose with `VStack/HStack/ZStack`; use `Spacer()` intentionally.
- Prefer `LazyVGrid/LazyHGrid` for collections.
- Use `GeometryReader` only when necessary; avoid “layout hacks”.
- Use `.safeAreaInset` / `.ignoresSafeArea` deliberately.

**UIKit**
- Prefer Auto Layout anchors + `NSLayoutConstraint.activate`.
- Use `UIStackView` for vertical/horizontal structure; constrain the stack, not every child.
- Pin to `safeAreaLayoutGuide`.

### 4) Navigation patterns
- **Hierarchical (push):**
  - SwiftUI: `NavigationStack` + `navigationDestination`
  - UIKit: `UINavigationController.pushViewController`
- **Tab-based:**
  - SwiftUI: `TabView`
  - UIKit: `UITabBarController`
- **Modal / sheet:**
  - SwiftUI: `.sheet` / `.fullScreenCover`
  - UIKit: `present(_:animated:)` with appropriate `modalPresentationStyle`

### 5) System assets & typography
- SF Symbols:
  - SwiftUI: `Image(systemName:)`
  - UIKit: `UIImage(systemName:)`
  - Configure scale/weight with symbol configuration when needed.
- Typography:
  - Use semantic text styles (`.body`, `.headline`, etc.) not fixed sizes.
  - Ensure Dynamic Type is supported.

### 6) Theming & visual design
- Use **semantic colors** (`.systemBackground`, `.label`, `.secondaryLabel`, `.tint`, etc.).
- Avoid hard-coded hex unless defining Asset Catalog colors properly.
- Keep elevation subtle; prefer system materials for blur.

### 7) Accessibility (A11y)
- Set **labels**, **hints**, and correct **traits**.
- Ensure logical focus order.
- Verify tap targets.
- Don’t rely on color alone to convey meaning.

## Done criteria (ship checklist)
- Works on at least: small iPhone + large iPhone + iPad (or explicitly out-of-scope).
- Passes Dark Mode + increased contrast.
- Passes Dynamic Type (including largest sizes) without truncation of key content.
- VoiceOver: elements are discoverable, labeled, and navigable.

## References
- For detailed snippets/patterns, read: `references/patterns.md`.
