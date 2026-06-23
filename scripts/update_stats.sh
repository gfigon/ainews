#!/bin/bash
# Update dynamic counters in index.qmd (article count, last update date).
# Idempotent. Run before `quarto render`.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INDEX="$ROOT/index.qmd"
POSTS_DIR="$ROOT/posts"

if [ ! -f "$INDEX" ]; then
  echo "ERROR: $INDEX not found" >&2
  exit 1
fi

# Count posts (directories starting with YYYY-MM-DD).
article_count=$(find "$POSTS_DIR" -maxdepth 1 -mindepth 1 -type d \
  -regextype posix-extended -regex '.*/[0-9]{4}-[0-9]{2}-[0-9]{2}-.*' \
  | wc -l)

# Most recent post timestamp (date field) - read from frontmatter of latest post.
latest_date=$(find "$POSTS_DIR" -maxdepth 2 -name 'index.qmd' -printf '%T@ %p\n' \
  | sort -nr | head -1 | cut -d' ' -f2)
if [ -n "$latest_date" ] && [ -f "$latest_date" ]; then
  date_line=$(grep -m1 '^date:' "$latest_date" | sed -E 's/^date:[[:space:]]*"?//; s/"$//')
  update_stamp="UPDATED ${date_line}"
else
  update_stamp="UPDATED $(date -u '+%Y-%m-%d %H:%M UTC')"
fi

# Replace tokens in index.qmd.  Pattern matches Quarto span syntax:
#   [[ [NNN ARTICLES]{.rad-bracket-inner} ]]{.rad-bracket}
python3 - "$INDEX" "$article_count" "$update_stamp" <<'PY'
import re, sys
path, count, stamp = sys.argv[1], sys.argv[2], sys.argv[3]
text = open(path, encoding='utf-8').read()
# Match the whole bracketed span:  [[ [INNER]{.rad-bracket-inner} ]]{.rad-bracket}
pat = re.compile(r"\[\[\s*\[([^\]]*?)\]\s*\{\.rad-bracket-inner\}\s*]]\{\.rad-bracket\}")
def sub(m):
    inner = m.group(1).strip()
    if inner.endswith("ARTICLES") or re.match(r"^\d+\s+ARTICLES", inner):
        return f"[[ [{count} ARTICLES]{{.rad-bracket-inner}} ]]{{.rad-bracket}}"
    if inner.startswith("UPDATED"):
        return f"[[ [{stamp}]{{.rad-bracket-inner}} ]]{{.rad-bracket}}"
    return m.group(0)
text = pat.sub(sub, text)
open(path, 'w', encoding='utf-8').write(text)
PY

echo "Updated stats: ${article_count} articles, ${update_stamp}"
