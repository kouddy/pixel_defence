# Pixel Defence — Gameplay

How the game actually plays: the loop, units, enemies, economy, and win/lose conditions.
For the high-level vision, theme, and "why it's fun", see **[DESIGN.md](DESIGN.md)**.

> This document mirrors the live code. Stats below are the exact values in
> `src/data/units.gd`, `enemies.gd`, `upgrades.gd`, `game_manager.gd`, and
> `wave_spawner.gd`. Update code first, then this doc.

---

## Core Loop
```
Plan (place/upgrade units) → Survive Wave → Earn Gold + XP → Rebuild → Repeat
```
Each "day" = a wave. Survive all waves of a map to win.

---

## Display & Map

- **Viewport:** 832×468 px (16:9 landscape, mobile-landscape oriented). The OS
  window scales this canvas to any size via `stretch/mode="viewport"` +
  `aspect="keep"`.
- **Grid:** 32 columns × 18 rows of 26 px tiles — the map fills the viewport
  exactly, so screen coordinates map 1:1 to world positions (no letterboxing).
- **Path:** an S-curve of waypoints running left → right with vertical
  switchbacks, so towers get long horizontal edges to cover. Spawn is off the
  left edge; the castle (goal) sits at the right edge.
- **HUD:** the top stats (gold / wave / lives) and bottom build bar float as
  **transparent overlays** on the map (no opaque bar stealing playfield). Labels
  use dark outlines for legibility over the bright grass.

---

## Defenders (Towers)

The player places these on buildable (grass) tiles along the path.

| Unit       | Role              | Strength                    | Weakness              |
|------------|-------------------|-----------------------------|-----------------------|
| Soldier ⚔️ | Cheap melee block | Holds chokepoints, soaks    | Low range, ground only|
| Archer 🏹  | Ranged single DPS | Hits flyers, long range     | Fragile, low HP       |
| Knight 🛡️ | Tanky frontline   | High HP, slows enemies on hit | Slow attack, costly |
| Wizard 🔮  | AoE magic         | Splash, hits air            | Long cooldown, costly |

### Stats (exact live values)
| Unit    | Cost | Damage | Range | Fire rate | Special |
|---------|------|--------|-------|-----------|---------|
| Soldier | 50   | 8      | 77    | 1.5/s     | Ground only |
| Archer  | 80   | 12     | 160   | 1.2/s     | Hits air |
| Knight  | 110  | 18     | 83    | 1.0/s     | Slows on hit (0.5× for 1.2s) |
| Wizard  | 150  | 22     | 128   | 0.7/s     | Splash radius 48, hits air |

> Ranges were scaled to the narrower 16:9 grid so each tower covers the same
> *relative* fraction of the playfield it did on the old wide map.

### Upgrade system
Each placed tower can be upgraded **2 tiers** (Rank 1 → 2 → 3) for gold. Select a
placed tower (left-click it) to open its info panel on the left, showing current
stats, the next tier's effect, and **Target / Upgrade / Sell** buttons.

- **Upgrade** multiplies the tower's BASE stats (damage / range / fire rate, and
  splash radius for the Wizard). Multipliers stack cumulatively from base, so
  there's no drift on repeat application. Costs scale per tier.
- **Sell** refunds **70%** of all gold invested (base cost + upgrades) and frees
  the tile for rebuilding. **Two-click confirm:** the first click arms a 3-second
  window (button reads "CONFIRM sell?"), the second click completes the sale.

| Unit    | Tier 1 cost | Tier 1 effect                | Tier 2 cost | Tier 2 effect                   |
|---------|-------------|------------------------------|-------------|---------------------------------|
| Soldier | 40          | +DMG, +range, faster swings  | 80          | Veteran: heavy strikes, pace    |
| Archer  | 60          | Eagle eye: +range, +DMG      | 120         | Marksman: rapid fire            |
| Knight  | 80          | Plate armour, heavier blows  | 160         | Champion: deep slow, +DMG       |
| Wizard  | 110         | Wider/hotter explosions      | 220         | Archmage: massive blasts, fast  |

(Tier multipliers: damage ~1.7–1.9, range ~1.15–1.25, fire_rate ~1.15–1.40,
Wizard splash ~1.35–1.40. Upgrades are tuned so investing in position beats
buying a fresh tower per gold.)

> Future: branching upgrade paths (e.g. Soldier → Pikeman / Berserker) once the
> core single-line system is proven fun.

