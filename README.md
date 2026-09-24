# Arcade Coder

A tiny **framework** for arcade-style coding agents: Grok + tools + a LÖVE cabinet pad.

Swap the **kit** (hero + what it tosses). Default is a **ghost courier**: it travels to the pad and puts the line down. Other kits still toss.

Auth is the same file Fun uses: `~/.local/share/fun/auth.json`.

## Run

```bash
python3 -m fighter --name "Arcade Coder"
python3 love2d/run.py
```

Tab cycles kits: `ghost` · `invader` · `frog` · `ship` · `dog` · `cat` · `aladdin` · `harry`.
Each kit drops straight into its stage (maze, space, pond, neon, kennel, alley, Agrabah, Hogwarts). No title card.

```bash
ARCADE_KIT=aladdin python3 love2d/run.py
```

Enter fires a turn. Thinking streams into the box. Tools: read, write, edit, bash.
Login: `login` / Ctrl+L.

Record a live coding turn (workspace `/tmp/demo`) into `docs/demo-<kit>.mp4`:

```bash
PYTHONPATH=$HOME/demo python3 scripts/record-demo.py aladdin
PYTHONPATH=$HOME/demo python3 scripts/record-demo.py ghost
PYTHONPATH=$HOME/demo python3 scripts/record-demo.py --all
```

## Make your own cabinet

**Python agent** (tools + voice):

```python
from fighter import Agent, serve, tool

@tool("ping", "Return pong.", {"type": "object", "properties": {}, "required": []})
def ping(_args):
    return "pong"

agent = Agent(
    "Frog Coder",
    callsign="HOP",
    workspace=".",
    extra_instructions="Keep replies short. Fix, then verify.",
    extra_tools=[ping],
)
serve(agent)
```

**LÖVE kit** (hero + shots):

```lua
local pad = require("pad")
pad.kit.register({
  name = "slime",
  title = "SLIME",
  callsign = "GOO",
  hero = "frog",     -- ghost | invader | frog | ship | dog | cat | aladdin | harry  (or add draw.hero)
  shot = "note",     -- coin | pellet | bubble | spark | capsule | bone | yarn | note | spell
  think_shot = "spark",
  trail = "spark",
  stage = "agrabah", -- arcade | agrabah | maze | space | pond | kennel | alley | hogwarts
  courier = true,  -- fly there and put it down (ghost default)
  scale = 3.2,
  muzzle = function(demo)
    return demo.x, demo.y + 18
  end,
})
local demo = pad.Demo.new({ kit = "slime" })
pad.client.apply(demo, event, { name = "Slime Coder", callsign = "GOO" })
```

New pixel heroes go on `draw.lua` as `M.myhero(...)`, then set `hero = "myhero"`.

`pad/` is theme, cabinet, kits, chalkboard, Grok event mapper.
`fighter/` is identity, tools, Grok, and `serve(agent)`.

Env: `ARCADE_AGENT`, `ARCADE_HOST`, `ARCADE_PORT`, `ARCADE_DEMO`, `ARCADE_KIT`.

Extra cabinets:

```bash
python3 examples/dog.py
ARCADE_KIT=dog python3 love2d/run.py

python3 examples/cat.py
ARCADE_KIT=cat python3 love2d/run.py

python3 examples/harry.py
ARCADE_KIT=harry python3 love2d/run.py
```

## Needs

- Python 3.10+
- LÖVE 11 (or a browser)
- Fun Grok login (`fun login` or the login button)
- `ffmpeg` with `libx264` only if recording
