# BetaTest Module Refactor and De-Optimization (iOS 12+ UIKit)

## TL;DR

> **Quick Summary**: Refactor BetaTest into a cleaner, portable UIKit module by removing over-engineered optimization layers and host-coupled debug seams, while preserving iOS 12 compatibility and anchor-constraint UI behavior.
>
> **Deliverables**:
> - Leaner BetaTest internals (reduced cache/reload/focus complexity)
> - Host/module seam migration away from direct `debug_*` coupling
> - Updated docs and project configuration consistency for iOS 12 baseline
> - Agent-executed QA evidence for behavior and compatibility
>
> **Estimated Effort**: Large
> **Parallel Execution**: YES - 3 implementation waves + final verification wave
> **Critical Path**: 1 -> 2 -> 3 -> 7 -> 10 -> 14 -> 15 -> F1/F2/F3/F4

---

## Context

### Original Request
User requested deep analysis of project docs and relevant files to identify and remove overkill/overused optimizations so `BetaTest` can be used as a standalone module, with iOS 12 UIKit anchor-constraint support and latest iOS compatibility.

### Interview Summary
**Key Discussions**:
- Exhaustive analysis completed across BetaTest code, host integration, docs, and Apple guidance.
- Concrete hotspots identified in `BetaTestViewController`, `BetaTestCollectionViewCell`, and `BetaTestAdaptiveMosaicLayout`.
- Host coupling confirmed through `AppDelegate` automation use of `debug_*` methods.
- User selected **NO automated tests**; verification will use agent-executed QA scenarios.

**Research Findings**:
- Over-optimization layers exist: multi-cache sizing paths, deferred reload queue, focus telemetry arrays, and broad layout cache logic.
- Docs/code drift exists (`singleColumnBreakpoint` docs vs 2-column-only implementation).
- Project configuration drift exists (mixed deployment targets 12.0 and 26.1 in pbxproj).
- Apple-aligned refactor direction: keep anchors/safe areas, use targeted layout invalidation, maintain proper `#available` branching.

### Metis Review
**Identified Gaps (addressed in this plan)**:
- Gap: Risky hard removal of `debug_*` APIs.
  - Resolution: staged seam migration via debug harness before removal.
- Gap: Potential iOS 12 regression if all optimization is removed at once.
  - Resolution: phased simplification with guardrails and QA evidence on each wave.
- Gap: Scope creep into redesign/rewrites.
  - Resolution: strict Must-NOT-Have list and module-boundary constraints.
- Gap: Acceptance criteria not fully command-verifiable.
  - Resolution: all task criteria include concrete agent-executed QA scenarios and evidence outputs.

---

## Work Objectives

### Core Objective
Refactor BetaTest to eliminate non-essential complexity and host leakage while preserving visible behavior, iOS 12 compatibility, anchor-based UIKit layout, and latest iOS runtime correctness.

### Concrete Deliverables
- Refactored internals in:
  - `Tester One/BetaTest/BetaTestViewController.swift`
  - `Tester One/BetaTest/BetaTestCollectionViewCell.swift`
  - `Tester One/BetaTest/BetaTestAdaptiveMosaicLayout.swift`
- Debug seam migration and host integration cleanup in:
  - `Tester One/AppDelegate.swift`
  - (if needed) new internal debug harness file(s) under `Tester One/BetaTest/`
- Documentation alignment in:
  - `docs/BetaTestAdaptiveMosaicPlan.md`
  - `docs/BetaTestModule.md`
  - `docs/BetaTestOptimizationRecord.md`
- Project config alignment in:
  - `Tester One.xcodeproj/project.pbxproj`

### Definition of Done
- [ ] BetaTest module no longer depends on host automation behavior inside module internals.
- [ ] Over-optimization hotspots are removed/simplified per plan.
- [ ] iOS 12 compatibility path remains valid.
- [ ] Debug and Release simulator builds succeed.
- [ ] Agent QA evidence artifacts are produced for all scenarios.

### Must Have
- Preserve `BetaTestModule.makeViewController(configuration:)` public entrypoint.
- Preserve anchor-constraint UIKit UI construction.
- Preserve state flow semantics (`initial/loading/success/failed`, retry path, sequential processing).
- Keep behavior compatible on iOS 12 and latest iOS.

### Must NOT Have (Guardrails)
- No SwiftUI rewrite or architectural redesign outside requested scope.
- No visual redesign of card system (only behavior-safe simplification).
- No direct host automation/environment coupling inside module internals.
- No stale docs describing removed 1-column behavior.
- No deployment-target drift across app/test targets once alignment is applied.

---

## Verification Strategy (MANDATORY)

> **ZERO HUMAN INTERVENTION** — all verification is agent-executed.

### Test Decision
- **Infrastructure exists**: YES (XCTest + scripts)
- **Automated tests**: None (user decision)
- **Framework**: N/A for acceptance gating

### QA Policy
Every task includes executable QA scenarios with concrete steps and evidence paths.
Evidence root: `.sisyphus/evidence/`

| Deliverable Type | Verification Tool | Method |
|------------------|-------------------|--------|
| Frontend/UI | Playwright | Launch app UI, navigate, assert visible state and screenshot |
| UIKit runtime/CLI | Bash + xcodebuild | Build/run commands, assert status and output |
| Module boundary checks | Bash (grep) | Assert forbidden coupling patterns are absent |
| Docs/config alignment | Bash (grep/showBuildSettings) | Assert exact strings/settings |

---

## Execution Strategy

### Parallel Execution Waves

Wave 1 (Start Immediately — foundation and seam setup):
- Task 1: Deployment target alignment + availability baseline [quick]
- Task 2: Introduce debug harness seam for BetaTest [unspecified-high]
- Task 3: Migrate AppDelegate automation to harness [quick]
- Task 4: Constraint activation cleanup (`.compactMap`) [quick]
- Task 5: Docs drift alignment (2-column policy) [writing]

Wave 2 (After Wave 1 — core simplification):
- Task 6: Simplify reload queue path [unspecified-high]
- Task 7: Remove focus telemetry arrays + debug telemetry APIs [quick]
- Task 8: Simplify ViewController measurement caching [deep]
- Task 9: Simplify cell preferred-height cache strategy [deep]
- Task 10: Simplify adaptive mosaic tuning + invalidation/caches [deep]

