# automate_scout.R
# This script is triggered by OpenClaw to run the daily AI news ingestion.

sources <- jsonlite::fromJSON("data/sources.json")
cat("Starting Daily AI Scout with Gemini 2.0 Flash...\n")

# Logic to be executed via sessions_spawn by the agent:
# 1. Fetch top RSS headlines (Hugging Face, arXiv, etc.)
# 2. Analyze content and pick top 3 stories.
# 3. For each story:
#    - Generate unique title and slug.
#    - Write index.qmd in posts/YYYY-MM-DD-slug/
#    - Generate/Download relevant image.
# 4. Final step: system('quarto render')
