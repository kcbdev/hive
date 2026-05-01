# Film Producer - Web UI Usage Guide

## Quick Start

### From the HIVE Web UI Chat

1. Open your HIVE web UI and start a chat with your queen (any queen works, but the Technology Queen is best for this)

2. Type one of these prompts:

**Simple:**
```
Make a horror-comedy film about Ibn Battuta in Classical Arabic, anime style
```

**Detailed:**
```
Create a film with these parameters:
- Story: Ibn Battuta encounters a shape-shifting jinn in 14th century Baghdad
- Genre: horror-comedy
- Language: Classical Arabic
- Visual style: anime
```

**Alternative examples:**
```
Make a documentary about Marie Curie discovering radium, in French, realistic style
```

```
Create a drama film about a samurai's last battle, in Japanese, watercolor painting style
```

3. The queen will respond that she's creating a film-producer colony

4. A new colony page will open showing the execution progress:
   - Script generation
   - Scene parsing
   - Voiceover generation (parallel)
   - Video clip generation (parallel)
   - Final assembly
   - Quality check

5. Wait 2-5 minutes (depending on film length and Kling API speed)

6. When complete, you'll see:
   - `output/film/final_film.mp4` — the main video
   - `output/film/hls/playlist.m3u8` — streaming version
   - `output/film/poster.jpg` — thumbnail
   - `output/film/quality_report.md` — validation results

7. Download or stream your film!

## Credentials Setup

Before your first film, make sure you have these credentials configured in HIVE:

1. Go to Settings → Credentials (or `/credentials` in the UI)
2. Add:
   - `ELEVENLABS_API_KEY` — your ElevenLabs API key
   - `KLING_API_KEY` — your Kling API key

If credentials are missing, the colony will report an error and you can add them and retry.

## Parameters Reference

| Parameter | Example | Description |
|-----------|---------|-------------|
| story | "Ibn Battuta's journey" | What the film is about (required) |
| genre | "horror-comedy", "documentary", "drama", "action" | Film genre |
| language | "Classical Arabic", "French", "Japanese", "English" | Script and voiceover language |
| visual_style | "anime", "realistic", "watercolor", "oil painting" | Visual aesthetic |

## Genre Examples

- **horror-comedy** — Blends scary and funny elements (great for Ibn Battuta jinn stories)
- **documentary** — Factual, educational tone (good for historical figures like Marie Curie)
- **drama** — Emotional, narrative-driven (good for samurai stories, personal journeys)
- **action** — Fast-paced, dynamic scenes (adventures, battles)

## Visual Style Examples

- **anime** — Japanese animation style (mention "Studio Ghibli" or "Makoto Shinkai" for specific aesthetics)
- **realistic** — Photorealistic, cinematic (looks like live-action film)
- **watercolor** — Soft, artistic watercolor painting look
- **oil painting** — Classical painted aesthetic
- **cyberpunk** — Neon, futuristic, high-tech

## Language Support

ElevenLabs multilingual model supports:
- English, Spanish, French, German, Italian, Portuguese
- Arabic (including Classical Arabic)
- Chinese, Japanese, Korean
- Hindi, Turkish, Polish
- And 20+ more languages

The film script will be written entirely in your chosen language, and the voiceover will match.

## Troubleshooting

**"Credentials not found" error:**
- Add ELEVENLABS_API_KEY and KLING_API_KEY in Settings → Credentials
- Retry the film generation request

**ElevenLabs voice sounds wrong:**
- The colony uses a default narrator voice
- For custom voice, specify in your request: "use a deep male voice" or "use a young female voice"

**Kling generates wrong style:**
- Be more explicit: "anime style by Studio Ghibli" instead of just "anime"
- Add reference artists or studios in your request

**Film takes too long:**
- Kling video generation is the bottleneck (~60s per scene)
- A 5-scene, 2-minute film takes ~5 minutes total
- This is normal — video generation is computationally intensive

**Audio/video out of sync:**
- The colony automatically handles sync with FFmpeg
- If you notice issues, check the quality_report.md for details
- Re-run with adjusted scene durations if needed

## Advanced Usage

### Custom Output Directory

```
Make a film about X, save it to output/my-films/ibn-battuta
```

### Multiple Films in Sequence

Just ask again after the first completes:

```
Now make another one about Marco Polo in Italian, realistic style
```

The queen will create a new colony for each film.

### Batch Generation

For multiple films at once, specify:

```
Create 3 short films:
1. Ibn Battuta in Baghdad (horror-comedy, Classical Arabic, anime)
2. Marie Curie in Paris (documentary, French, realistic)
3. Samurai battle (drama, Japanese, watercolor)
```

The queen may create multiple colonies in parallel or sequence them based on available resources.

## Output Files Explained

- **script.md** — Full film script in your chosen language
- **scenes.json** — Structured scene data (useful for debugging or modifications)
- **audio/scene_*.mp3** — Individual voiceover files
- **video/scene_*.mp4** — Individual video clips from Kling
- **final_film.mp4** — Complete assembled film (main deliverable)
- **hls/playlist.m3u8** — Streaming version (for web playback)
- **poster.jpg** — Thumbnail/poster image
- **quality_report.md** — Technical validation results

## Performance Expectations

| Film Length | Scenes | Expected Time |
|-------------|--------|---------------|
| 1 minute | 3-4 scenes | ~2-3 minutes |
| 2 minutes | 5-7 scenes | ~4-5 minutes |
| 3 minutes | 8-10 scenes | ~6-8 minutes |

Times vary based on:
- Kling API queue depth
- Your internet connection
- Number of parallel workers available

## Next Steps After Generation

Once your film is complete:

1. **Download** — Download `final_film.mp4` from the output folder
2. **Share** — Upload to YouTube, Vimeo, or social media
3. **Edit** — Use the individual scene files for custom editing
4. **Iterate** — Ask the queen to make changes: "Regenerate scene 3 with a different visual"
5. **Sequence** — Create a series of films and combine them externally

## Tips for Best Results

1. **Be specific in your story** — "Ibn Battuta meets a jinn" is better than just "Ibn Battuta"
2. **Match genre to story** — Horror-comedy works well for supernatural encounters
3. **Choose appropriate visual style** — Anime for fantasy, realistic for historical documentaries
4. **Keep films short** — 2-3 minutes is the sweet spot for generated content
5. **Review the script** — The script.md is generated first; you can request changes before video generation starts