Wave 3 (After Wave 2 — integration and portability hardening):
- Task 11: Simplify fallback image cache + memory warning path [quick]
- Task 12: iOS 12/latest availability + theme compatibility pass [unspecified-high]
- Task 13: Public API/config portability pass (host-neutral boundaries) [unspecified-high]
- Task 14: Remove legacy `debug_*` APIs and dead references [quick]
- Task 15: End-to-end QA evidence run + boundary/doc/config checks [deep]

Wave FINAL (After all tasks — independent review):
- Task F1: Plan compliance audit [oracle]
- Task F2: Code quality review [unspecified-high]
- Task F3: Real QA scenario replay [unspecified-high]
- Task F4: Scope fidelity check [deep]

Critical Path: 1 -> 2 -> 3 -> 7 -> 10 -> 14 -> 15 -> F1/F2/F3/F4
Parallel Speedup: ~65% faster than sequential
Max Concurrent: 5

### Dependency Matrix

| Task | Depends On | Blocks | Wave |
|------|------------|--------|------|
| 1 | — | 12, 15 | 1 |
| 2 | — | 3, 14 | 1 |
| 3 | 2 | 14, 15 | 1 |
| 4 | — | 8, 9, 10 | 1 |
| 5 | — | 15 | 1 |
| 6 | 4 | 15 | 2 |
| 7 | 2, 3 | 14, 15 | 2 |
| 8 | 4 | 10, 15 | 2 |
| 9 | 4 | 10, 15 | 2 |
| 10 | 8, 9 | 15 | 2 |
| 11 | 9 | 15 | 3 |
| 12 | 1 | 15 | 3 |
| 13 | 3, 5 | 15 | 3 |
| 14 | 2, 3, 7 | 15 | 3 |
| 15 | 1, 3, 5, 6, 7, 10, 11, 12, 13, 14 | F1-F4 | 3 |
| F1 | 15 | — | FINAL |
| F2 | 15 | — | FINAL |
| F3 | 15 | — | FINAL |
| F4 | 15 | — | FINAL |

### Agent Dispatch Summary

| Wave | # Parallel | Tasks -> Agent Category |
|------|------------|--------------------------|
| 1 | 5 | T1/T3/T4 -> `quick`, T2 -> `unspecified-high`, T5 -> `writing` |
| 2 | 5 | T6 -> `unspecified-high`, T7 -> `quick`, T8/T9/T10 -> `deep` |
| 3 | 5 | T11/T14 -> `quick`, T12/T13 -> `unspecified-high`, T15 -> `deep` |
| FINAL | 4 | F1 -> `oracle`, F2/F3 -> `unspecified-high`, F4 -> `deep` |

---

## TODOs

- [ ] 1. Align deployment targets and establish compatibility baseline

  **What to do**:
  - Normalize `IPHONEOS_DEPLOYMENT_TARGET` values in `Tester One.xcodeproj/project.pbxproj` to the approved baseline (iOS 12.0 unless explicitly overridden by policy).
  - Run Debug + Release simulator builds to catch availability regressions early.
  - Record any iOS 13+ API callsites that need guarded fallback (do not refactor all yet; just baseline-capture).

  **Must NOT do**:
  - Do not raise minimum deployment target above iOS 12.0.
  - Do not introduce new iOS-version-specific APIs without `#available`.

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: focused config/build hygiene task with small file set.
  - **Skills**: [`git-master`]
    - `git-master`: useful for safe config edits and isolated commit hygiene.
  - **Skills Evaluated but Omitted**:
    - `playwright`: not needed for non-UI config update.

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 2, 3, 4, 5)
  - **Blocks**: 12, 15
  - **Blocked By**: None

  **References**:
  - `Tester One.xcodeproj/project.pbxproj` - single source of target deployment settings; currently mixed values are present.
  - `README.md` - declares iOS 12 target intent; use as policy reference.
  - `Tester One/BetaTest/BetaTestTheme.swift` - availability-sensitive color APIs (`#available`) to confirm baseline compatibility.

  **Acceptance Criteria**:
  - [ ] `xcodebuild ... Debug ... build` succeeds.
  - [ ] `xcodebuild ... Release ... build` succeeds.
  - [ ] `xcodebuild -showBuildSettings | grep IPHONEOS_DEPLOYMENT_TARGET` output is policy-consistent.

  **QA Scenarios**:
  ```
  Scenario: Deployment target baseline is consistent
    Tool: Bash (xcodebuild)
    Preconditions: project file updated
    Steps:
      1. Run showBuildSettings grep for IPHONEOS_DEPLOYMENT_TARGET.
      2. Parse all emitted target values.
      3. Assert all values match approved baseline.
    Expected Result: one consistent deployment target policy is visible.
    Failure Indicators: mixed values (e.g., 12.0 and 26.1) still present.
    Evidence: .sisyphus/evidence/task-1-deployment-targets.txt

  Scenario: Build catches accidental availability regressions
    Tool: Bash (xcodebuild)
    Preconditions: same workspace state
    Steps:
      1. Run Debug simulator build.
      2. Run Release simulator build.
      3. Assert both end with BUILD SUCCEEDED.
    Expected Result: both configurations build cleanly.
    Evidence: .sisyphus/evidence/task-1-build-debug-release.txt
  ```

  **Evidence to Capture**:
  - [ ] target listing output
  - [ ] debug/release build logs

  **Commit**: YES
  - Message: `chore(ios): normalize deployment targets for iOS 12 baseline`
  - Files: `Tester One.xcodeproj/project.pbxproj`
  - Pre-commit: debug + release builds

