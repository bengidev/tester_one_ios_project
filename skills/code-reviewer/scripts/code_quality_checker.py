#!/usr/bin/env python3
"""code_quality_checker.py

Repo-local static-ish scanner. Not a replacement for real linters.
Finds common review issues:
- TODO/FIXME markers
- hardcoded secrets-ish patterns
- force unwraps in Swift (`!` after optional-ish symbols) (heuristic)
- print/debug logging left in

Usage:
  python3 scripts/code_quality_checker.py <target-path> [--verbose]
"""

import argparse
import os
import re
import sys


TEXT_EXT = {
    ".swift", ".m", ".mm", ".h", ".kt", ".kts", ".go", ".py", ".js", ".ts", ".tsx", ".jsx",
    ".json", ".yml", ".yaml", ".md", ".txt", ".toml",
}

SKIP_DIRS = {".git", ".derivedData", "DerivedData", "build", ".build", "Pods", "Carthage", "node_modules"}

PATTERNS = {
    "todo_fixme": re.compile(r"\b(TODO|FIXME|HACK)\b"),
    "secret": re.compile(r"(api[_-]?key|secret|token|password)\s*[:=]\s*['\"][^'\"]{8,}['\"]", re.IGNORECASE),
    "swift_force_unwrap": re.compile(r"[A-Za-z0-9_\)\]]!\b"),
    "debug_print": re.compile(r"\b(print\(|console\.log\(|NSLog\(|logger\.(debug|trace)\b)"),
}


def iter_files(root: str):
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for fn in filenames:
            ext = os.path.splitext(fn)[1]
            if ext in TEXT_EXT:
                yield os.path.join(dirpath, fn)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("target", help="Path to scan")
    ap.add_argument("--verbose", action="store_true")
    args = ap.parse_args()

    findings = []

    for path in iter_files(args.target):
        try:
            with open(path, "r", encoding="utf-8", errors="ignore") as f:
                for i, line in enumerate(f, start=1):
                    for key, rx in PATTERNS.items():
                        if rx.search(line):
                            findings.append({"kind": key, "path": path, "line": i, "text": line.strip()[:300]})
        except OSError:
            continue

    by_kind = {}
    for it in findings:
        by_kind.setdefault(it["kind"], 0)
        by_kind[it["kind"]] += 1

    print("Findings summary:")
    for k in sorted(by_kind.keys()):
        print(f"- {k}: {by_kind[k]}")

    if args.verbose:
        print("\nDetails:")
        for it in findings[:400]:
            rel = it["path"]
            print(f"[{it['kind']}] {rel}:{it['line']}  {it['text']}")

    # non-zero exit only if secrets found
    return 1 if by_kind.get("secret", 0) else 0


if __name__ == "__main__":
    raise SystemExit(main())
