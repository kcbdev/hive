---
name: film-producer
description: Autonomous film generation from script to final video. Uses ElevenLabs for voiceovers, Kling for video clips, FFmpeg for assembly.
---

# Film Producer Skill

Execute the following pipeline autonomously. Do not ask for approvals unless there are credential errors or API failures.

## Input Parameters

Extract these from the user's request or use defaults:
- `story`: What the film is about (required)
- `genre`: "drama", "horror-comedy", "documentary", etc. (default: "drama")
- `language`: "English", "Classical Arabic", "French", etc. (default: "English")
- `visual_style`: "anime", "realistic", "watercolor", etc. (default: "realistic")
- `output_dir`: "output/film" (default)

## Execution Steps

### Step 1: Generate Script
Write a complete film script:
- Language: `{language}`
- Genre tone: `{genre}`
- Story: `{story}`
- Structure: 5-7 scenes, 15-30 seconds each
- Format:
  ```markdown
  # Scene 1
  [Visual: description]
  [VO: narration in {language}]
  
  # Scene 2
  ...
  ```
- Save to: `{output_dir}/script.md`

### Step 2: Parse Scenes
Read the script and create JSON:
```json
{
  "scenes": [
    {
      "scene_number": 1,
      "visual_description": "enhanced prompt for Kling",
      "voiceover_text": "exact VO text from script",
      "duration": 20
    }
  ],
  "language": "{language}",
  "visual_style": "{visual_style}",
  "total_scenes": 5
}
```
- Save to: `{output_dir}/scenes.json`

### Step 3: Generate Voiceovers (ElevenLabs)
For each scene in parallel:
1. Read `voiceover_text` and `language`
2. Call ElevenLabs API:
   ```bash
   curl -X POST "https://api.elevenlabs.io/v1/text-to-speech/21m00Tcm4TlvDq8ikWAM" \
     -H "xi-api-key: $ELEVENLABS_API_KEY" \
     -H "Content-Type: application/json" \
     -d "{
       \"text\": \"{voiceover_text}\",
       \"model_id\": \"eleven_multilingual_v2\",
       \"voice_settings\": {\"stability\": 0.5, \"similarity_boost\": 0.75}
     }" \
     -o "{output_dir}/audio/scene_{scene_number:03d}.mp3"
   ```
3. Create `{output_dir}/audio_manifest.json` with file list and durations

**Voice selection:**
- Use Rachel (21m00Tcm4TlvDq8ikWAM) for general narration
- Adjust stability based on genre:
  - horror-comedy: 0.4 (more expressive)
  - documentary: 0.7 (more authoritative)
  - drama: 0.5 (balanced)

### Step 4: Generate Video Clips (Kling)
For each scene in parallel:
1. Read `visual_description` and `visual_style`
2. Enhance prompt for style:
   - anime: "anime style: {description}, Studio Ghibli aesthetic, detailed animation"
   - realistic: "photorealistic: {description}, cinematic lighting, 35mm film"
   - watercolor: "watercolor painting: {description}, soft edges, artistic"
3. Call Kling API:
   ```bash
   curl -X POST "https://api.klingai.com/v1/videos" \
     -H "Authorization: Bearer $KLING_API_KEY" \
     -H "Content-Type: application/json" \
     -d "{
       \"prompt\": \"{enhanced_prompt}\",
       \"duration\": {duration},
       \"aspect_ratio\": \"16:9\"
     }"
   ```
4. Poll for completion (check status endpoint every 10s, timeout 5 min)
5. Download video to `{output_dir}/video/scene_{scene_number:03d}.mp4`
6. Create `{output_dir}/video_manifest.json`

### Step 5: Assemble Final Video
Execute FFmpeg commands:

```bash
# Create directories
mkdir -p {output_dir}/combined {output_dir}/hls

# Combine video + audio per scene
for scene in scenes:
  ffmpeg -y -i "video/scene_{n}.mp4" -i "audio/scene_{n}.mp3" \
    -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 -shortest \
    "combined/scene_{n}.mp4"

# Create concat list
echo "file 'combined/scene_01.mp4'" > concat.txt
# ... add all scenes

# Concatenate with crossfade transitions
ffmpeg -y -f concat -i concat.txt \
  -filter_complex "[0:v][0:a][1:v][1:a]...xfade=transition=fade:duration=0.5" \
  -c:v libx264 -preset medium -crf 23 \
  -c:a aac -b:a 128k \
  "{output_dir}/final_film.mp4"

# Generate HLS streaming version
ffmpeg -y -i "{output_dir}/final_film.mp4" \
  -c:v libx264 -c:a aac \
  -hls_time 10 -hls_playlist_type vod \
  -hls_segment_filename "{output_dir}/hls/segment_%03d.ts" \
  "{output_dir}/hls/playlist.m3u8"

# Extract poster frame (best frame from first 30%)
ffmpeg -y -i "{output_dir}/final_film.mp4" \
  -vf "select=gt(scene\,0.3),thumbnail" -frames:v 1 \
  "{output_dir}/poster.jpg"
```

### Step 6: Quality Validation
Run ffprobe and generate report:

```bash
ffprobe -v error -show_entries format=duration -of json "{output_dir}/final_film.mp4"
ffprobe -v error -show_streams -select_streams v:0 -of json "{output_dir}/final_film.mp4"
ffprobe -v error -show_streams -select_streams a:0 -of json "{output_dir}/final_film.mp4"
```

Create `{output_dir}/quality_report.md`:
```markdown
# Quality Report

## Video
- Duration: X seconds
- Codec: H.264
- Resolution: 1920x1080
- Bitrate: X kbps

## Audio
- Codec: AAC
- Sample rate: 48000 Hz
- Channels: 2 (stereo)

## Status: PASS/FAIL
```

## Error Handling

**ElevenLabs 429 (rate limit):**
- Read `Retry-After` header
- Wait and retry with exponential backoff

**Kling timeout:**
- Poll status every 10 seconds
- Timeout after 5 minutes, log error, continue with next scene
- Report missing scenes in quality report

**FFmpeg failure:**
- Check all input files exist
- Verify uniform resolution/codec
- Re-transcode mismatched files before assembly

## Completion

When finished, report to the queen:
```
Film generation complete:
- Story: {story}
- Genre: {genre}
- Language: {language}
- Visual style: {visual_style}
- Duration: X seconds
- Scenes: N
- Output: {output_dir}/final_film.mp4
- HLS: {output_dir}/hls/playlist.m3u8
- Poster: {output_dir}/poster.jpg
- Quality: PASS/FAIL
```

Provide the queen with the file paths so the user can download/view the results.
