# AGENTS.md

Guidance for ZCode agents working in this repo. Project-specific facts only —
the README has the full player-facing overview.

## What this is

**Pixel Defence** — a pixel-art medieval-fantasy tower defence built in
**Godot 4.7** (GDScript, GL Compatibility renderer). Defend the Heart Crystal
from waves of enemies across 6+ story-gated levels. The main scene is the
main menu (`res://src/main_menu.tscn`); the game launches into level select.

## Run / edit

- Open in **Godot 4.7** (or newer) and press **F5**, or:
  `godot --path /path/to/pixel_defence`
- There is no CLI build/test/typecheck/lint for the game itself — Godot is the
  compiler. Validate changes by running the project in the editor.
- Progress saves to `user://progress.cfg` (Godot's user data dir, not in repo).

## Source layout (`src/`)

- `autoload/` — global singletons registered in `project.godot`:
  **GameManager** (run state: gold, lives, waves, selected_level, scene nav,
  arsenal), **Save** (story progression), **FX** (screen shake, hitstop,
  damage numbers, bursts), **SFX** (procedural sound). Referenced as bare
  globals (e.g. `GameManager.gold`), not preloaded.
- `data/` — static catalogues of game definitions: `units.gd`, `enemies.gd`,
  `levels.gd`, `upgrades.gd`, plus `unit_data.gd` / `enemy_data.gd` Resources.
- `world/` — map, path, buildable tiles, placement validation (`game_world.gd`).
- `towers/`, `enemies/`, `systems/wave_spawner.gd` — gameplay entities + spawner.
- `ui/` — main menu, HUD, pause overlay.
- `render/` — ASCII pixel-art patterns + `pixel_sprite.gd` renderer.
- `fx/` — damage numbers, burst shards.

**Layer rule:** gameplay state lives in `autoload/`; data lives in `data/`;
scenes/nodes read from those rather than holding canonical state. Keep this
separation when adding features.

## Conventions

- **GDScript style:** tabs for indentation, `class_name` for global classes,
  StringName keys (`&"..."`) in data dictionaries. Follow the surrounding file.
- Unit/enemy stats are **dictionaries of constants** in `data/*.gd` that return
  fresh `UnitData`/`EnemyData` instances so each placed tower can mutate stats
  independently on upgrade. Don't share mutable stat instances.
- **GAMEPLAY.md mirrors the live code.** When stats change in
  `units.gd` / `enemies.gd` / `upgrades.gd` / `game_manager.gd` / `levels.gd` /
  `wave_spawner.gd`, update code **first**, then GAMEPLAY.md to match.
- Docs: `DESIGN.md` = vision; `GAMEPLAY.md` = live rules/values; `README.md`
  = player guide. Read GAMEPLAY.md before touching balance or progression.

## Rendering constraints (don't break these)

Pixel art must stay crisp — these are set in `project.godot`:
- `2d_render/use_pixel_snap=true`
- `textures/canvas_textures/default_texture_filter=0` (nearest)
- `renderer/rendering_method="gl_compatibility"` (also mobile)
- Viewport 832×468, stretch mode `viewport`.

## Asset pipeline (important)

- Sprites live under `assets/towers/` and `assets/enemies/`, named
  `<unit>_<view>_<state>.svg`/`.png` where view ∈ `front|back|left` and
  state ∈ `attack|non_attack` (some units add a weapon, e.g. `prince_front_bow_attack`).
- Raw source PNGs go in `.../source/` subfolders (e.g. `assets/towers/source/`).
  These dirs are marked with a `.gdignore` so Godot does not import them.

### `process-png.js` — crops source PNGs (asset tool, not Godot)

`assets/scripts/process-png.js` is a **Node.js + sharp** script that **crops**
source character art: it strips the near-white/off-white background (sampled
from the four corners, with a tolerance), finds the largest opaque component,
crops to its bounding box, and scales the longer edge to **512px**
(nearest-neighbour, aspect preserved, no padding). It writes results to the
**parent of its own `source/` sibling** — i.e. run it **from inside the
`towers/` (or `enemies/`) directory** so `../source` and `..` resolve correctly.
Run on specific files or the whole folder:

```bash
cd assets/towers
node ../scripts/process-png.js                       # all PNGs in ../source
node ../scripts/process-png.js princess_front_attack.png   # one file
```

Install deps once: `cd assets/scripts && npm install`.
`assets/scripts/node_modules` is **not** gitignored — don't commit churn there.

### `svgo` — optimizes SVGs (asset tool, not Godot)

`svgo` is a dev dependency used to minify/strip the tower & enemy `.svg`
sprites in `assets/towers/` (and `assets/enemies/` if SVGs appear there).
Config is `assets/scripts/svgo.config.js` (`multipass` + `preset-default`).
It is **not** wired into an npm script — invoke the local binary directly:

```bash
cd assets/scripts
./node_modules/.bin/svgo ../towers/some_unit_front_attack.svg   # one file
./node_modules/.bin/svgo -f ../towers/                          # a whole folder
```

Run after importing or regenerating art, before committing. Optimized SVGs keep
the repo small and do not affect how Godot rasterizes them.

## Git notes

- Default branch `main`. The repo is a subdirectory of a larger `godot_game`
  parent; this folder is its own git repo (own `.git`).
- `.zcode/` and `.godot/` are gitignored. `.DS_Store` files appear on macOS —
  ignore them, don't commit.
- Godot generates `.uid` files and `.import` files alongside scenes/assets —
  commit these together with the source they belong to.
