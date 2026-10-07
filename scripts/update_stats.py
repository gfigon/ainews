#!/usr/bin/env python3
"""Update dynamic counters in index.qmd."""
import re
import subprocess
from pathlib import Path
from datetime import datetime

ROOT = Path("/home/skutek/projekty/ainews")
INDEX = ROOT / "index.qmd"
POSTS_DIR = ROOT / "posts"

# Count posts
result = subprocess.run(
    ["find", str(POSTS_DIR), "-maxdepth", "1", "-mindepth", "1", "-type", "d"],
    capture_output=True, text=True
)
article_count = len([d for d in result.stdout.strip().split("\n") if d])

# Get latest date
result2 = subprocess.run(
    ["find", str(POSTS_DIR), "-maxdepth", "2", "-name", "index.qmd", "-printf", "%T@ %p\n"],
    capture_output=True, text=True
)
lines = sorted(result2.stdout.strip().split("\n"), reverse=True)
if lines and lines[0]:
    latest_path = lines[0].split(" ")[1]
    result3 = subprocess.run(["grep", "-m1", "^date:", latest_path], capture_output=True, text=True)
    date_line = result3.stdout.strip().replace("date:", "").replace('"', "").strip()
    update_stamp = f"UPDATED {date_line}"
else:
    update_stamp = f"UPDATED {datetime.utcnow().strftime('%Y-%m-%d %H:%M UTC')}"

print(f"Article count: {article_count}")
print(f"Update stamp: {update_stamp}")

# Update index.qmd
text = INDEX.read_text(encoding="utf-8")
pat = re.compile(r"\[\[\s*\[([^\]]*?)\]\s*\{\.rad-bracket-inner\}\s*]]\{\.rad-bracket\}")
def sub(m):
    inner = m.group(1).strip()
    if inner.endswith("ARTICLES") or re.match(r"^\d+\s+ARTICLES", inner):
        return f"[[ [{article_count} ARTICLES]{{.rad-bracket-inner}} ]]{{.rad-bracket}}"
    if inner.startswith("UPDATED"):
        return f"[[ [{update_stamp}]{{.rad-bracket-inner}} ]]{{.rad-bracket}}"
    return m.group(0)
text = pat.sub(sub, text)
INDEX.write_text(text, encoding="utf-8")
print("Updated index.qmd")
