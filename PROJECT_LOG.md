# ainews - Project Log & Vision

## Vision & Goals
Goal: Create a world-class AI news portal using Quarto + R, focused on unique English insights.
Philosophy: Zero copy-paste. High visual impact (Dark AI Theme). Automated scouting via Gemini 2.0 Flash.

---

## 2026-02-06: The Genesis
### Accomplishments:
- Successfully initialized the project at `/home/skutek/projekty/ainews`.
- Implemented **Dark AI Theme** (styles.css) with high visual contrast and 5rem Hero Title for impact.
- Configured Quarto blog structure with modern grid listing.
- Established **Legal Base**: privacy.qmd and terms.qmd (English).
- Created **Live Scouting Logic**:
    - `data/sources.json` contains 20 top-tier AI sources (Hugging Face, arXiv, etc.).
    - Automated daily scout scheduled at 8:00 AM via `HEARTBEAT.md`.
    - Selected **Gemini 2.0 Flash** as the primary summary/author engine.
- Published first 2 professional posts (Daily Digest + Agentic Workflows analysis) with interlinking.

### Lessons Learned:
- Avoid copying data from other projects (prevents .RData/Rproj pollution).
- Quarto listing must be in `index.qmd`, not globally, to avoid render warnings in individual posts.
- Box placeholders on Home need high-quality images (800w) to prevent visual gaps.

---

## Future Ideas (Pending)
- [ ] Implement automatic image generation via AI for each post.
- [ ] Add RSS feed subscription link for readers.
- [ ] Integrate Newsletter signup.
- [ ] Add "Expert Opinion" section to each digest.
