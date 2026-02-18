# BetaTest Optimization Record (2026-02-12 to 2026-02-16)

This document records the BetaTest optimization journey in chronological order so it is easy to explain to teammates/friends.

## 1) Scope and Constraints

- Module scope: `Tester One/BetaTest/`
- Platform constraint: iOS 12+ compatibility retained
- UX constraint: preserve existing card visuals, scaling behavior, and current interaction model
- Layout constraint (final): always 2-column mosaic on every screen size
- Verification baseline: `./run-tests.sh` must pass after each optimization batch

## 2) High-Level Timeline (from git history)

| Date | Commit | Theme |
|---|---|---|
| 2026-02-12 | `7b5a1f6` | Sequential per-cell processing introduced |
| 2026-02-12 | `4a5aa04` | Unified processing callbacks into event API |
| 2026-02-12 | `9c1145f` | Completion-driven per-cell execution contract |
| 2026-02-12 | `445a2f9` | Callback flow cleanup |
| 2026-02-12 | `445e7f8` | Execution continuation naming clarity |
| 2026-02-12 | `f08a0bb` | Removed demo/default execution behavior |
| 2026-02-13 | `8f1ede3` | Adaptive mosaic layout strategy added |
| 2026-02-13 | `42b2d45` | Adaptive mosaic threshold tuning |
| 2026-02-13 | `4e5c6ba` | BetaTest modularization + breakpoint verification |
| 2026-02-14 | `5485622` | Bottom button title visibility fix |
| 2026-02-15 | `5dc6fb9` | Stage execution pass + focus-follow + retry guard |
| 2026-02-15 | `6e6eeca` | Test destination resiliency |
| 2026-02-15 | `bab58d6` | Simulator run script resiliency |
| 2026-02-15 | `8974888` | Stage 5/6 pass + retry test coverage |
| 2026-02-15 | `ea8da91` | Mosaic height/expand decision caching |
| 2026-02-15 | `1b327b1` | Stage 7 integration gate + E2E docs/tests |
| 2026-02-15 | `168ae92` | Long dynamic-list smart-follow + focus telemetry |
| 2026-02-16 | `289d7d2` | Processing lock UX: disable retry and user scroll during run |
| 2026-02-16 | `64b7251` | Enforced 2-column mosaic only (removed 1-column code path) |

## 3) Optimization Narrative by Phase

### Phase A — Execution Flow Stabilization (2026-02-12)

**Problem:** Processing logic and callbacks were fragmented, making runtime behavior harder to reason about.

**What changed:**
- Processing moved to explicit sequential per-cell execution.
- Callback flow was consolidated around event-based processing.
- Per-cell execution contract became explicit: item handlers must complete through the continuation callback.

**Impact:**
- More deterministic test progression.
- Easier integration for host/app consumers.
- Lower risk of inconsistent behavior between initial run and retry run.

### Phase B — Adaptive Mosaic Foundations and Tuning (2026-02-13)

**Problem:** Static card layout did not adapt well across width/content-size variations.

**What changed:**
- Adaptive mosaic strategy introduced and tuned.
- Breakpoint and spacing behavior refined for smoother responsive rhythm.
- Module boundaries clarified for maintainability.

**Impact:**
- Better visual adaptability across device widths.
- Improved maintainability through clearer module shape.

### Phase C — Stage Progression, Caching, and Test Hardening (2026-02-14 to 2026-02-15)

**Problem:** Remaining runtime rough edges in progression/focus and potential recompute overhead in mosaic sizing.

**What changed:**
- Progression and focus-follow flow refined in staged passes.
- Mosaic measurement caching (`height` + `expand eligibility`) strengthened.
- Test and simulator scripts hardened for resilient CI/local runs.
- Stage 7 integration and E2E verification completed.

**Impact:**
- Lower recomputation overhead in adaptive layout decisions.
- More reliable test runs across environments.
- Better confidence from broader integration coverage.

### Phase D — Processing Interaction Locks + Deterministic Retry Outcome (2026-02-16, earlier)

**Problem:** During active processing, user interaction could interfere with automatic flow.

**What changed:**
- Retry button interaction is disabled during `.processing` and restored after run phase exits processing.
- User scroll interaction is disabled during `.processing` and restored afterward.
- Retry result path configured to fail for consistency testing scenarios.

**Impact:**
- Automatic run appears deterministic.
- Manual interference reduced during active execution.
- Easier consistency checks for retry behavior.

### Phase E — Hard Rule: Always 2-Column + Codepath Simplification (2026-02-16)

**Problem:** 1-column branch still existed in layout code, creating extra branching/maintenance burden.

**What changed:**
- Removed single-column breakpoint plumbing from `BetaTestViewController` profile model.
- Removed single-column branch from `BetaTestAdaptiveMosaicLayout.prepare()`.
- Layout now always computes 2 columns across all widths.

**Impact:**
- Behavior matches product requirement exactly (always 2-column).
- Less branch complexity inside layout pass.

## 4) Current Optimization Batch (this request)

### 4.1 Static Preferred-Height Cache for Sizing Cell

**File:** `Tester One/BetaTest/BetaTestCollectionViewCell.swift`

**Before:**
- `preferredHeight(for:title:traitCollection:)` always executed offscreen Auto Layout sizing (`systemLayoutSizeFitting`).

