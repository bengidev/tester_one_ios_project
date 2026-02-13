# Tester One Refactor Plan

## Phase 1 — Scope Focus (completed)
- [x] Confirm active app entry flow (`BetaTestViewController`) and baseline build health.
- [x] Quarantine legacy DeviceTest path from app target without deleting source files.
- [x] Validate CLI build succeeds (no simulator app launch).
- [x] Validate test target compile path succeeds.

## Phase 2 — Sequential Chain Execution + Cell Customization
- [x] Replace batch processing with chain/sequential processing per cell.
- [x] Add per-item customization model (`BetaTestItem.Content` + `BetaTestItem.RunPlan`).
- [x] Add per-item update APIs in `BetaTestViewController`.
- [x] Simplify lifecycle callbacks into one event callback (`onProcessingEvent`) for chain actions.
- [x] Improve state transitions to feel smooth on visible cells (non-snappy).
- [x] Refactor execution engine into singular path (`executeItem`) used by both sequential run and retry.
- [x] Add per-cell execution function support through item initialization (`executionHandler`).
- [ ] Beng manual UI validation on device/simulator.
- [ ] Tune per-cell timings and visuals after manual feedback.
- [x] Keep a single lifecycle callback surface (`onProcessingEvent`) and avoid redundant completion hooks.
- [x] Remove temporary debug/demo execution logic from `defaultItems()` (`static var` counters, print-based behavior).

## Phase 3 — BetaTest Modularization Replan (for future extraction)
- [ ] Define BetaTest public API surface (minimal host-facing types only).
- [ ] Introduce `BetaTestModuleConfiguration` as a single entry config object.
- [ ] Replace direct closure sprawl with one host delegate/event stream contract.
- [ ] Move execution behavior wiring to injectable protocol (`BetaTestExecutionProviding`).
- [ ] Add factory entrypoint (`BetaTestModule.makeViewController(configuration:)`).
- [ ] Isolate internal UI/state types as `internal` to avoid API leakage.
- [ ] Remove AppDelegate debug print wiring; switch to sample integration block.
- [ ] Add module-level docs (`docs/BetaTestModule.md`) with integration examples.
- [ ] Add contract tests for module API behavior from host perspective.
- [ ] Run build + unit tests + manual UI validation as release gate.
