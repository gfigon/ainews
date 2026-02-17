#!/bin/bash
# Generate AI images for all posts using Pollinations.ai with the new key

POSTS_DIR="/home/skutek/projekty/ainews/posts"
API_KEY="sk_c5MZ0yAvD2AbZZZldOkDGbn9PIGVc5SC"

# Extract main keyword from title - prefer company/model names
get_keyword() {
  local title="$1"
  # Remove subtitle after colon
  local main_title=$(echo "$title" | sed 's/:.*//')
  
  # Check for key terms
  echo "$main_title" | grep -qi "NVIDIA" && echo "NVIDIA" && return
  echo "$main_title" | grep -qi "Blackwell" && echo "Blackwell" && return
  echo "$main_title" | grep -qi "Anthropic" && echo "Anthropic" && return
  echo "$main_title" | grep -qi "Claude" && echo "Claude" && return
  echo "$main_title" | grep -qi "OpenAI" && echo "OpenAI" && return
  echo "$main_title" | grep -qi "GPT" && echo "GPT" && return
  echo "$main_title" | grep -qi "Google" && echo "Google" && return
  echo "$main_title" | grep -qi "xAI" && echo "xAI" && return
  echo "$main_title" | grep -qi "Grok" && echo "Grok" && return
  echo "$main_title" | grep -qi "Microsoft" && echo "Microsoft" && return
  echo "$main_title" | grep -qi "ByteDance" && echo "ByteDance" && return
  
  # Otherwise take first word
  echo "$main_title" | awk '{print $1}' | tr -d '"'
}

for post_dir in $POSTS_DIR/2026-02-*; do
  if [ -d "$post_dir" ]; then
    slug=$(basename "$post_dir")
    
    # Get title
    title=$(grep "^title:" "$post_dir/index.qmd" | sed 's/title: *"\(.*\)"/\1/' | head -1)
    keyword=$(get_keyword "$title")
    
    # Clean topic for prompt
    topic=$(echo "$title" | sed "s/'//g; s/\"//g")
    
    # Build prompt
    prompt="Professional editorial illustration for a tech blog post about $topic. Cinematic lighting, futuristic AI aesthetic, high contrast, clean shapes, dark mode compatible, 16:9 aspect ratio."
    encoded_prompt=$(echo "$prompt" | jq -sRr @uri)
    
    # Use Pollinations enterprise endpoint with skiploader (as per user instruction/key type)
    # The user provided an enter.pollinations.ai key.
    # Note: enter.pollinations.ai usually hosts images directly at pollinations.ai/p/
    # We will fetch and save the image locally to avoid runtime latency/blocking.
    
    url="https://pollinations.ai/p/${encoded_prompt}?width=1024&height=576&seed=$((RANDOM))&nologo=true&enhance=true"
    
    echo "Processing: $slug"
    # Save as .jpg instead of .svg
    curl -s -L "$url" -o "$post_dir/image.jpg"
    
    # Update index.qmd frontmatter if needed to point to image.jpg
    sed -i 's/image: "image.svg"/image: "image.jpg"/g' "$post_dir/index.qmd"
    sed -i "s/image: 'image.svg'/image: 'image.jpg'/g" "$post_dir/index.qmd"
    
    echo "  Generated image.jpg for $keyword"
    sleep 1
  fi
done

echo "Done!"
