# Pixel Defence — Siege of the Crystal Kingdom

**Design document** — the high-level vision, theme, and design philosophy.

> **Looking for rules, units stats, waves?** → See **[GAMEPLAY.md](GAMEPLAY.md)**.

---

## 1. Core Idea

A pixel-art medieval-fantasy tower defence built in **Godot 4.x**.
You are the last Marshal of a fallen kingdom, defending the Heart Crystal from waves of dark-fantasy monsters.

**Pillars:**
- **Pixel-art aesthetic**, moody torch-lit palette (GBA/SNES era).
- **Towers are characters**, not buildings — each is a living soldier with an upgrade tree.
- **Day/Night cycle** (planned) — enemies grow stronger at night.
- **Roguelite meta-progression** (planned) — win levels to feed the Heart Crystal for permanent upgrades.

**Hook:** tower-defence accessibility + roguelite "one more run" pull + the satisfaction of placing & upgrading living units.

---

## 2. Why People Get Addicted 🎯

These are the proven psychological hooks of the genre — we design *for* them:

1. **"One More Wave" pull** 🌊 — short discrete waves, clear win/lose states. "I can do better next time." Keep waves 20–40 seconds.
2. **Build satisfaction & expression** 🧱 — placement is a puzzle; unit synergies (Paladin healing a Guardian wall; Cryomancer freezing enemies for Archers) enable theorycrafting.
3. **Visible progression** 📈 — in-run gold → upgrades → power spikes; meta-run Crystal Shards → permanent unlocks; unit XP → promotions.
4. **Mastery & difficulty curve** 🎮 — easy to learn, hard to master. Chase a "perfect defense" rating per wave.
5. **Variety = replayability** 🎲 — random enemy affixes, branching upgrade trees, daily challenge mode.
6. **Juicy feedback** ✨ — pixel art + screen shake on hits, satisfying death particles, crunchy SFX, damage numbers. *Feel* matters more than features.
7. **Loss feels fair** ⚖️ — roguelite permadeath of units + "you almost made it" moments drive retries. Make defeat obvious ("they broke through HERE").
8. **Short session length** ⏱️ — a run = 15–25 min. Fits lunch-break play.

---

## 3. MVP Scope (v1)

1. **Prototype (done):** core loop, base units, enemy roster, gold economy, win/lose.
2. **Polish (done):** juice (particles, shake, SFX), single-line upgrades, pixel-art sprites, pause/speed.
3. **Structure (done):** main menu + level select, run-restart flow, save/load.
4. **Story arc (done):** 6 maps with cumulative tower unlocks + per-level new enemies + 2 bosses.
5. **Depth (next):** branching upgrade trees, enemy affixes, meta-progression, daily challenge, day/night cycle.

---

## 4. Roadmap

- [x] Core loop: build, wave, gold, lives, win/lose
- [x] 7 units + 13 enemies incl. flyers, armor, regen, fast rushers, 2 bosses
- [x] HUD: gold/wave/lives + build bar + tower panel
- [x] Single-line tower upgrades (2 tiers) + targeting AI (First/Last/Strongest) + sell
- [x] Pixel-art sprites + map props
- [x] Juice: particles, screen shake, hitstop, SFX, damage numbers
- [x] Main menu + level select + run-restart flow
- [x] **Story progression: 6 levels, beat-one-to-unlock-next, saved to disk**
- [x] **Cumulative tower arsenal across the story arc (per-level unlocks)**
- [x] **Per-level new enemies + 2 bosses (Dragon, Hydra)**
- [ ] Branching upgrade trees (Pikeman/Berserker, Crossbow/Ranger, Paladin/Guardian, Pyromancer/Cryomancer)
- [ ] Enemy affixes
- [ ] Meta-progression (Crystal Shards between runs)
- [ ] Daily challenge & bonus maps
- [ ] Day/night cycle

---

## 5. Project Structure

```
pixel_defence/
├── project.godot              # Godot project config + autoloads
├── DESIGN.md                  # this document (vision)
├── GAMEPLAY.md                # rules, units, enemies, waves
├── README.md                  # how to run / play
├── icon.svg
└── src/
    ├── main.tscn / .gd        # root gameplay scene
    ├── autoload/
    │   └── game_manager.gd    # global state: gold, lives, waves
    ├── data/
    │   ├── unit_data.gd       # Resource: tower definition
    │   ├── enemy_data.gd      # Resource: enemy definition
    │   ├── units.gd           # static unit catalogue
    │   └── enemies.gd         # static enemy catalogue
    ├── world/
    │   └── game_world.gd      # map, path, buildable tiles
    ├── towers/
    │   ├── tower.gd / .tscn   # base tower logic
    │   └── projectile.gd/.tscn
    ├── enemies/
    │   ├── enemy.gd / .tscn   # base enemy logic
    ├── ui/
    │   ├── hud.gd / .tscn     # gold / wave / lives + build bar
    └── systems/
        └── wave_spawner.gd    # spawns waves of enemies
```