- [ ] 2. Introduce debug harness seam to decouple module internals

  **What to do**:
  - Add an internal/debug harness abstraction for retry/scroll/test hooks currently exposed as direct `debug_*` methods.
  - Route BetaTest debug behaviors through this seam so host/test code can migrate without direct controller internals.
  - Keep new seam behind debug-only boundary to avoid production API expansion.

  **Must NOT do**:
  - Do not break existing production callback surfaces (`onProcessingEvent`, `onRetryCompleted`).
  - Do not add new public API to `BetaTestModule` unless strictly necessary.

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: cross-file API seam work with migration safety concerns.
  - **Skills**: [`git-master`]
    - `git-master`: helps isolate staged migration changes.
  - **Skills Evaluated but Omitted**:
    - `playwright`: implementation is non-browser logic.

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1
  - **Blocks**: 3, 7, 14
  - **Blocked By**: None

  **References**:
  - `Tester One/BetaTest/BetaTestViewController.swift:155` - current `debug_*` surface and internal coupling.
  - `Tester One/AppDelegate.swift:79` - host automation currently reaches controller debug APIs.
  - `Tester OneTests/BetaTest/BetaTestViewControllerTests.swift` - tests that rely on debug calls.

  **Acceptance Criteria**:
  - [ ] A single debug seam exists and can trigger retry/scroll equivalents without direct raw `debug_*` usage.
  - [ ] Existing behavior paths still execute correctly through seam forwarding.

  **QA Scenarios**:
  ```
  Scenario: Debug seam forwards retry action correctly
    Tool: Bash (xcodebuild + runtime automation)
    Preconditions: debug harness integrated in module
    Steps:
      1. Build app in Debug.
      2. Launch with automation env and trigger retry through seam path.
      3. Assert retry completion event is emitted.
    Expected Result: retry still works without direct host call to legacy method.
    Failure Indicators: retry no-op, missing callback, crash.
    Evidence: .sisyphus/evidence/task-2-debug-harness-retry.txt

  Scenario: Debug seam is not exposed in production API
    Tool: Bash (grep)
    Preconditions: seam implementation complete
    Steps:
      1. Search module public API declarations.
      2. Verify seam is debug/internal only.
    Expected Result: no unintended public API expansion.
    Evidence: .sisyphus/evidence/task-2-debug-harness-visibility.txt
  ```

  **Evidence to Capture**:
  - [ ] retry forwarding output
  - [ ] API visibility grep output

  **Commit**: YES
  - Message: `refactor(betatest): add debug harness seam for migration`
  - Files: `Tester One/BetaTest/*`
  - Pre-commit: debug build

- [ ] 3. Migrate AppDelegate automation off direct controller debug calls

  **What to do**:
  - Replace direct calls (`debug_triggerRetry`, `debug_scrollToBottom/Top/Middle`) in `AppDelegate` with harness-backed interactions.
  - Preserve existing automation flow semantics and snapshot timing behavior.
  - Ensure automation remains host-side and not reintroduced into module internals.

  **Must NOT do**:
  - Do not remove automation capability required for evidence capture.
  - Do not move ProcessInfo/environment parsing into BetaTest module.

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: focused host-wiring migration with bounded blast radius.
  - **Skills**: [`git-master`]
    - `git-master`: useful for safe host-layer wiring updates.
  - **Skills Evaluated but Omitted**:
    - `playwright`: app-host wiring task only.

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1
  - **Blocks**: 7, 13, 14, 15
  - **Blocked By**: 2

  **References**:
  - `Tester One/AppDelegate.swift:79` - current automation entrypoint.
  - `Tester One/AppDelegate.swift:108` - direct retry debug invocation to migrate.
  - `Tester One/AppDelegate.swift:133` - direct debug scrolling calls to migrate.

  **Acceptance Criteria**:
  - [ ] AppDelegate no longer directly calls legacy `debug_*` APIs.
  - [ ] Automation still generates state snapshots in Documents folder.

  **QA Scenarios**:
  ```
  Scenario: Host automation still captures expected snapshots
    Tool: Bash (run app with env vars)
    Preconditions: harness migration complete; simulator booted
    Steps:
      1. Launch app with BETA_TEST_STATE_AUTOMATION=1.
      2. Wait for run + retry automation sequence.
      3. Assert expected png files are created in state-verify-inapp directory.
    Expected Result: required screenshots exist with non-zero file size.
    Failure Indicators: missing files, empty images, automation abort.
    Evidence: .sisyphus/evidence/task-3-automation-snapshots.txt

  Scenario: Module remains free from host env parsing
    Tool: Bash (grep)
    Preconditions: migration complete
    Steps:
      1. grep BetaTest module for ProcessInfo/env automation keys.
      2. Assert zero matches.
    Expected Result: host automation logic stays outside module.
    Evidence: .sisyphus/evidence/task-3-module-boundary-grep.txt
  ```

  **Evidence to Capture**:
  - [ ] snapshot file listing
  - [ ] boundary grep output

  **Commit**: YES
  - Message: `refactor(host): route BetaTest automation through harness seam`
  - Files: `Tester One/AppDelegate.swift` (+ seam adapter file if needed)
  - Pre-commit: debug build + automation snapshot run

- [ ] 4. Clean anchor-constraint activation noise (`.compactMap { $0 }`)

  **What to do**:
  - Remove unnecessary `.compactMap { $0 }` from `NSLayoutConstraint.activate` arrays in BetaTest VC and cell.
  - Keep anchor structure unchanged; this is readability and correctness-noise cleanup only.

  **Must NOT do**:
  - Do not alter constraint constants, anchors, or hierarchy behavior.
  - Do not introduce layout DSL/frameworks.

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: low-risk micro-refactor in two files.
  - **Skills**: []
  - **Skills Evaluated but Omitted**:
    - `frontend-ui-ux`: no design change needed.

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1
  - **Blocks**: 6, 8, 9, 10
  - **Blocked By**: None

  **References**:
  - `Tester One/BetaTest/BetaTestViewController.swift:480` - constraint activation array currently ends with compactMap.
  - `Tester One/BetaTest/BetaTestViewController.swift:505` - unnecessary optional compaction call.
  - `Tester One/BetaTest/BetaTestCollectionViewCell.swift:584` - same pattern in cell setup.
  - `Tester One/BetaTest/BetaTestCollectionViewCell.swift:618` - cleanup target.

  **Acceptance Criteria**:
  - [ ] Both files activate constraints without `.compactMap { $0 }`.
  - [ ] Layout rendering behavior remains unchanged.

  **QA Scenarios**:
  ```
  Scenario: Constraint cleanup compiles and renders normally
    Tool: Bash (xcodebuild)
    Preconditions: compactMap cleanup applied
    Steps:
      1. Build Debug configuration.
      2. Launch automation flow once.
      3. Confirm no Auto Layout runtime warnings in logs.
    Expected Result: build passes and no new constraint warnings are emitted.
    Evidence: .sisyphus/evidence/task-4-constraint-cleanup.txt

  Scenario: Anchor hierarchy remains intact
    Tool: Bash (grep + runtime log scan)
    Preconditions: same build
    Steps:
      1. Verify expected anchor setup methods still exist.
      2. Scan run logs for "Unable to simultaneously satisfy constraints".
    Expected Result: no unsatisfiable-constraint warnings.
    Evidence: .sisyphus/evidence/task-4-no-autolayout-conflicts.txt
  ```

  **Evidence to Capture**:
  - [ ] build log snippet
  - [ ] runtime log scan

  **Commit**: YES
  - Message: `refactor(layout): remove unnecessary constraint compactMap`
  - Files: `Tester One/BetaTest/BetaTestViewController.swift`, `Tester One/BetaTest/BetaTestCollectionViewCell.swift`
  - Pre-commit: debug build

