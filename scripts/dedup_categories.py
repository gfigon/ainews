#!/usr/bin/env python3
"""Remove duplicate entries from each post's `categories:` YAML list.

Order is preserved (first occurrence kept). Whitespace and surrounding
quotes are normalized for comparison only — values are written back in
their original form when retained.

Idempotent. Safe to re-run.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
POSTS = ROOT / "posts"

FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---\n", re.DOTALL)


def dedupe_block(block: str) -> tuple[str, int]:
    """Return (rewritten_block, removed_count) for a `categories:` block.

    Handles two YAML shapes:
      categories:
        - Foo
        - Bar
        - Foo
    and inline flow:
      categories: ["Foo", "Bar", "Foo"]
    """
    inline = re.match(
        r"^(categories:\s*)\[(?P<items>[^\]]*)\]\s*$",
        block,
        re.MULTILINE,
    )
    if inline:
        prefix = inline.group(1)
        items_raw = inline.group("items")
        items = [s.strip() for s in items_raw.split(",") if s.strip()]
        seen, kept = set(), []
        for item in items:
            key = item.strip().strip('"').strip("'").lower()
            if key in seen:
                continue
            seen.add(key)
            kept.append(item)
        new_block = f'{prefix}[{", ".join(kept)}]'
        return new_block, len(items) - len(kept)

    lines = block.splitlines()
    if not lines or not lines[0].rstrip().endswith("categories:"):
        return block, 0

    out = [lines[0]]
    seen: set[str] = set()
    removed = 0
    for line in lines[1:]:
        m = re.match(r"^(\s*-\s*)(.*?)\s*$", line)
        if not m:
            out.append(line)
            continue
        value = m.group(2)
        key = value.strip().strip('"').strip("'").lower()
        if key in seen:
            removed += 1
            continue
        seen.add(key)
        out.append(line)
    return "\n".join(out), removed


def process_post(qmd: Path) -> int:
    text = qmd.read_text(encoding="utf-8")
    m = FRONTMATTER_RE.match(text)
    if not m:
        return 0
    fm = m.group(1)

    # Carve out the categories block — either inline or list form.
    inline_match = re.search(r"^categories:\s*\[[^\]]*\]\s*$", fm, re.MULTILINE)
    if inline_match:
        block = inline_match.group(0)
        new_block, removed = dedupe_block(block)
        if removed == 0:
            return 0
        new_fm = fm.replace(block, new_block)
    else:
        list_match = re.search(
            r"^categories:\s*\n((?:[ \t]+-[^\n]*\n?)+)",
            fm,
            re.MULTILINE,
        )
        if not list_match:
            return 0
        block = list_match.group(0).rstrip("\n")
        new_block, removed = dedupe_block(block)
        if removed == 0:
            return 0
        new_fm = fm.replace(block, new_block)

    new_text = text.replace(fm, new_fm, 1)
    if new_text != text:
        qmd.write_text(new_text, encoding="utf-8")
    return removed


def main() -> int:
    if not POSTS.is_dir():
        print(f"posts dir not found at {POSTS}", file=sys.stderr)
        return 1

    total_removed = 0
    posts_changed = 0
    for qmd in sorted(POSTS.glob("*/index.qmd")):
        removed = process_post(qmd)
        if removed:
            posts_changed += 1
            total_removed += removed
            print(f"  -{removed:>2}  {qmd.relative_to(ROOT)}")

    print(f"\nDeduplicated {total_removed} entries across {posts_changed} posts.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
