# Responsiveness Budget (UIKit)

## Goal
Keep interactions responsive by controlling main-thread workload.

## Practical budgets
- Keep scroll callbacks O(1) and allocation-light.
- Avoid heavy formatting/parsing in `cellForRow`/`cellForItem`.
- Avoid repeated layout invalidation in hot interaction loops.

## Hot-path audit
- `scrollViewDidScroll`
- `viewDidLayoutSubviews`
- list cell configuration methods
- animation completion chains

## Mitigations
- Cache expensive measurements and formatters.
- Move decoding/parsing to background queues.
- Threshold-gate UI toggles.
- Use targeted updates over global refresh.

## Verification
- Time Profiler: identify expensive call stacks.
- Core Animation: watch dropped frames under stress scenarios.
- Manual stress: fast scroll + repeated retry/action taps.

## Checklist
- [ ] No heavy sync work in hot callbacks
- [ ] Performance-critical screens profiled after major UI changes
- [ ] Regression checks included in PR notes
