# Code Review Checklist

## Summary
- What does this change do?
- What’s the risk area (auth, data loss, concurrency, migrations, payments)?

## Correctness
- Handles errors (network failures, decoding errors, nils)
- Edge cases covered
- No race conditions / thread violations

## Maintainability
- Clear naming
- Functions small + focused
- Duplication avoided
- Comments explain *why*, not *what*

## Security & privacy
- Inputs validated/sanitized
- No secrets committed
- No PII in logs
- Authn/authz correct

## Performance
- Avoid unnecessary work in loops
- Avoid blocking main thread
- Caching where appropriate

## Tests
- Unit tests for logic
- UI tests for critical flows
- Regression tests added when fixing bugs
