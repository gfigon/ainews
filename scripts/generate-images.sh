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

# Extract main keyword from title - prefer company/model names
get_keyword() {
  local title="$1"
  # Remove subtitle after colon
  local main_title=$(echo "$title" | sed 's/:.*//')
  
  # Check for key terms (order matters - more specific first)
  echo "$main_title" | grep -qi "NVIDIA" && echo "NVIDIA" && return
  echo "$main_title" | grep -qi "Blackwell" && echo "Blackwell" && return
  echo "$main_title" | grep -qi "Anthropic" && echo "Anthropic" && return
  echo "$main_title" | grep -qi "Claude" && echo "Claude" && return
  echo "$main_title" | grep -qi "OpenAI" && echo "OpenAI" && return
  echo "$main_title" | grep -qi "GPT" && echo "GPT" && return
  echo "$main_title" | grep -qi "Google" && echo "Google" && return
  echo "$main_title" | grep -qi "DeepMind" && echo "DeepMind" && return
  echo "$main_title" | grep -qi "xAI" && echo "xAI" && return
  echo "$main_title" | grep -qi "Microsoft" && echo "Microsoft" && return
  echo "$main_title" | grep -qi "ByteDance" && echo "ByteDance" && return
  echo "$main_title" | grep -qi "Tesla" && echo "Tesla" && return
  echo "$main_title" | grep -qi "Apple" && echo "Apple" && return
  echo "$main_title" | grep -qi "Amazon" && echo "Amazon" && return
  echo "$main_title" | grep -qi "Meta" && echo "Meta" && return
  echo "$main_title" | grep -qi "Hugging Face" && echo "Hugging Face" && return
  echo "$main_title" | grep -qi "MiniMax" && echo "MiniMax" && return
  echo "$main_title" | grep -qi "Qwen" && echo "Qwen" && return
  
  # Otherwise skip common articles and take first meaningful word
  local first=$(echo "$main_title" | awk '{print $1}' | tr -d '"')
  case "$first" in
    The|A|An|How|This|What|New)
      echo "$main_title" | awk '{print $2}' | tr -d '"'
      ;;
    *)
      echo "$first"
      ;;
  esac
}

for post_dir in $POSTS_DIR/2026-02-*; do
  if [ -d "$post_dir" ]; then
    slug=$(basename "$post_dir")
    
    # Get title
    title=$(grep "^title:" "$post_dir/index.qmd" | sed 's/title: *"\(.*\)"/\1/' | head -1)
    keyword=$(get_keyword "$title")
    
    # Get first category - handle both inline [A, B] and list format
    category_block=$(grep -A3 "^categories:" "$post_dir/index.qmd" | head -4)
    if echo "$category_block" | grep -q '^\s*-'; then
      # List format: take first "- " value
      category=$(echo "$category_block" | grep '^\s*-' | head -1 | sed 's/.*-\s*"\([^"]*\)".*/\1/')
    else
      # Inline format: take first item before comma
      category=$(echo "$category_block" | sed 's/.*\[\(.*\)\].*/\1/' | cut -d',' -f1)
    fi
    # Trim whitespace
    category=$(echo "$category" | xargs)
    color=$(get_color "$category")
    
    # Truncate title for display (escape special chars)
    display_title=$(echo "$title" | sed "s/'//g" | cut -c1-55)
    if [ ${#title} -gt 55 ]; then
      display_title="$display_title..."
    fi
    
    # Date from slug
    date_str=$(echo "$slug" | cut -d'-' -f1,2,3)
    
    # Create SVG using printf to avoid bash parsing issues
    printf '<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="512" viewBox="0 0 1024 512">
  <defs>
    <linearGradient id="bg" x1="0%%" y1="0%%" x2="100%%" y2="100%%">
      <stop offset="0%%" style="stop-color:#1a1a2e"/>
      <stop offset="100%%" style="stop-color:#16213e"/>
    </linearGradient>
  </defs>
  <rect width="1024" height="512" fill="url(#bg)"/>
  
  <text x="512" y="200" font-family="Arial Black, Arial" font-size="120" font-weight="bold" fill="%s" text-anchor="middle" opacity="0.15">%s</text>
  
  <circle cx="512" cy="180" r="60" fill="%s"/>
  <text x="512" y="200" font-size="40" fill="white" text-anchor="middle" font-family="Arial">AI</text>
  
  <text x="512" y="320" font-family="Arial" font-size="28" font-weight="bold" fill="white" text-anchor="middle" max-width="900">%s</text>
  
  <text x="512" y="360" font-family="Arial" font-size="18" fill="%s" text-anchor="middle">%s</text>
  
  <text x="512" y="400" font-family="Arial" font-size="14" fill="#888" text-anchor="middle">%s - roboaidigest.com</text>
  
  <rect x="100" y="440" width="824" height="2" fill="%s" opacity="0.5"/>
</svg>' "$color" "$keyword" "$color" "$display_title" "$color" "$category" "$date_str" "$color" > "$post_dir/image.svg"

    echo "Generated: $slug (keyword: $keyword)"
  fi
done

echo "Done!"
