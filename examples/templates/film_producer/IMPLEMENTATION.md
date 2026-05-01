# Film Producer Colony - Implementation Summary

## What We Built

A complete genre-agnostic film generation pipeline that works from the HIVE web UI chat.

## Architecture

```
User (Web UI Chat)
    ↓
Queen (any queen, typically Technology)
    ↓ (recognizes film request)
create_colony() call
    ↓
Film Producer Colony
    ↓ (materializes film-producer skill)
Worker executes:
    1. Script generation (LLM)
    2. Scene parsing (JSON extraction)
    3. Voiceover generation (ElevenLabs, parallel)
    4. Video generation (Kling, parallel)
    5. Assembly (FFmpeg)
    6. Quality check (ffprobe)
    ↓
Final video + reports
```

## Files Created

```
examples/templates/film_producer/
├── README.md              # User-facing overview
├── USAGE.md               # Detailed web UI usage guide
├── QUEEN_INSTRUCTIONS.md  # How the queen handles requests
├── skill.md               # The actual colony skill (operational procedure)
└── IMPLEMENTATION.md      # This file
```

## How It Works

### 1. User Makes Request (Web UI)

User types in chat:
```
Make a horror-comedy film about Ibn Battuta in Classical Arabic, anime style
```

### 2. Queen Recognizes Pattern

Queen's recognition logic (from QUEEN_INSTRUCTIONS.md):
- Detects "Make a film about..." pattern
- Extracts parameters:
  - story: "Ibn Battuta"
  - genre: "horror-comedy"
  - language: "Classical Arabic"
  - visual_style: "anime"

### 3. Queen Validates Credentials

Queen checks:
- ELEVENLABS_API_KEY ✓
- KLING_API_KEY ✓

If missing, guides user to add them.

### 4. Queen Creates Colony

Queen calls:
```python
create_colony(
    colony_name="film-ibn-battuta-001",
    task="Generate a horror-comedy film about Ibn Battuta in Classical Arabic, anime style",
    skill_name="film-producer",
    skill_description="Autonomous film generation",
    skill_body="[content from skill.md]",
    tasks=[{
        "goal": "Generate complete film",
        "payload": {
            "story": "Ibn Battuta",
            "genre": "horror-comedy",
            "language": "Classical Arabic",
            "visual_style": "anime"
        }
    }]
)
```

### 5. Colony Executes Autonomously

Worker in the colony:
1. Reads skill.md instructions
2. Executes each phase sequentially
3. Fans out parallel tasks for voiceovers and video clips
4. Assembles final video with FFmpeg
5. Validates and reports

### 6. User Gets Result

After 2-5 minutes:
- `output/film/final_film.mp4` — main video
- `output/film/hls/playlist.m3u8` — streaming version
- `output/film/poster.jpg` — thumbnail
- `output/film/quality_report.md` — validation

## Usage Flow

### From Web UI (Primary Use Case)

1. Open HIVE web UI
2. Chat with queen
3. Say: "Make a [genre] film about [story] in [language], [style] style"
4. Queen creates colony
5. Watch progress on colony page
6. Download final video when complete

### From CLI (Alternative)

```bash
hive run film-producer \
  --story "Ibn Battuta's journey" \
  --genre "horror-comedy" \
  --language "Classical Arabic" \
  --visual_style "anime"
```

## API Integration

### ElevenLabs (Voiceovers)

**Endpoint:** `POST /v1/text-to-speech/{voice_id}`

**Request:**
```json
{
  "text": "voiceover in target language",
  "model_id": "eleven_multilingual_v2",
  "voice_settings": {
    "stability": 0.5,
    "similarity_boost": 0.75
  }
}
```

**Response:** MP3 audio file

**Rate limits:** ~50 requests/minute (standard tier)

### Kling (Video Generation)

**Endpoint:** `POST /v1/videos`

**Request:**
```json
{
  "prompt": "anime style: ancient Baghdad street",
  "duration": 20,
  "aspect_ratio": "16:9"
}
```

**Response:** Generation ID → poll status → download video

**Rate limits:** ~20 concurrent generations

### FFmpeg (Assembly)

Local execution, no API needed:
- Combine video + audio tracks
- Concatenate with crossfade transitions
- Generate HLS streaming version
- Extract poster frame

## Performance Profile

