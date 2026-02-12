# Lessons — Tester One

## 2026-02-12

- Batch state updates across all cards make UI feel abrupt; chain/sequential updates are easier to follow and feel closer to real device checks.
- Keep per-cell behavior in the item model (`Content` + `RunPlan`) so one card can change without side effects to others.
- For transition quality, animate state changes inside the visible cell (`transitionCrossDissolve`) and avoid full-grid reloads during processing.
- Keep a controller-level fallback duration (`processDuration`) while allowing per-item overrides for real-world tuning.
- If two callbacks represent the same lifecycle, merge into one event callback with enum payload (`onProcessingEvent`) to reduce confusion.
- If initial run and retry share lifecycle logic, route both through one executor function (`executeItem`) to keep behavior consistent and easier to reason about.
- Put per-cell behavior as item-level execution handlers during `defaultItems` setup so each card owns its specific execution path.
- Once all cards own execution handlers, remove global default-state fallback logic (it becomes dead/ambiguous behavior).
- Even with event enums, a dedicated aggregate callback can reduce integration friction for consumers that only care about final results.
