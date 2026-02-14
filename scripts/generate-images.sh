#!/bin/bash
# Generate SVG images for all posts

POSTS_DIR="/home/skutek/projekty/ainews/posts"
OUTPUT_DIR="$POSTS_DIR"

# Colors for different categories
declare -A colors=(
  ["LLMs & Models"]="#6366f1"
  ["AI Tools & Frameworks"]="#10b981"
  ["Agents & Automation"]="#f59e0b"
  ["AI Security & Safety"]="#ef4444"
  ["Ethics & Regulation"]="#8b5cf6"
  ["Industry News"]="#3b82f6"
  ["Research Highlights"]="#ec4899"
)

get_color() {
  local category="$1"
  for key in "${!colors[@]}"; do
    if [[ "$category" == *"$key"* ]]; then
      echo "${colors[$key]}"
      return
    fi
  done
  echo "#6366f1" # default
}

# Process each post
for post_dir in $POSTS_DIR/2026-02-*; do
  if [ -d "$post_dir" ]; then
    slug=$(basename "$post_dir")
    
    # Get title from index.qmd
    title=$(grep "^title:" "$post_dir/index.qmd" | sed 's/title: *"\(.*\)"/\1/' | head -1)
    
    # Get first category
    category=$(grep "^categories:" "$post_dir/index.qmd" | sed 's/.*\[\(.*\)\].*/\1/' | head -1 | cut -d',' -f1)
    
    # Get color for category
    color=$(get_color "$category")
    
    # Generate slug for filename
    slug_filename=$(echo "$slug" | sed 's/2026-02-[0-9]*-//')
    
    # Create SVG
    cat > "$post_dir/image.svg" << EOF
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="512" viewBox="0 0 1024 512">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#1e1e2e"/>
      <stop offset="100%" style="stop-color:#2d2d44"/>
    </linearGradient>
  </defs>
  <rect width="1024" height="512" fill="url(#bg)"/>
  <rect x="40" y="40" width="944" height="432" rx="20" fill="none" stroke="$color" stroke-width="3" opacity="0.3"/>
  <text x="512" y="220" font-family="Arial, sans-serif" font-size="42" font-weight="bold" fill="white" text-anchor="middle">ROBO AI DIGEST</text>
  <text x="512" y="280" font-family="Arial, sans-serif" font-size="24" fill="$color" text-anchor="middle">$category</text>
  <text x="512" y="340" font-family="Arial, sans-serif" font-size="18" fill="#a0a0b0" text-anchor="middle" max-width="900">
EOF

    # Wrap long title
    title_words=($title)
    line=""
    for word in "${title_words[@]}"; do
      if [ ${#line} -lt 60 ]; then
        line="$line $word"
      else
        echo "    <tspan x=\"512\" dy=\"24\">$line</tspan>" >> "$post_dir/image.svg"
        line="$word"
      fi
    done
    if [ -n "$line" ]; then
      echo "    <tspan x=\"512\" dy=\"24\">$line</tspan>" >> "$post_dir/image.svg"
    fi

    cat >> "$post_dir/image.svg" << EOF
  </text>
  <text x="512" y="480" font-family="Arial, sans-serif" font-size="14" fill="#606080" text-anchor="middle">roboaidigest.com</text>
</svg>
EOF

    echo "Generated: $slug/image.svg"
  fi
done

echo "Done!"