- [ ] 5. Reconcile documentation drift with current 2-column module behavior

  **What to do**:
  - Update stale docs still referencing `singleColumnBreakpoint` or 1-column fallback.
  - Align module docs with actual public surface and portability constraints.
  - Document that host automation remains host-owned, not module contract.

  **Must NOT do**:
  - Do not add speculative roadmap sections unrelated to this refactor.
  - Do not leave contradictory statements between docs.

  **Recommended Agent Profile**:
  - **Category**: `writing`
    - Reason: documentation consistency and precision task.
  - **Skills**: []
  - **Skills Evaluated but Omitted**:
    - `playwright`: documentation-only.

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1
  - **Blocks**: 13, 15
  - **Blocked By**: None

  **References**:
  - `docs/BetaTestAdaptiveMosaicPlan.md:25` - stale 1-column fallback language.
  - `docs/BetaTestModule.md` - source of module contract and internals statements.
  - `docs/BetaTestOptimizationRecord.md` - chronology and rationale baseline.

  **Acceptance Criteria**:
  - [ ] No stale 1-column behavior references remain.
  - [ ] Docs consistently describe current module architecture and host boundaries.

  **QA Scenarios**:
  ```
  Scenario: Stale 1-column references removed
    Tool: Bash (grep)
    Preconditions: docs updated
    Steps:
      1. grep docs for "singleColumnBreakpoint" and "1-column fallback".
      2. Assert zero matches.
    Expected Result: no stale terms remain.
    Evidence: .sisyphus/evidence/task-5-docs-grep-stale-terms.txt

  Scenario: Module contract consistency check
    Tool: Bash (grep)
    Preconditions: docs updated
    Steps:
      1. Verify docs mention current public APIs.
      2. Verify host automation is documented as host-side concern.
    Expected Result: consistent language across docs.
    Evidence: .sisyphus/evidence/task-5-docs-contract-consistency.txt
  ```

  **Evidence to Capture**:
  - [ ] stale-term grep output
  - [ ] contract consistency check output

  **Commit**: YES
  - Message: `docs(betatest): align mosaic and module contract documentation`
  - Files: `docs/BetaTestAdaptiveMosaicPlan.md`, `docs/BetaTestModule.md`, `docs/BetaTestOptimizationRecord.md`
  - Pre-commit: docs grep checks

- [ ] 6. Simplify non-visible reload path by removing deferred queue complexity

  **What to do**:
  - Replace `pendingReloadIndexPaths` + scheduled flush pattern with a simpler, safer reload mechanism.
  - Keep visible-cell transitions animated; keep non-visible updates correct.
  - Ensure no invalid index-path reloads occur under mutation.

  **Must NOT do**:
  - Do not regress state correctness for non-visible items.
  - Do not introduce full `reloadData()` in hot loop if item-specific reload is sufficient.

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: behavior-sensitive internal simplification.
  - **Skills**: []
  - **Skills Evaluated but Omitted**:
    - `frontend-ui-ux`: no visual redesign.

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2
  - **Blocks**: 15
  - **Blocked By**: 4

  **References**:
  - `Tester One/BetaTest/BetaTestViewController.swift:272` - reload queue state storage.
  - `Tester One/BetaTest/BetaTestViewController.swift:741` - enqueue path.
  - `Tester One/BetaTest/BetaTestViewController.swift:754` - flush batching path.
  - `Tester One/BetaTest/BetaTestViewController.swift:771` - batch update reload call.

  **Acceptance Criteria**:
  - [ ] Deferred queue structures are removed or reduced to minimal coalescing.
  - [ ] Non-visible item state updates still reflect correctly when cells reappear.

  **QA Scenarios**:
  ```
  Scenario: Non-visible states synchronize after scroll back
    Tool: Playwright
    Preconditions: app launched to BetaTest screen with enough items to scroll
    Steps:
      1. Scroll to bottom so top cells are offscreen.
      2. Trigger processing/retry flow affecting offscreen items.
      3. Scroll back to top and assert updated state badges/colors for affected cells.
    Expected Result: reappearing cells show latest state; no stale visual state.
    Failure Indicators: stale retry enabled/disabled or incorrect status indicator.
    Evidence: .sisyphus/evidence/task-6-offscreen-state-sync.png

  Scenario: Reload simplification does not trigger invalid update crash
    Tool: Bash (runtime log)
    Preconditions: stress run with repeated state transitions
    Steps:
      1. Run automation flow repeatedly.
      2. Monitor logs for invalid collection update exceptions.
    Expected Result: zero invalid update exceptions.
    Evidence: .sisyphus/evidence/task-6-reload-stability.txt
  ```

  **Evidence to Capture**:
  - [ ] offscreen resync screenshot
  - [ ] stability log output

  **Commit**: YES
  - Message: `refactor(betatest): simplify non-visible reload synchronization`
  - Files: `Tester One/BetaTest/BetaTestViewController.swift`
  - Pre-commit: debug build + automation flow run

