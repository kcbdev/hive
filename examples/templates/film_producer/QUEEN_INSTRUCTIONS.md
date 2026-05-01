# Queen Instructions: Film Generation Requests

## Recognition Patterns

When a user's message contains these patterns, recognize it as a film generation request:

**Direct requests:**
- "Make a film about..."
- "Create a video about..."
- "Generate a film..."
- "I want a movie about..."
- "Produce a short film..."

**Parameterized requests:**
- "Story: X, Genre: Y, Language: Z, Style: W"
- "Make a [genre] film about [story] in [language], [style] style"

**Implicit requests:**
- "Can you create an anime video about Ibn Battuta?"
- "I need a documentary-style video about Marie Curie"

## Response Protocol

When you recognize a film generation request:

### 1. Extract Parameters

Parse the user's request for:
- **story** (required) — What the film is about
- **genre** (optional, default: "drama") — Film genre
- **language** (optional, default: "English") — Script and voiceover language
- **visual_style** (optional, default: "realistic") — Visual aesthetic

If story is missing, ask the user: "What story should the film tell?"

### 2. Check Credentials

Before creating the colony, verify:
- `ELEVENLABS_API_KEY` exists
- `KLING_API_KEY` exists

If missing, respond:
```
I can create that film for you, but I need API credentials first:
- ELEVENLABS_API_KEY (for voiceover generation)
- KLING_API_KEY (for video generation)

Add these in Settings → Credentials, then ask me again.
```

### 3. Create Colony

Call `create_colony` with these parameters:

```python
create_colony(
    colony_name="film-{timestamp or story-slug}",
    task="Generate a {genre} film about {story} in {language}, {visual_style} style",
    skill_name="film-producer",
    skill_description="Autonomous film generation from script to final video",
    skill_body="""
    [Copy the full skill content from examples/templates/film_producer/skill.md]
    """,
    tasks=[
        {
            "goal": "Generate complete film from script to final assembly",
            "payload": {
                "story": "{story}",
                "genre": "{genre}",
                "language": "{language}",
                "visual_style": "{visual_style}",
                "output_dir": "output/film"
            }
        }
    ]
)
```

### 4. Inform User

After creating the colony, tell the user:

```
I've created a film-producer colony for your {genre} film about {story}.

The colony will:
1. Write the script in {language}
2. Generate voiceovers (ElevenLabs)
3. Create video clips (Kling)
4. Assemble the final film
5. Validate quality

This takes 2-5 minutes depending on film length. You can monitor progress on the colony page.

I'll notify you when the final video is ready.
```

### 5. Monitor Progress

The colony runs autonomously. Monitor via:
- `get_worker_status()` — Check progress
- `list_worker_questions()` — Answer any escalations

Common escalations:
- **Credential errors** — Guide user to add missing credentials
- **API rate limits** — Advise user to wait and retry
- **Quality concerns** — Offer to regenerate specific scenes

### 6. Report Completion

When the colony finishes, summarize:

```
Your film is complete!

**{Story title}**
- Genre: {genre}
- Language: {language}
- Visual style: {visual_style}
- Duration: X seconds
- Scenes: N

**Output files:**
- Main video: output/film/final_film.mp4
- Streaming: output/film/hls/playlist.m3u8
- Poster: output/film/poster.jpg
- Quality: PASS/FAIL

You can download the video from the output folder or stream it via the HLS playlist.
```

## Example Interactions

### Example 1: Simple Request

**User:** "Make a horror-comedy film about Ibn Battuta in Classical Arabic, anime style"

**Queen:** 
```
I'll create a horror-comedy film about Ibn Battuta in Classical Arabic with anime-style visuals.

First, let me verify credentials... ✓ ELEVENLABS_API_KEY found, ✓ KLING_API_KEY found.

Creating film-producer colony now...

[Creates colony with task]

Your film is being generated! The colony will:
1. Write the script in Classical Arabic
2. Generate voiceovers with ElevenLabs
3. Create anime-style video clips with Kling
4. Assemble everything into a final film

This will take about 3-5 minutes. You can watch progress on the colony page.
```

### Example 2: Missing Credentials

**User:** "Make a documentary about Marie Curie in French"

**Queen:**
```
I can create that documentary for you! But first, I need to check credentials...

Missing:
- ELEVENLABS_API_KEY
- KLING_API_KEY

Please add these in Settings → Credentials:
1. Go to Settings
2. Click "Credentials"
3. Add ELEVENLABS_API_KEY (get from elevenlabs.io)
4. Add KLING_API_KEY (get from klingai.com)

Then ask me again, and I'll create your Marie Curie documentary right away.
```

### Example 3: Incomplete Request

**User:** "Make a film"

**Queen:**
```
I'd be happy to create a film for you! I need a bit more information:

1. **What story should it tell?** (e.g., "Ibn Battuta's travels", "Marie Curie's discovery")
2. **What genre?** (e.g., documentary, drama, horror-comedy)
3. **What language?** (e.g., English, French, Classical Arabic)
4. **What visual style?** (e.g., realistic, anime, watercolor)

Or just give me a simple description like:
"Make a documentary about Marie Curie in French, realistic style"
```

### Example 4: Complex Request

**User:** "Create 3 short films: Ibn Battuta (horror-comedy, Arabic, anime), Marie Curie (documentary, French, realistic), and a samurai battle (drama, Japanese, watercolor)"

**Queen:**
```
That's an ambitious trilogy! I'll create three separate film-producer colonies:

1. **Ibn Battuta** — horror-comedy, Classical Arabic, anime style
2. **Marie Curie** — documentary, French, realistic style  
3. **Samurai Battle** — drama, Japanese, watercolor style

Creating colonies now...

[Creates three colonies in parallel or sequence based on resources]

Each film will take 2-5 minutes to generate. You can monitor all three on their respective colony pages. I'll notify you as each one completes.
```

## Error Handling

### API Rate Limits

If the colony reports rate limit errors:

**ElevenLabs 429:**
```
The voiceover generation hit ElevenLabs' rate limit. The colony will retry with exponential backoff. This may add 1-2 minutes to the generation time.
```

**Kling quota exceeded:**
```
Kling video generation is at capacity. The colony will retry every 30 seconds. If this persists, you may need to upgrade your Kling API tier.
```

### Generation Failures

If specific scenes fail:

```
Scene 3 video generation failed (Kling timeout). The colony can:
1. Skip scene 3 and continue (film will be shorter)
2. Retry scene 3 (may take another 2-3 minutes)
3. Regenerate with a simpler visual description

Which would you prefer?
```

### Quality Issues

If the final film has problems:

```
The quality check found issues:
- Audio/video sync drift in scene 2
- Resolution mismatch between scenes 1 and 3

The colony can re-assemble with corrected settings, or you can download the individual scene files for manual editing.

Would you like me to have the colony re-assemble?
```

## Best Practices

1. **Set expectations** — Always tell users the 2-5 minute timeframe
2. **Show progress** — Point users to the colony page for live updates
3. **Handle errors gracefully** — Credential issues are common; guide users clearly
4. **Offer iterations** — Users often want to tweak and regenerate
5. **Celebrate completion** — Share excitement when the film is ready!

## Integration Notes

This film-producer capability integrates with:
- **HIVE Web UI** — Primary interface for users
- **Colony system** — Autonomous execution
- **MCP servers** — ElevenLabs and Kling integrations (if available)
- **FFmpeg** — Local video assembly

No additional setup required beyond API credentials.
