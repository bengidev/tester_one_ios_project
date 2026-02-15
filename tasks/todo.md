# Tester One — BetaTest Execution Plan

## Stage 1 — Contract/API Freeze
- [x] Keep public module entrypoint via `BetaTestModule.makeViewController(configuration:executionProvider:)`.
- [x] Keep injectable `BetaTestExecutionProviding` for host integration.
- [x] Keep host callback surface centralized through `onProcessingEvent` (+ retry callback).
- [x] Add start-step event emission for host observability (`.stepStarted`).
- [x] Add/keep module contract tests.

## Stage 2 — State Machine Hardening
- [x] Keep item states bounded to `initial/loading/failed/success`.
- [x] Keep bottom button states bounded to `start/loading/finish` via run phase.
- [x] Guard invalid retry path when full run is processing.
- [ ] Add explicit transition-matrix tests (follow-up).

## Stage 3 — Deterministic Sequential Engine
- [x] Keep sequential processing run coordinator (`runID`) and stale completion rejection.
- [x] Emit `.stepStarted` + `.stepCompleted` in sequential order.
- [x] Add unit test proving `.stepStarted` event order is strictly ascending.
- [ ] Add dedicated no-overlap assertion test with controlled artificial delays.

## Stage 4 — Interaction Lock + Focus Follow
- [x] Continue button disabled while processing.
- [x] Block retry tap while processing to avoid parallel overlap.
- [x] Add active-item focus follow (`scrollToItem` centered) at execution start.
- [ ] Add UI-level focus-follow verification test.

## Stage 5 — Concept-Safe UI Parity
- [x] Preserve concept layout/composition (no structural layout redesign).
- [x] Keep state visuals mapped to initial/loading/failed/success.
- [ ] Snapshot parity rerun after implementation batch.

## Stage 6 — Non-Breaking Interface Optimization
- [x] Polish-only adjustments (typography/spacing/animation/readability) without changing layout structure.
- [x] Profile layout invalidation + cell sizing hot spots.
- [x] Tune for iOS 12-safe performance.

## Stage 7 — Integration Gate
- [x] End-to-end run pass (start → processing → finish).
- [x] Failure + retry path pass.
- [x] Host-implant checklist + docs update.

## Test Timing Policy (Execution-side only, not project default)
- [x] Use longer async test windows in execution verification when simulator is unstable.
- [x] Keep project defaults untouched unless explicitly approved.