**After:**
- Added `PreferredHeightCacheKey` keyed by:
  - rounded width (2 decimals),
  - `UIContentSizeCategory`,
  - title text.
- Added `preferredHeightCache` lookup before sizing.
- Added cache population after measurement and safety clear when cache grows past threshold.
- `clearFallbackImageCache()` now also clears preferred-height cache on memory warning path.

**Why this matters:**
- Avoids repeated Auto Layout measurement for identical width/title/type-size combinations.
- Reduces CPU cost in mosaic/grid measurement flows.

### 4.2 Batched Reload for Non-Visible Cell State Updates

**File:** `Tester One/BetaTest/BetaTestViewController.swift`

**Before:**
- Non-visible state updates used repeated per-item `reloadItems` calls.

**After:**
- Added pending reload queue (`Set<IndexPath>`) and scheduled flush.
- Added `reloadItemsInBatch(_:)` with one `performBatchUpdates` reload pass.
- `updateAllItemStates(_:)` now:
  - transitions visible cells directly,
  - collects non-visible index paths,
  - reloads non-visible cells in one batch.
- `updateItemState` now enqueues non-visible reloads instead of immediate one-by-one reload.

**Why this matters:**
- Reduces collection reload churn and layout invalidation bursts.
- Preserves visible animation behavior while reducing background update overhead.

### 4.3 Retry Interaction Re-Sync on Cell Reappearance (post-batch fix)

**Files:**
- `Tester One/BetaTest/BetaTestViewController.swift`

**Issue observed manually:**
- After processing finished, item 0 could remain untappable on retry when it returned as failed.

**Root cause:**
- Retry interaction lock/unlock was only applied to currently visible cells.
- When a cell (especially item 0) left the viewport during processing and later reappeared, its retry button could keep stale `isUserInteractionEnabled = false`.

**Fix applied:**
- Added `collectionView(_:willDisplay:forItemAt:)` hook to re-apply current retry interaction state whenever any cell becomes visible.
- This ensures offscreen->onscreen cells always sync with controller-level `isRetryInteractionEnabled`.

**Why this matters:**
- Removes a stale-state edge case without changing visual behavior or run flow.
- Keeps retry interaction deterministic after auto-scroll driven processing.

### 4.4 De-Optimization and Portability Cleanup (2026-02-18)

**Problem:**
- The module carried optimization layers that were no longer justified for a small, portable feature surface.
- Debug helper methods were directly consumed by host automation and tests, creating module-boundary leakage.

**What changed:**
- Removed static preferred-height cache complexity from `BetaTestCollectionViewCell` while keeping sizing-cell Auto Layout measurement.
- Removed deferred non-visible reload queue complexity in `BetaTestViewController` and kept direct, validated reload behavior.
- Removed focus telemetry arrays and simplified related debug/testing hooks through a dedicated debug harness seam.
- Simplified mosaic tuning profile branching and moved to a smaller adaptive configuration pass.
- Normalized deployment target drift in project settings to align with iOS 12 baseline expectations.

**Impact:**
- Lower maintenance burden and fewer invalidation edge cases.
- Cleaner host/module boundaries for standalone BetaTest reuse.
- Preserved visible flow semantics with simpler internal control paths.

### 4.5 Contract Simplification + Resource Ownership Shift (2026-02-18)

**Problem:**
- Generic icon contract (`iconAssetName`) and split status asset params created ambiguity for host integrators.
- State-specific visual intent (initial/failed/success) was not explicit at API level.

**What changed:**
- Removed generic `iconAssetName` from module-facing DTOs.
- Added explicit state icon inputs in item configuration:
  - `initialIconAssetName`
  - `failedIconAssetName`
  - `successIconAssetName`
- Kept single generic `statusAssetName` for trailing status badge customization.
- Updated cell icon resolution to follow explicit state precedence and fallback between provided state assets.
- Updated failed-state UI visibility rule so retry badge and status badge cannot overlap.

**Impact:**
- Host-side API is clearer: module users control resource semantics directly per state.
- Better production readiness for teams replacing placeholder assets with branded resources.
- Reduced confusion during module onboarding and integration.

## 5) Verification Record

- Local verification command: `./run-tests.sh`
- Latest result for this batch: passed (`** TEST SUCCEEDED **`, `✅ Tests completed!`)
- Note: SourceKit diagnostics in this shell may report `No such module 'UIKit'`, while Xcode build/test pipeline compiles and passes through `xcodebuild`.
- For the post-batch retry-interaction re-sync fix, simulator validation was intentionally skipped by request; manual validation is expected by the owner.

## 6) How to Explain This to Others (simple script)

1. We first stabilized BetaTest execution to be deterministic and callback-driven per item.
2. Then we improved adaptive mosaic behavior and caching to reduce unnecessary recompute.
3. Next, we locked interaction during processing so auto-run cannot be disturbed.
4. Then we enforced a strict always-2-column rule and removed dead 1-column logic.
5. Finally, we simplified over-optimized internals so the module is easier to transplant and maintain.

## 7) Remaining Low-Risk Opportunities

- Add lightweight signposts (`os_signpost`) around `prepare()` and cell sizing for measured profiling.
- Add explicit benchmark notes for long-list behavior on older devices (iOS 12-compatible simulator/device runs).
