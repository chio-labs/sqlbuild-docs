# Demo recordings

How the terminal demo GIFs in the docs are produced.

## dbt reuse (`/dbt-reuse.gif`)

Shows pointing SQLBuild at a dbt project: `sqb dbt init`, then a first
`sqb dbt build` that reuses 8 unchanged tables from production and rebuilds only
the 2 edited models, then a second build that skips everything because all
planned dbt models are current.

Embedded on `concepts/dbt-compatibility/overview.mdx`.

### Tools

- [`vhs`](https://github.com/charmbracelet/vhs) (terminal recorder)
- `ttyd` (headless terminal, used by vhs)
- `ffmpeg` (post-processing: speed-up and GIF encode)
- `sqb`, `dbt`, `git` on PATH (activate the SQLBuild venv first)

On Debian/Ubuntu, vhs installs cleanly from the release `.deb`; `ttyd` is a
single static binary from its releases; `ffmpeg` is in apt.

### Why a raw recording plus an ffmpeg speed-up

`vhs` records command output in real time. Fixed `Sleep`s in the tape are sized
generously so nothing is ever clipped mid-output, which makes the raw recording
long (~60s). Speeding up inside vhs (`Set PlaybackSpeed`) compressed the timeline
unpredictably and clipped the payoff frames. So the tape renders a full-speed
raw source, and ffmpeg speeds it up afterward. This is deterministic: the full
recording already exists, so post-speed-up cannot clip content, and the speed
factor can be retuned without re-recording.

### `SQLBUILD_NO_PROGRESS`

`sqb` shows a transient spinner (rich `Status`) for long planning steps. Inside
a headless tty that spinner redraws over streaming dbt output and, captured
frame-by-frame, smears across the rows. Setting `SQLBUILD_NO_PROGRESS=1` prints
those status lines as plain (still colored) lines instead of an animated spinner,
which removes the smear. The tape sets it.

### Steps

```bash
cd assets/demos

# 1. Activate the SQLBuild venv so sqb/dbt/git resolve.
source /path/to/sqlbuild/.venv/bin/activate

# 2. Render the full-speed raw source (~60s, real-time; nothing clipped).
vhs dbt-reuse.tape          # -> dbt-reuse-raw.mp4

# 3. Speed up 3x and emit the final MP4 + GIF.
#    Change PTS/3 to PTS/2 (slower) or PTS/4 (faster) to retune.
ffmpeg -y -i dbt-reuse-raw.mp4 -filter:v "setpts=PTS/3" -an dbt-reuse.mp4
ffmpeg -y -i dbt-reuse.mp4 -vf "fps=15,scale=1100:-1:flags=lanczos,palettegen" palette.png
ffmpeg -y -i dbt-reuse.mp4 -i palette.png \
  -lavfi "fps=15,scale=1100:-1:flags=lanczos[x];[x][1:v]paletteuse" dbt-reuse.gif
rm -f palette.png

# 4. Publish: copy the GIF to the docs repo root (served at /dbt-reuse.gif).
cp dbt-reuse.gif ../../dbt-reuse.gif
```

The intermediate `dbt-reuse-raw.mp4`, `dbt-reuse.mp4`, and `palette.png` are
build artifacts and do not need to be committed; only the published
`/dbt-reuse.gif` at the repo root is referenced by the docs.
