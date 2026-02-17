#!/bin/bash
# Set Dynamic Pollinations URLs in all posts to avoid server-side blocking

POSTS_DIR="/home/skutek/projekty/ainews/posts"

for post_dir in $POSTS_DIR/2026-02-*; do
  if [ -d "$post_dir" ]; then
    slug=$(basename "$post_dir")
    title=$(grep "^title:" "$post_dir/index.qmd" | sed 's/title: *"\(.*\)"/\1/' | head -1)
    
    # Clean topic for prompt
    topic=$(echo "$title" | sed "s/'//g; s/\"//g" | tr ' ' '+')
    
    # Create dynamic URL for Pollinations
    # We use pollinations.ai/p/ format which works great in browser
    img_url="https://pollinations.ai/p/${topic}?width=1024&height=576&seed=$((RANDOM))&nologo=true"
    
    echo "Ustawianie URL dla: $slug"
    
    # Replace image field with direct URL
    sed -i "s|image:.*|image: \"$img_url\"|g" "$post_dir/index.qmd"
  fi
done