- [ ] 7. Remove focus telemetry arrays and reduce debug-only tracking noise

  **What to do**:
  - Remove `focusAttemptedIndexes` and `focusScrolledIndexes` storage where only used for telemetry/testing.
  - Keep user-facing focus behavior functional (scroll-to-item logic) without telemetry accumulation.
  - Update debug/test hooks to avoid dependency on internal arrays.

  **Must NOT do**:
  - Do not remove focus-follow behavior itself unless explicitly scoped.
  - Do not break retry/processing sequencing while removing telemetry writes.

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: targeted removal of non-essential state.
  - **Skills**: []
  - **Skills Evaluated but Omitted**:
    - `playwright`: used for QA, not implementation.

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2
  - **Blocks**: 14, 15
  - **Blocked By**: 2, 3

  **References**:
  - `Tester One/BetaTest/BetaTestViewController.swift:270` - focus telemetry arrays.
  - `Tester One/BetaTest/BetaTestViewController.swift:916` - attempted index append.
  - `Tester One/BetaTest/BetaTestViewController.swift:935` - scrolled index append.
  - `Tester OneTests/BetaTest/BetaTestViewControllerTests.swift:195` - tests currently asserting telemetry counts.

  **Acceptance Criteria**:
  - [ ] Telemetry arrays are removed or replaced with minimal debug counters.
  - [ ] Focus behavior still scrolls when needed during long processing runs.

  **QA Scenarios**:
  ```
  Scenario: Focus-follow still scrolls to processing item
    Tool: Playwright
    Preconditions: long item list available
    Steps:
      1. Start processing from top.
      2. Observe progression as active item moves offscreen.
      3. Assert collection scrolls to keep active item visible.
    Expected Result: automatic focus-follow behavior remains functional.
    Evidence: .sisyphus/evidence/task-7-focus-follow-happy.png

  Scenario: Removing telemetry does not break processing flow
    Tool: Bash (runtime logs)
    Preconditions: telemetry code removed
    Steps:
      1. Run full processing + retry cycle.
      2. Assert run reaches finished state without exceptions.
    Expected Result: no runtime errors related to removed tracking arrays.
    Evidence: .sisyphus/evidence/task-7-focus-telemetry-removal.txt
  ```

  **Evidence to Capture**:
  - [ ] focus-follow screenshot
  - [ ] runtime flow log

  **Commit**: YES
  - Message: `refactor(betatest): remove focus telemetry state noise`
  - Files: `Tester One/BetaTest/BetaTestViewController.swift` (+ test references if migrated)
  - Pre-commit: debug build

- [ ] 8. Simplify ViewController measurement cache layering

  **What to do**:
  - Reduce `cachedRowMeasurements` and `cachedMosaicMeasurements` complexity to a simpler strategy (single cache scope or on-demand calculation path).
  - Keep Dynamic Type and width-change correctness.
  - Ensure cache invalidation events are explicit and minimal.

  **Must NOT do**:
  - Do not remove all measurement performance control in one step.
  - Do not regress card height correctness for multiline titles.

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: sizing correctness and performance-sensitive logic.
  - **Skills**: []
  - **Skills Evaluated but Omitted**:
    - `frontend-ui-ux`: no styling change.

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2
  - **Blocks**: 10, 15
  - **Blocked By**: 4

  **References**:
  - `Tester One/BetaTest/BetaTestViewController.swift:280` - row cache definition.
  - `Tester One/BetaTest/BetaTestViewController.swift:286` - mosaic cache definition.
  - `Tester One/BetaTest/BetaTestViewController.swift:1026` - row height measurement path.
  - `Tester One/BetaTest/BetaTestViewController.swift:1118` - mosaic measurement preparation path.

  **Acceptance Criteria**:
  - [ ] Cache layering is reduced with clear invalidation triggers.
  - [ ] Height calculations remain stable across width and content-size changes.

  **QA Scenarios**:
  ```
  Scenario: Multiline cards keep stable heights after simplification
    Tool: Playwright
    Preconditions: long titles present in list
    Steps:
      1. Open BetaTest screen in portrait.
      2. Capture card heights at top/middle/bottom.
      3. Rotate simulator and capture again.
      4. Return to portrait and compare expected consistency.
    Expected Result: no collapsed/overlapping cards; heights adapt consistently.
    Evidence: .sisyphus/evidence/task-8-height-stability.png

  Scenario: Dynamic type change invalidates measurements safely
    Tool: Playwright
    Preconditions: accessibility text size toggled between normal and large
    Steps:
      1. Launch app with default text size.
      2. Re-launch with larger content size category.
      3. Assert card text wraps and height updates without clipping.
    Expected Result: no text clipping or truncated layout caused by stale cache.
    Evidence: .sisyphus/evidence/task-8-dynamic-type-cache-invalid.txt
  ```

  **Evidence to Capture**:
  - [ ] rotation comparison screenshots
  - [ ] dynamic type verification log/screenshot

  **Commit**: YES
  - Message: `refactor(betatest): simplify measurement cache layering`
  - Files: `Tester One/BetaTest/BetaTestViewController.swift`
  - Pre-commit: debug build + orientation/dynamic-type checks

- [ ] 9. Simplify `BetaTestCollectionViewCell` preferred-height cache strategy

  **What to do**:
  - Remove or significantly reduce static `preferredHeightCache` complexity.
  - Keep sizing-cell measurement path intact for Auto Layout correctness.
  - If caching is retained, bound it and tie invalidation to explicit signals only.

  **Must NOT do**:
  - Do not remove multiline self-sizing support.
  - Do not introduce thread-unsafe sizing behavior.

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: cell sizing and trait-driven behavior are fragile.
  - **Skills**: []
  - **Skills Evaluated but Omitted**:
    - `playwright`: implementation-side not required.

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2
  - **Blocks**: 10, 11, 15
  - **Blocked By**: 4

  **References**:
  - `Tester One/BetaTest/BetaTestCollectionViewCell.swift:33` - preferred height entrypoint.
  - `Tester One/BetaTest/BetaTestCollectionViewCell.swift:225` - cache key type.
  - `Tester One/BetaTest/BetaTestCollectionViewCell.swift:260` - static cache store.
  - `Tester One/BetaTest/BetaTestCollectionViewCell.swift:76` - cache size threshold logic.

  **Acceptance Criteria**:
  - [ ] Preferred-height cache complexity is reduced without layout regressions.
  - [ ] Memory warning path still clears any retained sizing cache state.

  **QA Scenarios**:
  ```
  Scenario: Repeated list relayout remains stable without heavy static cache
    Tool: Playwright
    Preconditions: app with mixed short/long titles
    Steps:
      1. Open screen and perform 10 rapid scroll up/down cycles.
      2. Assert no card overlap or jittering cell heights.
      3. Capture final screenshot of top/mid sections.
    Expected Result: visual layout stays stable under repeated relayout.
    Evidence: .sisyphus/evidence/task-9-scroll-relayout-stability.png

  Scenario: Memory warning handling clears retained sizing state safely
    Tool: Bash + simulator control logs
    Preconditions: build running in simulator
    Steps:
      1. Trigger simulated memory warning.
      2. Revisit list and force relayout via rotation/scroll.
      3. Assert no crash and layout still correct.
    Expected Result: safe recovery after memory warning.
    Evidence: .sisyphus/evidence/task-9-memory-warning-recovery.txt
  ```

  **Evidence to Capture**:
  - [ ] relayout stability screenshot
  - [ ] memory warning recovery log

  **Commit**: YES
  - Message: `refactor(betatest): streamline preferred-height caching`
  - Files: `Tester One/BetaTest/BetaTestCollectionViewCell.swift`
  - Pre-commit: debug build + relayout checks

