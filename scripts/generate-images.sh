#!/bin/bash
# Generate improved SVG images for all posts with icons and keywords

POSTS_DIR="/home/skutek/projekty/ainews/posts"

# Generate unique color based on keyword hash
get_color() {
  local keyword="$1"
  # Hash the keyword to get a number, then pick from palette
  local hash=$(echo "$keyword" | md5sum | cut -c1-6)
  local num=$((16#$hash))
  
  # Vibrant color palette
  local colors=("#ff6b6b" "#4ecdc4" "#45b7d1" "#96ceb4" "#ffeaa7" 
               "#dfe6e9" "#fd79a8" "#a29bfe" "#00b894" "#e17055"
               "#74b9ff" "#81ecec" "#fab1a0" "#fdcb6e" "#e056fd"
               "#686de0" "#4834d4" "#130f40" "#2d3436" "#636e72"
               "#b2bec3" "#d63031" "#e84393" "#0984e3" "#00cec9"
               "#6c5ce7" "#ffeaa7" "#fab1a0" "#ff7675" "#fd79a8")
  
  local index=$((num % ${#colors[@]}))
  echo "${colors[$index]}"
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
    
    # Create SVG - large keyword background ONLY (no title text - not visible in thumbnails)
    printf '<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="512" viewBox="0 0 1024 512">
  <defs>
    <linearGradient id="bg" x1="0%%" y1="0%%" x2="100%%" y2="100%%">
      <stop offset="0%%" style="stop-color:#0f0f23"/>
      <stop offset="100%%" style="stop-color:#1a1a2e"/>
    </linearGradient>
  </defs>
  <rect width="1024" height="512" fill="url(#bg)"/>
  
  <!-- Large keyword as background watermark -->
  <text x="512" y="300" font-family="Arial Black, Arial" font-size="220" font-weight="bold" fill="%s" text-anchor="middle" opacity="0.25">%s</text>
  
  <!-- Keyword badge (centered, prominent) -->
  <rect x="362" y="200" width="300" height="50" rx="25" fill="%s" opacity="0.95"/>
  <text x="512" y="234" font-family="Arial" font-size="22" font-weight="bold" fill="white" text-anchor="middle">%s</text>
  
  <!-- Category -->
  <text x="512" y="320" font-family="Arial" font-size="14" fill="%s" text-anchor="middle">%s</text>
  
  <!-- Date and site -->
  <text x="512" y="360" font-family="Arial" font-size="14" fill="#666" text-anchor="middle">%s - roboaidigest.com</text>
  
  <!-- Bottom accent line -->
  <rect x="100" y="420" width="824" height="3" fill="%s"/>
</svg>' "$color" "$keyword" "$color" "$keyword" "$color" "$category" "$date_str" "$color" > "$post_dir/image.svg"

    echo "Generated: $slug (keyword: $keyword)"
  fi
done

echo "Done!"
