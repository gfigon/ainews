#!/bin/bash
# Generate improved SVG images for all posts with icons and keywords

POSTS_DIR="/home/skutek/projekty/ainews/posts"

# Colors for categories
get_color() {
  local category="$1"
  case "$category" in
    *LLMs*|*Models*) echo "#6366f1" ;;
    *Tools*|*Framework*) echo "#10b981" ;;
    *Agents*|*Automation*) echo "#f59e0b" ;;
    *Security*|*Safety*) echo "#ef4444" ;;
    *Ethics*|*Regulation*) echo "#8b5cf6" ;;
    *Industry*) echo "#3b82f6" ;;
    *Research*) echo "#ec4899" ;;
    *) echo "#6366f1" ;;
  esac
}

# Extract main keyword from title
get_keyword() {
  local title="$1"
  echo "$title" | sed 's/.*: *//' | awk '{print $1}' | tr -d '"\''
}

for post_dir in $POSTS_DIR/2026-02-*; do
  if [ -d "$post_dir" ]; then
    slug=$(basename "$post_dir")
    
    # Get title
    title=$(grep "^title:" "$post_dir/index.qmd" | sed 's/title: *"\(.*\)"/\1/' | head -1)
    keyword=$(get_keyword "$title")
    
    # Get first category
    category=$(grep "^categories:" "$post_dir/index.qmd" | sed 's/.*\[\(.*\)\].*/\1/' | head -1 | cut -d',' -f1)
    color=$(get_color "$category")
    
    # Truncate title for display
    display_title=$(echo "$title" | cut -c1-55)
    if [ ${#title} -gt 55 ]; then
      display_title="$display_title..."
    fi
    
    # Create SVG with large keyword
    cat > "$post_dir/image.svg" << EOFSVG
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="512" viewBox="0 0 1024 512">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#1a1a2e"/>
      <stop offset="100%" style="stop-color:#16213e"/>
    </linearGradient>
  </defs>
  <rect width="1024" height="512" fill="url(#bg)"/>
  
  <!-- Large keyword -->
  <text x="512" y="200" font-family="Arial Black, Arial" font-size="120" font-weight="bold" fill="$color" text-anchor="middle" opacity="0.15">$keyword</text>
  
  <!-- Icon circle -->
  <circle cx="512" cy="180" r="60" fill="$color"/>
  <text x="512" y="200" font-size="40" fill="white" text-anchor="middle" font-family="Arial">AI</text>
  
  <!-- Title -->
  <text x="512" y="320" font-family="Arial" font-size="28" font-weight="bold" fill="white" text-anchor="middle" max-width="900">$display_title</text>
  
  <!-- Category -->
  <text x="512" y="360" font-family="Arial" font-size="18" fill="$color" text-anchor="middle">$category</text>
  
  <!-- Date and site -->
  <text x="512" y="400" font-family="Arial" font-size="14" fill="#888" text-anchor="middle">$(echo $slug | cut -d'-' -f1,2,3) - roboaidigest.com</text>
  
  <!-- Bottom line -->
  <rect x="100" y="440" width="824" height="2" fill="$color" opacity="0.5"/>
</svg>
EOFSVG

    echo "Generated: $slug"
  fi
done

echo "Done!"
