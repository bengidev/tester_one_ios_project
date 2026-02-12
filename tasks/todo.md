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
