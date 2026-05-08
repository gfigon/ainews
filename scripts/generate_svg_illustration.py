#!/usr/bin/env python3
"""Generate robotic-terminal SVG illustrations for posts.

For each post passed (or auto-discovered as broken):
  1. Parse the YAML frontmatter to read title, categories, date, slug.
  2. Render a 1024x576 SVG matching the design-system aesthetic
     (phosphor-green on near-black, JetBrains Mono labels, bracket
     frame, category-tinted accent, large watermark keyword).
  3. Write to assets/post-images/<slug>.svg and rewrite the post's
     `image:` frontmatter field to point at the new asset.

Modes:
  --auto      Discover posts whose `image:` references a missing local
              file (paths starting with `/images/`, `/image/`, or
              `/posts/.../something.{jpg,png,svg}`) and generate for all.
  <post-dir>  Run for a single post directory (relative or absolute).
"""

from __future__ import annotations

import argparse
import hashlib
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
POSTS = ROOT / "posts"
OUT_DIR = ROOT / "assets" / "post-images"

# Category → accent color. Falls back to phosphor-green.
CATEGORY_COLOR = {
    "LLMs & Models": "#6ee7a3",
    "Industry News": "#f0b429",
    "Agents & Automation": "#d946ef",
    "Research & Innovation": "#58a6ff",
    "AI Infrastructure": "#fb923c",
    "AI Security & Policy": "#f85149",
    "AI Tools & Frameworks": "#4ade80",
}
DEFAULT_ACCENT = "#4ade80"
BG = "#0d1117"
SURFACE = "#161b22"
LINE = "#30363d"
FG = "#e6edf3"
FG_DIM = "#768390"

FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---\n", re.DOTALL)


def parse_frontmatter(text: str) -> dict | None:
    m = FRONTMATTER_RE.match(text)
    if not m:
        return None
    fm_raw = m.group(1)

    title = None
    date = None
    image = None
    categories: list[str] = []

    title_m = re.search(r'^title:\s*"?(.*?)"?\s*$', fm_raw, re.MULTILINE)
    if title_m:
        title = title_m.group(1).strip()
    date_m = re.search(r'^date:\s*"?(.*?)"?\s*$', fm_raw, re.MULTILINE)
    if date_m:
        date = date_m.group(1).strip()
    image_m = re.search(r'^image:\s*"?(.*?)"?\s*$', fm_raw, re.MULTILINE)
    if image_m:
        image = image_m.group(1).strip()

    # Categories: either inline `categories: ["A", "B"]` or YAML list.
    inline = re.search(r"^categories:\s*\[([^\]]*)\]", fm_raw, re.MULTILINE)
    if inline:
        for chunk in inline.group(1).split(","):
            v = chunk.strip().strip('"').strip("'")
            if v:
                categories.append(v)
    else:
        block = re.search(
            r"^categories:\s*\n((?:[ \t]+-[^\n]*\n?)+)", fm_raw, re.MULTILINE
        )
        if block:
            for line in block.group(1).splitlines():
                m2 = re.match(r"^\s*-\s*(.+?)\s*$", line)
                if m2:
                    v = m2.group(1).strip().strip('"').strip("'")
                    if v:
                        categories.append(v)

    return {
        "title": title or "",
        "date": date or "",
        "image": image,
        "categories": categories,
        "raw_frontmatter": fm_raw,
        "full_text": text,
    }


def pick_keyword(title: str) -> str:
    """Pick a short label to use as the dominant SVG glyph."""
    if not title:
        return "AI"
    cleaned = re.sub(r"[^\w\s\-]", " ", title)
    tokens = [t for t in cleaned.split() if t]
    # Prefer all-caps tokens with 2-8 chars (acronyms / brands).
    for t in tokens:
        if 2 <= len(t) <= 8 and t.isupper():
            return t
    # Else prefer the first token >= 4 chars, uppercased.
    for t in tokens:
        if len(t) >= 4 and t.lower() not in {"with", "from", "this", "that", "into"}:
            return t.upper()
    return tokens[0].upper() if tokens else "AI"


