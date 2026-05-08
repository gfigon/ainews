# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**Robo AI Digest** — an automated AI news site at https://roboaidigest.com. Quarto static site that publishes 1–3 daily English-language briefings on AI/ML developments. Hosted on Netlify; deploys read pre-rendered HTML from the committed `_site/` directory (Netlify itself does not run Quarto — see "Deployment" below).

## Common commands

```bash
quarto render                       # build full site into _site/
quarto preview                      # local dev server with hot reload
quarto render posts/2026-05-06-eu-ai-act-dma-review/  # render a single post
bash scripts/generate-images.sh     # (re)generate image: URLs in posts (Pollinations.ai)
bash scripts/add_nofollow.sh        # apply rel="nofollow" to external markdown links
```

There is no test suite, linter, or package manifest — this is a content site, not an application.

## Publishing flow (the big picture)

1. **Scout** — daily cron jobs (08:00, 08:45, 10:15) trigger an agent that reads `data/sources.json` (RSS feeds, blogs, arXiv) and picks stories. `R/automate_scout.R` is a stub describing the agent contract; the actual scouting logic is executed by the orchestrating agent, not by R code.
2. **Deduplicate** — before writing, the agent must check `data/published_topics.json` and skip topics already covered. After publishing, it appends new entries (term + slug + date). This file is the single source of truth for "what have we already covered" and must be kept in sync.
3. **Write** — create `posts/YYYY-MM-DD-slug/index.qmd` with the frontmatter conventions below.
4. **Image** — `scripts/generate-images.sh` rewrites the `image:` field in each post to a `https://pollinations.ai/p/<title>?...` URL. Cron pipelines run this *after* writing posts (a past bug: posts went out without thumbnails because this step was missing).
5. **Render & commit** — `quarto render`, then commit both the post directory **and** the regenerated files under `_site/`. Netlify serves whatever is in `_site/`; skipping this step means the post won't appear live.

## Post frontmatter conventions

```yaml
---
title: "..."
date: "YYYY-MM-DD HH:MM"          # always include the time slot (08:00 / 08:45 / 10:15)
author: "AI News Editorial"
categories:
  - Primary
  - Secondary
summary: "..."                     # 1-sentence dek shown on listings
image: "https://pollinations.ai/p/..."   # set by generate-images.sh
---
```

`CATEGORIES.md` defines the canonical 7-category taxonomy (LLMs & Models, Industry News, Agents & Automation, Research & Innovation, AI Infrastructure, AI Security & Policy, AI Tools & Frameworks) with a "two categories per post" rule. Older posts predate this and use ad-hoc categories — don't retrofit them unless asked.

## External links: always nofollow

`filters/nofollow.lua` is registered in `_quarto.yml` and adds `rel="nofollow"` to every `http(s)://` link at render time. You generally don't need to add `{rel="nofollow"}` manually in markdown — the Lua filter handles it. The standalone `scripts/add_nofollow.sh` exists for retrofitting older posts and is rarely needed for new content.

## Deployment

`netlify.toml` has only `publish = "_site"` and no build command. **Netlify does not run Quarto.** The `_site/` directory is committed to git and served as-is. Consequence: any change to a post, theme file, or `_quarto.yml` requires a local `quarto render` and a commit of the regenerated `_site/` for it to ship. (See `.PROJECT_LOG.md` 2026-02-10 entry — this was a deliberate fix after Netlify was skipping Quarto builds.)

## Things that look weird but are intentional

- `_site/` is checked into git (see Deployment).
- `.PROJECT_LOG.md` is dotfile-prefixed specifically so Quarto doesn't pick it up into the sitemap (`PROJECT_LOG.md` and `_site/PROJECT_LOG.html` are also gitignored).
- `_quarto.yml` sets `website.title: ""` so the article title appears first in the `<title>` tag for SEO.
- `header-includes` in `_quarto.yml` wires up Google Consent Mode v2 → Klaro cookie banner → GTM (`GTM-WR6KBLTV`) in that exact order. Reordering breaks consent gating.
- Project log and some shell scripts contain Polish comments — this is a solo project, not a localization issue.

## Reference files when working in this repo

- `CATEGORIES.md` — taxonomy rules for new posts.
- `data/sources.json` — feed list the scout agent reads from.
- `data/published_topics.json` — dedup ledger; update when publishing.
- `.PROJECT_LOG.md` — chronological log of incidents, fixes, and infra changes; useful background for "why is X like this".
