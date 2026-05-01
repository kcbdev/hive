---
name: hive.film-pipeline
description: Colony skill for end-to-end film generation. Queen uses this to spawn film-production colonies. Handles script → ElevenLabs → Kling → FFmpeg assembly.
metadata:
  author: hive
  type: default-skill
  version: "1.0"
  verified: 2026-04-22
---

# Film Pipeline Colony Skill

This skill is materialized by the queen when a user requests film generation. The colony executes the full pipeline automatically.

## Usage Pattern

From the HIVE web UI chat, say:

```
Make a horror-comedy film about Ibn Battuta in Classical Arabic, anime style
```

The queen will:
1. Create a colony named `film-XXXX`
2. Materialize this skill into the colony
3. Seed a task with your parameters
4. The colony worker executes autonomously
5. You get a notification when the final video is ready

## Pipeline Execution

### Phase 1: Script
Write script in target language with genre-appropriate tone.

```python
# Output: output/script.md
# 5-7 scenes, each with:
# [Visual: description]
# [VO: narration in target language]
```

### Phase 2: Parse Scenes
Extract to JSON structure:

```json
{
  "scenes": [
    {
      "scene_number": 1,
      "visual_description": "anime style: ancient Baghdad street at dusk",
      "voiceover_text": "في مدينة بغداد القديمة...",
      "duration": 20
    }
  ],
  "language": "Classical Arabic",
  "visual_style": "anime"
}
```

### Phase 3: ElevenLabs Voiceovers
Parallel generation for all scenes:

```bash
for scene in scenes:
  curl -X POST "https://api.elevenlabs.io/v1/text-to-speech/VOICE_ID" \
    -H "xi-api-key: $ELEVENLABS_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{
      \"text\": \"${scene.voiceover_text}\",
      \"model_id\": \"eleven_multilingual_v2\",
      \"voice_settings\": {\"stability\": 0.5, \"similarity_boost\": 0.75}
    }" \
    -o "output/audio/scene_$(scene.scene_number).mp3"
```

**Voice selection by genre:**
- horror-comedy: use expressive voice (lower stability)
- documentary: use authoritative voice (higher stability)
- drama: use warm, narrative voice

### Phase 4: Kling Video Clips
Parallel generation for all scenes:

```bash
for scene in scenes:
  curl -X POST "https://api.klingai.com/v1/videos" \
    -H "Authorization: Bearer $KLING_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{
      \"prompt\": \"${scene.visual_description}\",
      \"duration\": ${scene.duration},
      \"aspect_ratio\": \"16:9\",
      \"style\": \"${visual_style}\"
    }"
```

**Style prompts:**
- anime: "anime style: [description], Studio Ghibli aesthetic"
- realistic: "photorealistic: [description], cinematic lighting"
- watercolor: "watercolor painting: [description], soft edges"

### Phase 5: FFmpeg Assembly

```bash
# Combine video + audio per scene
for i in $(seq -w 1 7); do
  ffmpeg -y -i "output/video/scene_$i.mp4" -i "output/audio/scene_$i.mp3" \
    -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 -shortest \
    "output/combined/scene_$i.mp4"
done

# Create concat file
echo "file 'combined/scene_01.mp4'" > concat.txt
echo "file 'combined/scene_02.mp4'" >> concat.txt
# ... repeat for all scenes

# Concatenate with crossfade
ffmpeg -y -f concat -i concat.txt \
  -vf "xfade=transition=fade:duration=0.5:offset=19.5" \
  -c:v libx264 -preset medium -crf 23 \
  -c:a aac -b:a 128k \
  output/final_film.mp4

# HLS for streaming
ffmpeg -y -i output/final_film.mp4 \
  -c:v libx264 -c:a aac \
  -hls_time 10 -hls_playlist_type vod \
  -hls_segment_filename "output/hls/segment_%03d.ts" \
  output/hls/playlist.m3u8

# Poster frame
ffmpeg -y -i output/final_film.mp4 \
  -vf "select=gt(scene\,0.3),thumbnail" -frames:v 1 \
  output/poster.jpg
```

### Phase 6: Quality Validation

```bash
ffprobe -v error -show_entries format=duration -of json output/final_film.mp4
ffprobe -v error -show_streams -select_streams v:0 -of json output/final_film.mp4
ffprobe -v error -show_streams -select_streams a:0 -of json output/final_film.mp4
```

Generate `output/quality_report.md` with:
- Total duration
- Video codec, resolution, bitrate
- Audio codec, sample rate, channels
- Pass/fail status

## Credentials

Colony requires these environment variables or credential entries:
- `ELEVENLABS_API_KEY`
- `KLING_API_KEY`

## Error Handling

**ElevenLabs rate limit (429):**
- Wait for `Retry-After` header
- Implement exponential backoff

**Kling generation timeout:**
- Poll generation status endpoint
- Timeout after 5 minutes per clip

**FFmpeg assembly failure:**
- Check all input files exist
- Verify uniform codec/resolution
- Re-transcode if needed

## Output

Colony produces:
```
output/
├── script.md
├── scenes.json
├── audio/scene_*.mp3
├── video/scene_*.mp4
├── combined/scene_*.mp4
├── final_film.mp4
├── hls/playlist.m3u8
├── poster.jpg
└── quality_report.md
```

Final deliverable: `output/final_film.mp4`