### Targeting AI
Each tower has a **targeting mode** the player can cycle from its panel:

| Mode        | Picks the enemy…                                      |
|-------------|-------------------------------------------------------|
| **First**   | Closest to the exit (most path progress). *Default.*  |
| **Last**    | Furthest from exit (newest spawn in range).           |
| **Strongest**| Highest current HP (progress as tiebreak).           |

Towers still respect range and can't-hit-air rules regardless of mode.

---

## Enemies

| Enemy        | HP   | Speed | Armor | Reward | Special |
|--------------|------|-------|-------|--------|---------|
| Goblin 👺    | 30   | 80    | 0     | 6      | Fast, swarms |
| Skeleton 💀 | 55   | 55    | 2     | 9      | Armored |
| Ghost 👻     | 45   | 70    | 0     | 10     | — |
| Bat 🦇       | 28   | 95    | 0     | 8      | **Flying** |
| Wolf 🐺      | 42   | 130   | 0     | 9      | **Very fast** ground rusher |
| Demon 😈     | 130  | 45    | 4     | 20     | Tanky + armored |
| Troll 👹     | 240  | 38    | 3     | 32     | **Regenerates** 8 HP/s — must be focused |
| Dragon 🐉    | 600  | 40    | 0     | 100    | **Boss**, flying, leaks 5 lives |

- **Armor** reduces each instance of incoming damage by a flat amount (min 0).
- **Flying** enemies bypass ground-only towers (Soldier, Knight).
- **Regeneration**: Trolls heal over time, undoing chip damage — burst them down.
- **Leak damage**: most enemies cost 1 life if they reach the exit; the Dragon costs 5.

---

## Waves (9 waves)

Each wave is a sequence of spawn groups `(enemy, count, interval, gap_after)`.
A wave is cleared when every spawned enemy has left the scene (killed or leaked).

| Wave | Contents | Introduces |
|------|----------|------------|
| 1 | 6 goblins | Basic flow |
| 2 | 8 goblins + 3 skeletons | Armored enemies |
| 3 | 6 goblins + 4 wolves + 3 skeletons | **Speed** — wolves punish slow defences |
| 4 | 8 goblins + 6 bats | **Flyers** — need archers/wizards |
| 5 | 6 skeletons + 5 ghosts + 6 wolves (tight) | Mixed pressure |
| 6 | 8 bats + 1 troll + 12 goblins | **Regen** — focus fire or it heals |
| 7 | 8 wolves + 3 demons + 10 skeletons | Armour + speed together |
| 8 | 8 ghosts + 10 bats + 2 trolls + 3 demons | Sustained pressure |
| 9 | 6 ghosts + 8 wolves + 3 demons + 1 troll + **dragon** | **Boss** |

The player presses **▶ Start Wave** (or **Enter**) to begin each wave. The next
wave can't start until the current one is fully cleared. A **wave preview banner**
("Wave N / 9 — incoming" with the enemy composition) shows at game start and
whenever a new wave begins, so the player can prep (e.g. build archers before
a flyer wave).

---

## Economy

- **Gold** (from kills + wave-clear bonus) → place/upgrade units.
- **Wave-clear bonus**: `30 + 12×(wave−1)` gold for surviving each wave, so the
  economy keeps pace with tougher enemies (kills alone stall in the early game).
- **Sell refund**: 70% of all gold invested in a tower (base + upgrades), with a
  two-click confirm to prevent accidental sells.

Starting gold: **200**. Starting lives: **20**.

---

## Win / Lose

- **Win:** survive all 9 waves of the map.
- **Lose:** enemies leak through and reduce lives to 0.

---

## Controls

- **Click a unit button** in the bottom bar → enter build mode (green/red tile
  follows cursor).
- **Click a green tile** → place the unit (costs gold).
- **Left-click a placed tower** → select it and open the target/upgrade/sell panel.
- **Right-click** → cancel build mode, or deselect the current tower.
- **Enter / ⏎** → start the next wave (build phase only).
- **Space / P** → pause (only during an active wave). The screen dims and shows a
  "PAUSED" overlay; press again to resume. Build/planning time between waves
  needs no pause.
- **M** → toggle sound.
- **▶ 1x / 2x** button (bottom bar) → toggle simulation speed.

> The Pause and Speed buttons remain interactive while paused; Speed is applied
> via `Engine.time_scale` and is reset to 1× when the game exits.
