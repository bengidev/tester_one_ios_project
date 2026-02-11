# Instruments Playbook (UIKit)

## Goal
Make performance recommendations measurable and repeatable.

## Primary instruments
1. **Time Profiler**
   - Find CPU-heavy call stacks in hot paths.
2. **Core Animation**
   - Detect frame drops and rendering bottlenecks.

## Run plan
1. Launch screen in debug profile build.
2. Record baseline: idle + normal interaction.
3. Record stress: fast scroll + repeated actions/retries.
4. Compare before/after optimization.

## What to inspect
- Repeated expensive calls in `cellForRow/cellForItem`.
- Layout churn from frequent invalidation.
- Shadow/material rendering hotspots.

## Pass/fail heuristics
- Pass: local updates no longer trigger global churn.
- Pass: stress interaction remains visually smooth.
- Fail: broad reloads/invalidations still dominate traces.

## Checklist
- [ ] Baseline and post-change traces captured
- [ ] Hotspots identified and linked to code sections
- [ ] Regression guard notes added to PR