- [ ] 10. Simplify adaptive mosaic tuning and layout invalidation/cache flow

  **What to do**:
  - Reduce tuning branch complexity between controller profile logic and layout engine.
  - Keep 2-column policy; remove stale or redundant tuning knobs where practical.
  - Tighten invalidation behavior to avoid broad cache churn when targeted invalidation is enough.

  **Must NOT do**:
  - Do not reintroduce 1-column fallback behavior.
  - Do not break current card placement correctness.

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: custom collection layout behavior is algorithmic and regression-prone.
  - **Skills**: []
  - **Skills Evaluated but Omitted**:
    - `frontend-ui-ux`: visual language is unchanged.

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2
  - **Blocks**: 15
  - **Blocked By**: 8, 9

  **References**:
  - `Tester One/BetaTest/BetaTestViewController.swift:562` - profile application entrypoint.
  - `Tester One/BetaTest/BetaTestViewController.swift:601` - profile generation branches.
  - `Tester One/BetaTest/BetaTestAdaptiveMosaicLayout.swift:35` - prepare/cache lifecycle.
  - `Tester One/BetaTest/BetaTestAdaptiveMosaicLayout.swift:168` - invalidation triggers.
  - Apple guidance: `UICollectionViewLayoutInvalidationContext` usage for targeted recomputation.

  **Acceptance Criteria**:
  - [ ] Tuning/invalidation logic is measurably simpler (fewer mutable knobs/branches).
  - [ ] 2-column adaptive behavior remains correct across screen sizes.

  **QA Scenarios**:
  ```
  Scenario: Mosaic layout remains correct after tuning simplification
    Tool: Playwright
    Preconditions: mixed card title lengths and states
    Steps:
      1. Open BetaTest screen on small-width simulator.
      2. Scroll through full list and capture representative sections.
      3. Repeat on wider simulator.
      4. Assert no overlapping frames and stable two-column rhythm.
    Expected Result: valid layout on both narrow and wide screens.
    Evidence: .sisyphus/evidence/task-10-mosaic-layout-widths.png

  Scenario: Layout invalidation is targeted and stable
    Tool: Bash (runtime logs)
    Preconditions: instrumentation/logging for invalidation path enabled
    Steps:
      1. Trigger bounds-width change (rotation).
      2. Trigger non-width state changes.
      3. Assert invalidation occurs for expected reasons only.
    Expected Result: no excessive full-cache invalidation loops.
    Evidence: .sisyphus/evidence/task-10-invalidation-behavior.txt
  ```

  **Evidence to Capture**:
  - [ ] multi-device mosaic screenshots
  - [ ] invalidation behavior log

  **Commit**: YES
  - Message: `refactor(betatest): simplify adaptive mosaic tuning and invalidation`
  - Files: `Tester One/BetaTest/BetaTestViewController.swift`, `Tester One/BetaTest/BetaTestAdaptiveMosaicLayout.swift`
  - Pre-commit: debug build + multi-width layout checks

- [ ] 11. Simplify fallback image caching and memory warning cleanup path

  **What to do**:
  - Reassess `fallbackImageCache` usage and reduce unnecessary global retained state.
  - Keep icon fallback correctness for iOS 12 (asset fallback when SF Symbols unavailable).
  - Ensure memory warning cleanup remains explicit and minimal.

  **Must NOT do**:
  - Do not break icon rendering on iOS 12 asset path.
  - Do not remove memory warning cleanup hook if cache remains.

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: focused resource-state simplification.
  - **Skills**: []
  - **Skills Evaluated but Omitted**:
    - `playwright`: only needed for post-change verification.

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3
  - **Blocks**: 15
  - **Blocked By**: 9

  **References**:
  - `Tester One/BetaTest/BetaTestCollectionViewCell.swift:244` - asset fallback map.
  - `Tester One/BetaTest/BetaTestCollectionViewCell.swift:259` - fallback cache store.
  - `Tester One/BetaTest/BetaTestCollectionViewCell.swift:694` - cache lookup path.
  - `Tester One/BetaTest/BetaTestViewController.swift:414` - memory warning observer callback.

  **Acceptance Criteria**:
  - [ ] Fallback icon behavior remains correct for all icon types.
  - [ ] Cache/memory warning path is simpler and free of unnecessary global retention.

  **QA Scenarios**:
  ```
  Scenario: iOS 12 fallback icons render for all card types
    Tool: Playwright
    Preconditions: run app in iOS 12-compatible simulator runtime if available
    Steps:
      1. Open BetaTest and enumerate visible card icons.
      2. Scroll through all cards.
      3. Assert each icon view has non-empty rendered image.
    Expected Result: no missing icons across entire list.
    Evidence: .sisyphus/evidence/task-11-fallback-icons.png

  Scenario: Memory warning does not break icon rendering
    Tool: Bash + simulator control logs
    Preconditions: app running
    Steps:
      1. Trigger memory warning.
      2. Scroll through list to force icon re-resolution.
      3. Assert no blank icons or crashes.
    Expected Result: icon fallback remains stable after warning.
    Evidence: .sisyphus/evidence/task-11-memory-warning-icons.txt
  ```

  **Evidence to Capture**:
  - [ ] icon coverage screenshot
  - [ ] memory warning recovery output

  **Commit**: YES
  - Message: `refactor(betatest): streamline fallback image cache behavior`
  - Files: `Tester One/BetaTest/BetaTestCollectionViewCell.swift`, `Tester One/BetaTest/BetaTestViewController.swift`
  - Pre-commit: debug build + icon verification pass

