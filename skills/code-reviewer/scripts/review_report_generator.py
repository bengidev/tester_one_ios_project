#!/usr/bin/env python3
"""review_report_generator.py

Generates a simple Markdown review report by combining:
- git diff stats (via pr_analyzer)
- quality scan counts (via code_quality_checker)

Usage:
  python3 scripts/review_report_generator.py [--base origin/main] [--target .] [--out REVIEW_REPORT.md]
"""

import argparse
import json
import subprocess
from datetime import datetime
from pathlib import Path


def run(cmd: list[str]) -> str:
    return subprocess.check_output(cmd, text=True, stderr=subprocess.STDOUT)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", default=None)
    ap.add_argument("--target", default=".")
    ap.add_argument("--out", default="REVIEW_REPORT.md")
    args = ap.parse_args()

    here = Path(__file__).resolve().parent
    pr_analyzer = here / "pr_analyzer.py"
    quality = here / "code_quality_checker.py"

    pr_cmd = ["python3", str(pr_analyzer), "--json"] + (["--base", args.base] if args.base else [])
    q_cmd = ["python3", str(quality), args.target]

    pr = json.loads(run(pr_cmd))
    q_out = run(q_cmd).strip().splitlines()

    ts = datetime.now().isoformat(timespec="seconds")
    md = []
    md.append(f"# Review Report\n\nGenerated: {ts}\n")
    md.append("## Diff summary\n")
    md.append(f"- Files changed: {pr['files_changed']}\n")
    md.append(f"- Lines: +{pr['lines_added']} / -{pr['lines_deleted']}\n")
    md.append("\nTop changed files:\n")
    for f in pr["files"][:15]:
        md.append(f"- `{f['path']}` (+{f['added']} / -{f['deleted']})\n")

    md.append("\n## Automated scan\n")
    md.append("```\n" + "\n".join(q_out[:50]) + "\n```\n")

    md.append("\n## Reviewer checklist\n")
    md.append("- [ ] Correctness: edge cases + error handling\n")
    md.append("- [ ] Concurrency/threading (if applicable)\n")
    md.append("- [ ] Security: inputs, authz, secrets, logging PII\n")
    md.append("- [ ] Performance hot paths\n")
    md.append("- [ ] Tests added/updated + CI green\n")

    out_path = Path(args.out)
    out_path.write_text("".join(md), encoding="utf-8")
    print(f"Wrote {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
