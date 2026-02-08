# Project: ainews

## Description

World-class AI news portal focusing on unique English insights, built with Quarto and R. Currently in local development and testing phase.

## Tech Stack

- Quarto
- R
- CSS (Dark AI Theme)
- Gemini 3 Flash (Primary Author Engine)

## TODOs

- [ ] Implement automatic image generation via AI for each post.
- [ ] Add RSS feed subscription link for readers.
- [ ] Integrate Newsletter signup.
- [ ] Add "Expert Opinion" section to each digest.

## Cron Jobs

| Schedule | Script | Purpose |
|----------|--------|---------|
| 0 8 * * * | Cron ID: c39bdd8a... | Daily scout, unique post generation & git push |

## Event Log

### 2026-02-06

- Project initialized at /home/skutek/projekty/ainews.
- Implemented Dark AI Theme and Quarto structure.
- Established legal pages (Privacy/Terms).
- Initial setup of automated scouting with Gemini 2.0 Flash.

### 2026-02-07

- Upgraded primary author engine to Gemini 3 Flash for better analysis and phrasing.
- Registered project in MEMORY.md and formatted project logs using pmem skill.
- Successfully performed manual daily update and verified cron automation.
- Implemented Deduplication System: Created `data/published_topics.json` to track topics and prevent repetitive content. Added "Validation & Update" step to automation requirements.
- Verified historical posts and initialized topic database with today's and yesterday's entries.
- Synchronized heartbeat tasks to enforce deduplication check before každą publikacją.