- [ ] 12. Run iOS 12/latest availability and theme compatibility hardening pass

  **What to do**:
  - Audit all BetaTest `#available(iOS 13.0, *)` branches for correctness and minimality.
  - Preserve iOS 12 fallback behavior in nav appearance, indicator style, icon strategy, and dynamic color fallback.
  - Ensure safe area anchor usage remains canonical (no deprecated top/bottom guide regressions).

  **Must NOT do**:
  - Do not remove fallback branches required for iOS 12.
  - Do not add deprecated APIs as compatibility shortcuts.

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: compatibility-sensitive cross-file audit.
  - **Skills**: []
  - **Skills Evaluated but Omitted**:
    - `frontend-ui-ux`: not a visual redesign task.

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3
  - **Blocks**: 15
  - **Blocked By**: 1

  **References**:
  - `Tester One/BetaTest/BetaTestViewController.swift:441` - navigation bar appearance branch.
  - `Tester One/BetaTest/BetaTestCollectionViewCell.swift:321` - activity indicator style branch.
  - `Tester One/BetaTest/BetaTestCollectionViewCell.swift:676` - SF Symbol with fallback branch.
  - `Tester One/BetaTest/BetaTestTheme.swift:76` - dynamic color helper fallback logic.

  **Acceptance Criteria**:
  - [ ] Availability branches are minimal, valid, and justified.
  - [ ] iOS 12 fallback and latest iOS behavior both remain functional.

  **QA Scenarios**:
  ```
  Scenario: iOS 12 compatibility path executes without unsupported API usage
    Tool: Bash (xcodebuild)
    Preconditions: availability audit complete
    Steps:
      1. Build app with deployment target set to iOS 12 baseline.
      2. Scan build output for availability errors/warnings.
      3. Assert build succeeds.
    Expected Result: no unsupported API compile/runtime issues.
    Evidence: .sisyphus/evidence/task-12-ios12-availability-build.txt

  Scenario: Latest iOS path still applies modern appearance correctly
    Tool: Playwright
    Preconditions: run on latest simulator
    Steps:
      1. Launch BetaTest screen.
      2. Assert nav bar and card status visuals are applied as expected.
      3. Capture screenshot for evidence.
    Expected Result: modern path remains visually and functionally intact.
    Evidence: .sisyphus/evidence/task-12-latest-ios-appearance.png
  ```

  **Evidence to Capture**:
  - [ ] iOS12 build log
  - [ ] latest iOS screenshot

  **Commit**: YES
  - Message: `fix(betatest): harden iOS12 and latest-iOS availability paths`
  - Files: `Tester One/BetaTest/BetaTestViewController.swift`, `Tester One/BetaTest/BetaTestCollectionViewCell.swift`, `Tester One/BetaTest/BetaTestTheme.swift`
  - Pre-commit: debug + release build

- [ ] 13. Enforce portability boundaries in module config and host responsibilities

  **What to do**:
  - Ensure module defaults/config remain host-injectable and not host-app coupled.
  - Keep environment parsing and screenshot automation in host layer only.
  - Document localization/default-string strategy clearly (host can override via `Screen` and `Item` config).

  **Must NOT do**:
  - Do not hardcode host-specific runtime behavior into BetaTest internals.
  - Do not silently change public config types in breaking ways.

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: boundary and contract-sensitive integration cleanup.
  - **Skills**: []
  - **Skills Evaluated but Omitted**:
    - `playwright`: boundary verification happens via grep/build checks.

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3
  - **Blocks**: 15
  - **Blocked By**: 3, 5

  **References**:
  - `Tester One/BetaTest/BetaTestModule.swift` - module factory entrypoint to preserve.
  - `Tester One/BetaTest/BetaTestModuleConfiguration.swift` - host-facing override points for screen/item text.
  - `Tester One/AppDelegate.swift` - host-owned automation and env parsing should remain here.
  - `docs/BetaTestModule.md` - public contract documentation anchor.

  **Acceptance Criteria**:
  - [ ] Module code does not parse host automation environment variables.
  - [ ] Public configuration remains compatible and host override paths are explicit.

  **QA Scenarios**:
  ```
  Scenario: Module remains host-neutral by source scan
    Tool: Bash (grep)
    Preconditions: portability pass completed
    Steps:
      1. grep BetaTest module for AppDelegate/env automation symbols.
      2. Assert zero coupling matches.
    Expected Result: module contains no host runtime coupling patterns.
    Evidence: .sisyphus/evidence/task-13-host-neutral-grep.txt

  Scenario: Host-provided labels override defaults correctly
    Tool: Playwright
    Preconditions: app launched with custom screen/item labels via config
    Steps:
      1. Launch BetaTest with non-default `Screen` titles.
      2. Assert nav title and continue button titles match host input.
    Expected Result: host overrides are reflected correctly.
    Evidence: .sisyphus/evidence/task-13-host-config-overrides.png
  ```

  **Evidence to Capture**:
  - [ ] host-neutral grep output
  - [ ] override verification screenshot

  **Commit**: YES
  - Message: `refactor(betatest): enforce host-neutral module boundaries`
  - Files: `Tester One/BetaTest/*`, `docs/BetaTestModule.md`, `Tester One/AppDelegate.swift` (if needed)
  - Pre-commit: debug build + boundary grep

- [ ] 14. Remove legacy `debug_*` APIs and dead references after seam migration

  **What to do**:
  - Remove legacy debug methods from `BetaTestViewController` once harness and host/test migration are complete.
  - Remove dead call sites and stale references in host/tests/docs.
  - Keep debug functionality only through the new seam where required.

  **Must NOT do**:
  - Do not remove methods before all callers are migrated.
  - Do not leave dangling compile references.

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: targeted cleanup with strict reference checks.
  - **Skills**: [`git-master`]
    - `git-master`: useful for safe deletion and reference verification.
  - **Skills Evaluated but Omitted**:
    - `playwright`: implementation phase only.

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3
  - **Blocks**: 15
  - **Blocked By**: 2, 3, 7

  **References**:
  - `Tester One/BetaTest/BetaTestViewController.swift:155` - legacy debug API block.
  - `Tester OneTests/BetaTest/BetaTestViewControllerTests.swift` - debug references requiring migration/removal.
  - `Tester OneTests/BetaTest/BetaTestModuleTests.swift` - debug references requiring migration/removal.
  - `Tester One/AppDelegate.swift:108` - direct debug caller previously migrated.

  **Acceptance Criteria**:
  - [ ] Legacy `debug_*` methods are removed from module internals.
  - [ ] No remaining references to removed debug API names across repo.

  **QA Scenarios**:
  ```
  Scenario: No legacy debug method references remain
    Tool: Bash (grep)
    Preconditions: cleanup complete
    Steps:
      1. grep repository for debug_runPhase/debug_triggerRetry/debug_scrollTo* patterns.
      2. Assert no matches (or only explicitly allowed harness docs).
    Expected Result: legacy API names are fully removed from runtime codepaths.
    Evidence: .sisyphus/evidence/task-14-debug-reference-purge.txt

  Scenario: App still builds after debug API removal
    Tool: Bash (xcodebuild)
    Preconditions: references migrated
    Steps:
      1. Build Debug configuration.
      2. Assert build success and no unresolved symbol errors.
    Expected Result: compile succeeds with no dangling references.
    Evidence: .sisyphus/evidence/task-14-build-after-removal.txt
  ```

  **Evidence to Capture**:
  - [ ] reference grep output
  - [ ] build success log

  **Commit**: YES
  - Message: `refactor(betatest): remove legacy debug api surface`
  - Files: `Tester One/BetaTest/BetaTestViewController.swift` + migrated callers
  - Pre-commit: repo grep + debug build

