#!/usr/bin/env python3
"""pr_analyzer.py

Lightweight PR/diff analyzer that works without external deps.
- Summarizes changed files/lines via `git diff --numstat`.
- Optionally outputs JSON.

Usage:
  python3 scripts/pr_analyzer.py [--base origin/main] [--json]
"""

import argparse
import json
import subprocess
import sys


def sh(cmd: list[str]) -> str:
    return subprocess.check_output(cmd, text=True, stderr=subprocess.STDOUT)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", default=None, help="Base ref to diff against (e.g. origin/main). Default: working tree vs HEAD")
    ap.add_argument("--json", action="store_true", help="Output JSON")
    args = ap.parse_args()

    if args.base:
        cmd = ["git", "diff", "--numstat", f"{args.base}..."]
    else:
        cmd = ["git", "diff", "--numstat"]

    try:
        out = sh(cmd).strip()
    except subprocess.CalledProcessError as e:
        print(e.output, file=sys.stderr)
        return 2

    files = []
    total_add = 0
    total_del = 0

    if out:
        for line in out.splitlines():
            add_s, del_s, path = line.split("\t", 2)
            add = 0 if add_s == "-" else int(add_s)
            dele = 0 if del_s == "-" else int(del_s)
            total_add += add
            total_del += dele
            files.append({"path": path, "added": add, "deleted": dele})

    result = {
        "files_changed": len(files),
        "lines_added": total_add,
        "lines_deleted": total_del,
        "files": sorted(files, key=lambda f: (f["added"] + f["deleted"]), reverse=True),
    }

    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print(f"Files changed: {result['files_changed']}")
        print(f"Lines: +{result['lines_added']}  -{result['lines_deleted']}")
        for f in result["files"][:25]:
            print(f"- {f['path']}: +{f['added']} -{f['deleted']}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
