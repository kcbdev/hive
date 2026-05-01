# Film Producer Colony

Autonomous film generation colony. Takes story, genre, language, and visual style parameters. Produces complete video with voiceover and generated scenes.

## Usage from Web UI

In the HIVE web UI chat with your queen, say:

```
Make a horror-comedy film about Ibn Battuta in Classical Arabic, anime style
```

Or:

```
Create a film:
- Story: Marie Curie discovers radium
- Genre: documentary
- Language: French
- Visual style: realistic
```

The queen will create a film-producer colony that executes autonomously.

## Usage from CLI

```bash
hive run film-producer \
  --story "Ibn Battuta's journey through Damascus" \
  --genre "horror-comedy" \
  --language "Classical Arabic" \
  --visual_style "anime"
```

## Pipeline

1. **Script** — Write complete script in target language
2. **Parse** — Extract scenes to structured JSON
3. **Voiceover** — ElevenLabs TTS (parallel per scene)
4. **Video** — Kling video generation (parallel per scene)
5. **Assembly** — FFmpeg concatenation with transitions
6. **Quality** — Validate final output

## Credentials Required

Set these before running:
- `ELEVENLABS_API_KEY` — ElevenLabs TTS
- `KLING_API_KEY` — Kling video generation

## Output

```
output/
├── script.md
├── scenes.json
├── audio/scene_*.mp3
├── video/scene_*.mp4
├── final_film.mp4
├── hls/playlist.m3u8
├── poster.jpg
└── quality_report.md
```

## Performance

- 2-3 minute film: 2-5 minutes total generation time
- Dominated by Kling video generation (~60s per scene)
- All other stages: <30 seconds each
