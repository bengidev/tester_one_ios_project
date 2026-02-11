---
name: ios-developer-competency-matrix
description: Professional iOS development competency coverage across Swift language mastery, SwiftUI + UIKit UI development, architecture/patterns (MVVM, Coordinator, Clean), networking/data/persistence, platform capabilities (lifecycle, background, device features), accessibility, testing/debugging/performance, and CI/CD + App Store distribution. Use when implementing or reviewing iOS code for best-practice patterns, concurrency/thread-safety, memory/ARC issues, architecture decisions, data layers, testing strategy, or release readiness.
---

# iOS Developer Competency Matrix

Use this skill as a **review + implementation checklist** when building features in this repo.

## 1) Quick triage questions (pick the right lane)
Answer these before coding:
- Is this mostly **UI** (SwiftUI/UIKit), **domain logic**, **data/network**, or **platform integration**?
- Do we need **async** work? If yes: can we use **structured concurrency** end-to-end?
- What are the **states** (loading/empty/error/success) and how are they represented?
- What must be **testable** (unit/UI/snapshot) and what is the acceptance criteria?

## 2) Swift language & concurrency rules
- Prefer **Swift concurrency** (`async/await`) over nested completion handlers.
- UI mutations on the **main actor** (`@MainActor` / `await MainActor.run`).
- Use **actors** or isolated types for shared mutable state.
- Watch for ARC traps: closures capturing `self` → use `[weak self]` when needed.

## 3) UI (SwiftUI + UIKit)
- SwiftUI: choose the right state tool (`@State`, `@Binding`, `@StateObject`, `@ObservedObject`, `@Environment`).
- UIKit: respect lifecycle, safe areas, and Auto Layout anchors.
- Interop:
  - SwiftUI in UIKit: `UIHostingController`
  - UIKit in SwiftUI: `UIViewRepresentable` / `UIViewControllerRepresentable`

## 4) Architecture & patterns
Default opinionated picks (override only with reason):
- SwiftUI screens: **MVVM** (View + ViewModel + injected services)
- Navigation complexity: add a **Coordinator** (or a routing layer)
- Scale/enterprise modules: consider **Clean** boundaries (domain/use-cases, repositories)
- Dependency injection: start with **initializer injection**; add a container only when it pays off.

## 5) Networking & data
- Prefer `URLSession` + `Codable` with explicit domain errors.
- Model API errors → map to **user-facing** messages at the edge.
- Persistence: SwiftData/Core Data for relational graphs; Keychain for secrets; UserDefaults for prefs.

## 6) Platform integration
- Understand scene lifecycle vs app delegate responsibilities.
- For background work, pick the correct API (and keep expectations realistic).
- Device features (camera/location/push/biometrics): treat permission flows + failure paths as first-class.

## 7) Quality: tests, debugging, performance
- Unit tests for logic; UI tests for key flows; snapshot tests for UI regressions (if used here).
- Use Instruments for leaks/time/energy when performance matters.

## 8) Release readiness
- HIG alignment + accessibility basics.
- Review Guideline landmines: privacy disclosures, permissions strings, incomplete flows.
- CI/CD: prefer SPM; automate build/test; keep signing/provisioning sane.

## References
- Deep checklists + snippets: `references/checklists.md`
