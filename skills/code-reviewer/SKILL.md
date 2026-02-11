---
name: code-reviewer
description: Comprehensive code review workflow for TypeScript, JavaScript, Python, Swift, Kotlin, and Go. Use when reviewing pull requests or local diffs, providing code feedback, identifying bugs/performance issues, checking best practices, security risks, and generating structured review checklists/reports. Includes scripts to analyze git diffs, scan for common issues, and output a review report.
---

# Code Reviewer

Use this skill to do **consistent, high-signal reviews** across languages.

## What to do (workflow)

1) **Scope the change**
- What’s the goal? What are the user-visible effects?
- Identify risk areas: auth, payments, data loss, concurrency, migrations.

2) **Run automated checks (optional but recommended)**
From repo root:
```bash
# 1) PR / diff analyzer
python3 scripts/pr_analyzer.py

# 2) Quality + security-ish scanner
python3 scripts/code_quality_checker.py . --verbose

# 3) Generate a markdown review report
python3 scripts/review_report_generator.py --out REVIEW_REPORT.md
```

3) **Manual review passes**
- Correctness: edge cases, error handling, race conditions.
- Architecture: boundaries, duplication, naming, testability.
- Security: input validation, secrets, logging PII, authz.
- Performance: hot paths, unnecessary work, N+1, allocation churn.
- UX (if UI): accessibility, loading/empty/error states.

## What to produce
- A short summary
- Blockers (must-fix)
- Suggestions (nice-to-have)
- Test plan (what you ran / what to run)

## References
- Checklist: `references/code_review_checklist.md`
- Coding standards workflow: `references/coding_standards.md`
- Common antipatterns: `references/common_antipatterns.md`