| Stage | Time (per scene) | Parallel? |
|-------|------------------|-----------|
| Script | 30s total | No |
| Parse | 5s total | No |
| Voiceover | 10s | Yes (all scenes) |
| Video | 60s | Yes (all scenes) |
| Assembly | 30s total | No |
| Quality | 10s total | No |
| **Total (5 scenes)** | **~4-5 minutes** | |

## Credential Setup

Users need to configure:

1. **ElevenLabs API Key**
   - Get from: https://elevenlabs.io
   - Add in HIVE: Settings → Credentials → ELEVENLABS_API_KEY

2. **Kling API Key**
   - Get from: https://klingai.com
   - Add in HIVE: Settings → Credentials → KLING_API_KEY

## Genre-Agnostic Design

The pipeline handles any genre by:

1. **Script tone** — LLM adapts writing style to genre
2. **Voice selection** — Stability settings adjust expressiveness
3. **Visual prompts** — Style keywords adapt to genre expectations

Examples:
- **horror-comedy** → Expressive voice, dramatic visuals with comedic timing
- **documentary** → Authoritative voice, factual visual descriptions
- **drama** → Warm narrative voice, emotional visual storytelling
- **action** → Dynamic voice, fast-paced visual sequences

## Language Support

ElevenLabs multilingual v2 supports:
- European: English, French, German, Spanish, Italian, Portuguese, Polish, Turkish
- Asian: Chinese, Japanese, Korean, Hindi
- Middle Eastern: Arabic (including Classical Arabic), Hebrew
- And 20+ more

The script is written entirely in the target language, and voiceover matches.

## Visual Style Support

Any visual style can be specified:
- **anime** — "anime style, Studio Ghibli aesthetic"
- **realistic** — "photorealistic, cinematic lighting, 35mm film"
- **watercolor** — "watercolor painting, soft edges, artistic"
- **oil painting** — "oil painting, classical style"
- **cyberpunk** — "cyberpunk, neon, futuristic"
- **pixel art** — "pixel art, 8-bit style"
- Custom — Any descriptive phrase works

## Error Recovery

The skill includes error handling for:

1. **Rate limits** — Exponential backoff, retry with delays
2. **Timeouts** — Skip failed scenes, continue with rest
3. **Quality issues** — Report problems, offer re-generation
4. **Credential errors** — Fail fast, guide user to fix

## Next Steps

To use this system:

1. **Install the template**
   - Files are in `examples/templates/film_producer/`
   - The skill content is in `skill.md`

2. **Configure credentials**
   - Add ELEVENLABS_API_KEY
   - Add KLING_API_KEY

3. **Test with a simple film**
   ```
   Make a short documentary about coffee in English, realistic style
   ```

4. **Iterate and expand**
   - Try different genres
   - Experiment with visual styles
   - Test different languages

## Future Enhancements

Potential improvements:

1. **Custom voice selection** — Let users choose specific ElevenLabs voices
2. **Background music** — Add royalty-free music tracks per genre
3. **Subtitles** — Generate subtitle files in multiple languages
4. **Scene editing** — Allow users to modify individual scenes before assembly
5. **Longer films** — Support for 5-10 minute films (more scenes)
6. **Multiple aspect ratios** — 9:16 for TikTok/Reels, 1:1 for Instagram
7. **Style references** — Accept reference images for visual style

## Troubleshooting

**Colony doesn't start:**
- Check that skill.md was properly materialized
- Verify task was seeded in progress.db
- Check colony logs for errors

**API calls fail:**
- Verify credentials are correct
- Check API key permissions/quotas
- Test APIs independently with curl

**Video quality poor:**
- Adjust Kling prompt specificity
- Try different visual style descriptions
- Increase scene durations for complex visuals

**Audio quality poor:**
- Adjust ElevenLabs stability settings
- Try different voice IDs
- Ensure script text is clean (no special characters)

## Support

For issues or questions:
1. Check the colony logs in the web UI
2. Review quality_report.md for technical details
3. Consult USAGE.md for common scenarios
4. Check API provider documentation (ElevenLabs, Kling)

---

**Built with:** HIVE colony system, ElevenLabs TTS, Kling video generation, FFmpeg
**Author:** HIVE framework team
**Version:** 1.0
**Date:** 2026-04-22
