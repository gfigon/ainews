#!/usr/bin/env python3
"""Validate each post's `categories:` against the canonical 7-category list
defined in CATEGORIES.md.

Reports posts that use legacy or out-of-list categories. With --fix, applies
a best-effort mapping from known legacy categories to canonical ones.

Idempotent. Safe to re-run.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
POSTS = ROOT / "posts"
CATEGORIES_FILE = ROOT / "CATEGORIES.md"

# Canonical 7 categories, derived from CATEGORIES.md (mirrored here so the
# script doesn't have to parse Markdown).
CANONICAL: list[str] = [
    "LLMs & Models",
    "Industry News",
    "Agents & Automation",
    "Research & Innovation",
    "AI Infrastructure",
    "AI Security & Policy",
    "AI Tools & Frameworks",
]

# Best-effort mapping of legacy / off-list categories to canonical ones.
# Keep keys lowercase; matching is case-insensitive substring.
LEGACY_MAP: dict[str, str] = {
    "research highlights": "Research & Innovation",
    "research & academia": "Research & Innovation",
    "ai research & academia": "Research & Innovation",
    "ethics & regulation": "AI Security & Policy",
    "ai security & safety": "AI Security & Policy",
    "ai safety": "AI Security & Policy",
    "llms & models": "LLMs & Models",
    "agents & automation": "Agents & Automation",
    "industry news": "Industry News",
    "ai tools & frameworks": "AI Tools & Frameworks",
    "ai tools": "AI Tools & Frameworks",
    "ai infrastructure": "AI Infrastructure",
    "open source": "AI Tools & Frameworks",
    "startups": "Industry News",
    "funding": "Industry News",
    "hardware": "AI Infrastructure",
    "chips": "AI Infrastructure",
    "policy": "AI Security & Policy",
    "regulation": "AI Security & Policy",
    "robotics": "AI Infrastructure",
}

FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---\n", re.DOTALL)
CATEGORIES_RE = re.compile(r"^categories:\s*\[(.*?)\]\s*$", re.MULTILINE)
CATEGORIES_BLOCK_RE = re.compile(
    r"^categories:\s*\n((?:\s*-\s*.+\n)+)", re.MULTILINE
)


def parse_categories(block: str) -> list[str] | None:
    """Return list of categories from frontmatter block, or None if missing."""
    inline = CATEGORIES_RE.search(block)
    if inline:
        raw = inline.group(1)
        return [c.strip().strip("'\"") for c in raw.split(",") if c.strip()]
    block_match = CATEGORIES_BLOCK_RE.search(block)
    if block_match:
        items = re.findall(r"-\s*(.+)", block_match.group(1))
        return [i.strip().strip("'\"") for i in items if i.strip()]
    return None


def remap(category: str) -> str | None:
    """Return canonical category for a legacy one, or None if already canonical."""
    if category in CANONICAL:
        return None
    key = category.lower()
    if key in LEGACY_MAP:
        return LEGACY_MAP[key]
    for legacy, target in LEGACY_MAP.items():
        if legacy in key:
            return target
    return None


def process_post(post_dir: Path, fix: bool) -> tuple[str, list[str]]:
    """Return (status, categories_after) for a post directory.

    status: 'ok' | 'fixed' | 'invalid' | 'no-categories'
    """
    qmd = post_dir / "index.qmd"
    if not qmd.exists():
        return ("skip", [])
    text = qmd.read_text(encoding="utf-8")
    m = FRONTMATTER_RE.search(text)
    if not m:
        return ("skip", [])
    block = m.group(1)
    cats = parse_categories(block)
    if not cats:
        return ("no-categories", [])

    invalid = [c for c in cats if c not in CANONICAL]
    if not invalid:
        return ("ok", cats)

    if not fix:
        return ("invalid", cats)

    # Apply remap.
    new_cats: list[str] = []
    seen: set[str] = set()
    for c in cats:
        target = remap(c) or c
        if target not in seen:
            new_cats.append(target)
            seen.add(target)
    # Cap at 2 categories (project rule).
    new_cats = new_cats[:2]
    quoted = ", ".join(f'"{c}"' for c in new_cats)
    new_block = re.sub(
        r"^categories:.*$",
        f'categories: [{quoted}]',
        block,
        count=1,
        flags=re.MULTILINE,
    )
    new_text = text[: m.start(1)] + new_block + text[m.end(1) :]
    qmd.write_text(new_text, encoding="utf-8")
    return ("fixed", new_cats)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--fix",
        action="store_true",
        help="Apply best-effort remap of legacy categories to canonical ones.",
    )
    args = parser.parse_args()

    if not POSTS.exists():
        print(f"posts/ not found at {POSTS}", file=sys.stderr)
        return 1

    stats = {"ok": 0, "fixed": 0, "invalid": 0, "no-categories": 0, "skip": 0}
    issues: list[tuple[str, list[str]]] = []

    for post_dir in sorted(POSTS.iterdir()):
        if not post_dir.is_dir() or not post_dir.name.startswith("2"):
            continue
        status, cats = process_post(post_dir, args.fix)
        stats[status] = stats.get(status, 0) + 1
        if status == "invalid":
            issues.append((post_dir.name, cats))

    print("=" * 60)
    print(f"validate_categories  (fix={args.fix})")
    print("=" * 60)
    for k, v in stats.items():
        print(f"  {k:<16} {v}")
    if issues:
        print()
        print(f"Posts with off-list categories ({len(issues)}):")
        for slug, cats in issues:
            print(f"  - {slug}: {cats}")
        return 2 if not args.fix else 0
    return 0


if __name__ == "__main__":
    sys.exit(main())
