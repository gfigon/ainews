#!/usr/bin/env python3
import os
import re
import glob

POSTS_DIR = "/home/skutek/projekty/ainews/posts"

for qmd_file in glob.glob(f"{POSTS_DIR}/*/index.qmd"):
    with open(qmd_file, 'r') as f:
        content = f.read()
    
    # Pattern to match markdown links: [text](url)
    # We want to add {rel="nofollow"} to external URLs (not roboaidigest.com)
    
    def add_nofollow(match):
        text = match.group(1)  # The full link [text](url)
        # Check if it's an internal link
        if 'roboaidigest.com' in text:
            return text
        # If already has rel=, don't add
        if 'rel=' in text:
            return text
        # Add {rel="nofollow"} before the closing ]
        # Transform [text](url) -> [text](url){rel="nofollow"}
        return text.replace(']', ']{rel="nofollow"}', 1)
    
    # Find all markdown links [...]
    # But we need to be careful not to match YAML links
    
    # Simple approach: replace ](https://...) with ... (only in lines not starting with spaces/tabs followed by href)
    # Actually, let's just process the whole file and look for patterns that look like markdown links
    
    # Better: Look for patterns: ](http...)] or ](https...)]
    # Replace with: ](http...){rel="nofollow"}]
    
    new_content = re.sub(r'\]\((https?://(?!roboaidigest)[^)]+)\)', r'](\1){rel="nofollow"}', content)
    
    if new_content != content:
        with open(qmd_file, 'w') as f:
            f.write(new_content)
        print(f"Updated: {qmd_file}")

print("Done!")