- [ ] 15. Execute full agent QA run and collect final evidence bundle

  **What to do**:
  - Run complete verification suite for build, boundaries, docs, and automation artifacts.
  - Collect evidence files for each prior task scenario in `.sisyphus/evidence/`.
  - Produce a concise QA manifest mapping scenario -> evidence file.

  **Must NOT do**:
  - Do not mark tasks complete without evidence artifacts.
  - Do not rely on manual-only validation statements.

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: cross-cutting end-to-end verification and artifact auditing.
  - **Skills**: [`playwright`]
    - `playwright`: required for deterministic UI interaction and screenshot evidence.
  - **Skills Evaluated but Omitted**:
    - `frontend-ui-ux`: no design changes required.

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 3 terminal gate
  - **Blocks**: F1, F2, F3, F4
  - **Blocked By**: 1, 3, 5, 6, 7, 10, 11, 12, 13, 14

  **References**:
  - `run-tests.sh` - existing project validation script reference (tests not acceptance-gated, but infra context).
  - `Tester One/AppDelegate.swift:186` - snapshot output directory behavior.
  - `docs/BetaTestModule.md` and `docs/BetaTestAdaptiveMosaicPlan.md` - documentation alignment checks.
  - `.sisyphus/evidence/` - required artifact destination.

  **Acceptance Criteria**:
  - [ ] Debug and Release builds pass.
  - [ ] Deployment target output is consistent.
  - [ ] Module boundary grep is clean.
  - [ ] Docs stale-term grep is clean.
  - [ ] Required automation screenshots exist and are non-empty.
  - [ ] QA manifest is written under evidence directory.

  **QA Scenarios**:
  ```
  Scenario: Full verification command suite passes
    Tool: Bash
    Preconditions: all prior tasks completed
    Steps:
      1. Run Debug + Release builds.
      2. Run deployment target grep check.
      3. Run module boundary grep check.
      4. Run docs stale-term grep check.
    Expected Result: all checks return pass conditions.
    Evidence: .sisyphus/evidence/task-15-verification-suite.txt

  Scenario: Automation screenshots produced in expected directory
    Tool: Bash + Playwright
    Preconditions: BETA_TEST_STATE_AUTOMATION flow available
    Steps:
      1. Launch app with automation env.
      2. Wait for state transitions to complete.
      3. Assert presence of required PNG snapshots.
    Expected Result: all required screenshot files exist and are non-zero.
    Evidence: .sisyphus/evidence/task-15-snapshot-artifacts.txt
  ```

  **Evidence to Capture**:
  - [ ] verification suite output
  - [ ] snapshot artifact listing
  - [ ] QA manifest file

  **Commit**: NO
  - Message: N/A (verification task)
  - Files: `.sisyphus/evidence/*`
  - Pre-commit: N/A

---

## Final Verification Wave (MANDATORY)

- [ ] F1. **Plan Compliance Audit** — `oracle`
  - Verify every Must Have/Must NOT Have against implemented artifacts.
  - Validate evidence files exist for all task scenarios.
  - Output: `Must Have [N/N] | Must NOT Have [N/N] | Tasks [N/N] | VERDICT`.

- [ ] F2. **Code Quality Review** — `unspecified-high`
  - Run strict build checks; scan for anti-patterns and dead debug leftovers.
  - Output: `Build [PASS/FAIL] | Warnings [count] | Issues [count] | VERDICT`.

- [ ] F3. **Real QA Scenario Replay** — `unspecified-high`
  - Re-run all task QA scenarios from a clean state and validate evidence.
  - Output: `Scenarios [N/N pass] | Integration [PASS/FAIL] | VERDICT`.

- [ ] F4. **Scope Fidelity Check** — `deep`
  - Verify no unplanned changes; ensure all scoped refactors were executed.
  - Output: `Tasks [N/N compliant] | Scope Creep [NONE/DETAILS] | VERDICT`.

---

## Commit Strategy

| After Task Group | Message | Files | Verification |
|------------------|---------|-------|--------------|
| Wave 1 | `refactor(betatest): establish seam and baseline constraints` | BetaTest + AppDelegate + docs + pbxproj | Debug/Release build |
| Wave 2 | `refactor(betatest): simplify caches reload and layout tuning` | BetaTest internals | Build + automation artifacts |
| Wave 3 | `refactor(betatest): finalize portability and remove legacy debug paths` | BetaTest + docs + host wiring | Full QA evidence pass |

---

## Success Criteria

### Verification Commands
```bash
xcodebuild -project "Tester One.xcodeproj" -scheme "Tester One" -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build
xcodebuild -project "Tester One.xcodeproj" -scheme "Tester One" -configuration Release -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build
xcodebuild -project "Tester One.xcodeproj" -scheme "Tester One" -showBuildSettings | grep IPHONEOS_DEPLOYMENT_TARGET
grep -R "singleColumnBreakpoint\|1-column fallback" "docs/BetaTestAdaptiveMosaicPlan.md" "docs/BetaTestModule.md"
grep -R "BETA_TEST_STATE_AUTOMATION\|ProcessInfo.processInfo.environment\|AppDelegate" "Tester One/BetaTest"
```

### Final Checklist
- [ ] All Must Have conditions present.
- [ ] All Must NOT Have conditions absent.
- [ ] Debug and Release builds pass on simulator.
- [ ] Deployment targets are policy-consistent.
- [ ] All QA evidence artifacts are present under `.sisyphus/evidence/`.
