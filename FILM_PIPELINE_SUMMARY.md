# Film Generation Pipeline - Quick Start

## What You Asked For

A genre-agnostic film pipeline where you trigger new story/video generation from the HIVE web UI chat, and everything runs automatically to final video.

## What We Built

- Complete pipeline: Script → Voiceover → Video → Assembly
- Web UI chat integration — ask queen in natural language
- Genre-agnostic (horror-comedy, documentary, drama, etc.)
- Multi-language (Classical Arabic, French, Japanese, English, etc.)
- Multiple visual styles (anime, realistic, watercolor, etc.)
- Fully autonomous — no approvals needed
- Parallel execution for voiceovers and video clips
- Quality validation on final output

## Files Created

```
examples/templates/film_producer/
├── README.md              # Overview
├── USAGE.md               # Detailed usage guide
├── QUEEN_INSTRUCTIONS.md  # How queen handles requests
├── skill.md               # Colony skill instructions
└── IMPLEMENTATION.md      # Technical details

core/framework/skills/_default_skills/film-pipeline/
└── SKILL.md               # Default skill reference
```

## How to Use (Web UI)

### 1. Set Up Credentials

In HIVE web UI:
- Settings → Credentials
- Add `ELEVENLABS_API_KEY` (from elevenlabs.io)
- Add `KLING_API_KEY` (from klingai.com)

### 2. Make Your First Film

In chat with queen:
```
Make a horror-comedy film about Ibn Battuta in Classical Arabic, anime style
```

Queen will:
1. Recognize film request
2. Check credentials
3. Create film-producer colony
4. Execute full pipeline automatically

### 3. Watch Progress

New colony page shows:
- Script generation ✓
- Scene parsing ✓
- Voiceover generation (parallel)
- Video generation (parallel)
- Final assembly
- Quality check

### 4. Get Your Film (2-5 minutes)

Output:
- `output/film/final_film.mp4` — complete film
- `output/film/hls/playlist.m3u8` — streaming
- `output/film/poster.jpg` — thumbnail
- `output/film/quality_report.md` — validation

## Examples

```
Make a documentary about Marie Curie in French, realistic style
```

```
Create a drama film about a samurai in Japanese, watercolor style
```

```
Make a cyberpunk film about a hacker in Korean, anime style
```

## Performance

| Length | Scenes | Time |
|--------|--------|------|
| 1 min | 3-4 | 2-3 min |
| 2 min | 5-7 | 4-5 min |
| 3 min | 8-10 | 6-8 min |

## Parameters

- **story** (required) — What film is about
- **genre** (optional, default: drama) — horror-comedy, documentary, etc.
- **language** (optional, default: English) — Classical Arabic, French, etc.
- **visual_style** (optional, default: realistic) — anime, watercolor, etc.

## Architecture

```
User Chat → Queen → create_colony() → Film Colony → Worker executes:
  1. Script (LLM)
  2. Parse to JSON
  3. ElevenLabs voiceovers (parallel)
  4. Kling video clips (parallel)
  5. FFmpeg assembly
  6. Quality check
→ Final MP4 in 2-5 min
```

## Troubleshooting

**Missing credentials** — Add in Settings → Credentials
**Slow generation** — Kling takes ~60s/scene (normal)
**Wrong style** — Be specific: "anime style by Studio Ghibli"
**Audio issues** — Specify voice: "use deep male voice"

## Next Steps

1. Read USAGE.md for complete guide
2. Add API credentials
3. Make your first film
4. Experiment with genres/languages/styles

---

Ready? Just say: "Make a horror-comedy film about Ibn Battuta in Classical Arabic, anime style"