def accent_for(categories: list[str]) -> str:
    for c in categories:
        if c in CATEGORY_COLOR:
            return CATEGORY_COLOR[c]
    return DEFAULT_ACCENT


def short_date(date: str) -> str:
    m = re.match(r"(\d{4})-(\d{2})-(\d{2})", date)
    if not m:
        return ""
    return f"{m.group(1)}.{m.group(2)}.{m.group(3)}"


def hash_seed(slug: str, mod: int) -> int:
    return int(hashlib.md5(slug.encode("utf-8")).hexdigest(), 16) % mod


def render_svg(slug: str, title: str, categories: list[str], date: str) -> str:
    keyword = pick_keyword(title)
    accent = accent_for(categories)
    primary_cat = categories[0].upper() if categories else "AI DIGEST"
    date_str = short_date(date)

    # Watermark size: shrink for longer keywords so it always fits.
    wm_len = max(len(keyword), 1)
    wm_size = max(140, min(360, int(1024 * 0.95 / wm_len)))

    # Two pseudo-random circuit-line accents (deterministic per slug).
    grid_offset = hash_seed(slug, 40)

    title_text = title if len(title) <= 64 else title[:61] + "..."
    title_line1 = title_text
    title_line2 = ""
    if len(title_text) > 38:
        # Soft break at a word boundary near the middle.
        mid = len(title_text) // 2
        idx = title_text.rfind(" ", 0, mid + 8)
        if idx > 0:
            title_line1 = title_text[:idx]
            title_line2 = title_text[idx + 1 :]

    return f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 576" font-family="JetBrains Mono, ui-monospace, monospace">
  <defs>
    <pattern id="grid-{slug}" width="48" height="48" patternUnits="userSpaceOnUse" patternTransform="translate({grid_offset} {grid_offset})">
      <path d="M 48 0 L 0 0 0 48" fill="none" stroke="{LINE}" stroke-width="0.6" opacity="0.35"/>
    </pattern>
    <radialGradient id="vignette-{slug}" cx="50%" cy="0%" r="100%">
      <stop offset="0%" stop-color="{SURFACE}" stop-opacity="0.7"/>
      <stop offset="100%" stop-color="{BG}" stop-opacity="0"/>
    </radialGradient>
    <filter id="glow-{slug}" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur stdDeviation="6" result="blur"/>
      <feMerge>
        <feMergeNode in="blur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
  </defs>

  <rect width="1024" height="576" fill="{BG}"/>
  <rect width="1024" height="576" fill="url(#grid-{slug})"/>
  <rect width="1024" height="576" fill="url(#vignette-{slug})"/>

  <!-- Watermark keyword -->
  <text x="512" y="370" text-anchor="middle"
        font-size="{wm_size}" font-weight="800"
        fill="{accent}" opacity="0.10"
        letter-spacing="-0.04em">{keyword}</text>

  <!-- Bracket frame -->
  <g stroke="{accent}" stroke-width="2" fill="none">
    <path d="M 32 32 L 32 96 M 32 32 L 96 32"/>
    <path d="M 992 32 L 992 96 M 992 32 L 928 32"/>
    <path d="M 32 544 L 32 480 M 32 544 L 96 544"/>
    <path d="M 992 544 L 992 480 M 992 544 L 928 544"/>
  </g>

  <!-- Top metadata bar -->
  <g font-size="14" letter-spacing="0.12em" fill="{FG_DIM}" font-weight="500">
    <text x="56" y="64">&gt;_ ROBO_AI_DIGEST</text>
    <text x="968" y="64" text-anchor="end">{date_str}</text>
  </g>

  <!-- Title block -->
  <g fill="{FG}" font-weight="700">
    <text x="56" y="220" font-size="40" letter-spacing="-0.02em">{escape_xml(title_line1)}</text>
    {f'<text x="56" y="270" font-size="40" letter-spacing="-0.02em">{escape_xml(title_line2)}</text>' if title_line2 else ''}
  </g>

  <!-- Category badge -->
  <g transform="translate(56 320)">
    <rect x="0" y="0" width="{16 + len(primary_cat) * 11}" height="32"
          fill="{SURFACE}" stroke="{accent}" stroke-width="1" rx="2"/>
    <text x="{8 + (len(primary_cat) * 11) // 2 - 2}" y="21" text-anchor="middle"
          font-size="13" font-weight="700" letter-spacing="0.14em" fill="{accent}">{escape_xml(primary_cat)}</text>
  </g>

  <!-- Bottom-left tag with keyword -->
  <g transform="translate(56 504)" filter="url(#glow-{slug})">
    <text x="0" y="0" font-size="20" font-weight="700" fill="{accent}" letter-spacing="0.06em">// {keyword}_</text>
  </g>

  <!-- Bottom-right signature line -->
  <g font-size="12" fill="{FG_DIM}" letter-spacing="0.16em">
    <text x="968" y="528" text-anchor="end">SIGNAL OVER NOISE</text>
  </g>
