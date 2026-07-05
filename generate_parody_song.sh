#!/usr/bin/env bash
# Generate "I Know How This Works" (Weird Al-style flat-pack parody) with
# ElevenLabs Music (Eleven Music API).
#
# Usage: ELEVENLABS_API_KEY=xi-... ./generate_parody_song.sh [output.mp3]
set -euo pipefail

OUT="${1:-i_know_how_this_works_parody.mp3}"
: "${ELEVENLABS_API_KEY:?Set ELEVENLABS_API_KEY to your ElevenLabs API key}"

read -r -d '' PROMPT <<'EOF' || true
A comedic rock parody song in the style of a confident, driving pop-rock
call-out anthem — mid-tempo, punchy electric guitars, tight drums, a slightly
theatrical male lead vocal sung with total unearned confidence. The joke:
the narrator is assembling flat-pack furniture and refuses to read the manual.
The bridge is spoken word, dead calm, with comedic timing over an instrumental
breakdown. End with the outro fading under distant crashing sounds. Sing these
lyrics exactly:

[Verse]
I've got a box from the Swedish store
Instructions? Please — I've done this before
Every screw's the same
Manuals are for jerks
I know how this works
I know how this works

[Prechorus]
Allen wrench in hand
I've got a plan

[Chorus]
I know how this works
The peg
The screw
The quirk
I need no plans
These capable hands
I know how this works

[Verse 2]
The shelf leans left and the legs point east
I've got twelve screws left over, at least
But the wobble's fine
It's called "design"
I planned it all
I planned it all

[Prechorus]
Allen wrench in hand
Just as I planned

[Chorus]
I know how this works
The peg
The screw
The quirk
I need no plans
These capable hands
I know how this works

[Bridge — spoken, dead calm]
Okay. That's... that's a load-bearing shelf now.
"Step one: insert dowel A into slot—" Nope. No. I don't need this.
...That was always going to do that.

[Verse 3]
The bunk bed's done and it only took nine
Hours — plus stitches, but I'm feeling fine
Kids can sleep in shifts
Gravity's a jerk
I know how this works
I know how this works

[Prechorus]
Band-aid on each hand
Part of the plan

[Final Chorus]
I know how this works
The crack
The creak
The lurch
It's up to code
(At least my own code)
I know how this works

[Outro — repeating, fading]
I know how this works
I know how this works
I know how this works...
EOF

jq -n --arg prompt "$PROMPT" '{prompt: $prompt, music_length_ms: 180000}' |
curl -sS -X POST "https://api.elevenlabs.io/v1/music" \
  -H "xi-api-key: ${ELEVENLABS_API_KEY}" \
  -H "Content-Type: application/json" \
  -d @- -o "$OUT"

# If the API returned a JSON error instead of audio, surface it.
if head -c 1 "$OUT" | grep -q '{'; then
  echo "API returned an error:" >&2
  cat "$OUT" >&2
  exit 1
fi
echo "Wrote $OUT"