</svg>
"""


def escape_xml(s: str) -> str:
    return (
        s.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
        .replace("'", "&apos;")
    )


def is_broken_local_image(image: str | None) -> bool:
    if not image:
        return False
    if image.startswith(("http://", "https://")):
        return False
    # Local path. Resolve against project root (leading slash → root).
    rel = image.lstrip("/")
    candidate = ROOT / rel
    return not candidate.exists()


def replace_image_field(text: str, new_image: str) -> str:
    """Replace `image:` field in the YAML frontmatter (preserves rest)."""
    m = FRONTMATTER_RE.match(text)
    if not m:
        return text
    fm = m.group(1)
    new_line = f'image: "{new_image}"'
    if re.search(r"^image:\s*.*$", fm, re.MULTILINE):
        new_fm = re.sub(r"^image:\s*.*$", new_line, fm, count=1, flags=re.MULTILINE)
    else:
        new_fm = fm.rstrip() + "\n" + new_line
    return text.replace(fm, new_fm, 1)


def process(post_dir: Path) -> tuple[bool, str]:
    qmd = post_dir / "index.qmd"
    if not qmd.exists():
        return False, f"no index.qmd in {post_dir}"
    fm = parse_frontmatter(qmd.read_text(encoding="utf-8"))
    if not fm:
        return False, f"no frontmatter in {qmd}"

    slug = post_dir.name
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out_path = OUT_DIR / f"{slug}.svg"
    svg = render_svg(slug, fm["title"], fm["categories"], fm["date"])
    out_path.write_text(svg, encoding="utf-8")

    new_image = f"/assets/post-images/{slug}.svg"
    new_text = replace_image_field(fm["full_text"], new_image)
    if new_text != fm["full_text"]:
        qmd.write_text(new_text, encoding="utf-8")
    return True, f"  + {out_path.relative_to(ROOT)}  ({fm['title'][:60]})"


def discover_broken() -> list[Path]:
    out: list[Path] = []
    for qmd in sorted(POSTS.glob("*/index.qmd")):
        fm = parse_frontmatter(qmd.read_text(encoding="utf-8"))
        if not fm:
            continue
        if is_broken_local_image(fm["image"]):
            out.append(qmd.parent)
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("post_dirs", nargs="*", type=Path)
    ap.add_argument(
        "--auto",
        action="store_true",
        help="Auto-discover posts whose image: points to a missing local file.",
    )
    args = ap.parse_args()

    targets: list[Path]
    if args.auto:
        targets = discover_broken()
        print(f"Discovered {len(targets)} posts with broken local image paths.")
    else:
        targets = [p if p.is_absolute() else (ROOT / p) for p in args.post_dirs]

    if not targets:
        print("Nothing to do. Pass --auto or one or more post directories.")
        return 0

    for d in targets:
        ok, msg = process(d)
        print(msg)

    return 0


if __name__ == "__main__":
    sys.exit(main())
