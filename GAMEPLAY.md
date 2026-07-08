# Pixel Defence — Gameplay

How the game actually plays: the loop, units, enemies, economy, and win/lose conditions.
For the high-level vision, theme, and "why it's fun", see **[DESIGN.md](DESIGN.md)**.

> This document mirrors the live code. Stats below are the exact values in
> `src/data/units.gd`, `enemies.gd`, `upgrades.gd`, `game_manager.gd`,
> `levels.gd`, and `wave_spawner.gd`. Update code first, then this doc.

---

## Core Loop
```
Pick Level → Plan (place/upgrade units) → Survive Wave → Earn Gold → Rebuild → Repeat → Win → unlock next level (saved)
```
Each "day" = a wave. Survive all waves of a map to win and unlock the next.

---

## Story Progression

Levels are gated in story order. You start with only **Crystal Valley** unlocked.
Beating a level permanently unlocks the next (saved to disk at
`user://progress.cfg` — your progress survives quitting). The menu's **↺ Reset
Progress** button wipes the save so you can replay from level 1.

The story arc is also an **escalating arsenal**: towers unlocked on a level stay
buildable on every later level (cumulative, classic TD). Enemies are simply
whatever a level's wave script references — new foes debut as the story moves on.

| # | Level | Path | Start gold | Lives | Unlocks tower | New enemy |
|---|-------|------|-----------|-------|---------------|-----------|
| 1 | **Crystal Valley** | Gentle S-curve | 200 | 20 | Soldier, Archer, Knight, Wizard *(base 4)* | — |
| 2 | **Shadowfen** | Tighter zigzag | 190 | 18 | Crossbowman | Cursed Skull |
| 3 | **Dragon's Reach** | Long serpentine | 280 | 18 | Frost Mage | Wraith |
| 4 | **Plaguelands** | Twin parallel runs | 280 | 18 | Catapult | Hellhound |
| 5 | **Sunken Crypt** | Maze of causeways | 300 | 16 | — *(full arsenal)* | Banshee |
| 6 | **Throne of Ash** | Long sweeping approach | 320 | 18 | — *(arc-1 finale)* | Hydra *(boss)* |
| 7 | **Cursed Abbey** | Cloister march | 320 | 18 | Cleric | Zombie, Vampire |
| 8 | **Sandstorm Vaults** | Wide desert U | 340 | 18 | Paladin | Mummy |
| 9 | **War Camp** | Staggered siege descent | 360 | 17 | Bard | Orc |
| 10 | **Witchwood** | Winding forest path | 380 | 16 | Alchemist | Witch |
| 11 | **Stone Keep** | Keep circuit loop | 400 | 16 | Prince | Gargoyle |
| 12 | **Gates of the Abyss** | Grand sweep, two switchbacks | 420 | 18 | Princess | Demon Lord *(final boss)* |

The wave table below describes **Crystal Valley** (the canonical opening map).
Other levels use the same enemy roster in different compositions/order — see
`levels.gd` for their exact scripts.

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
  use dark outlines for legibility over the bright grass. The bottom **build bar
  wraps to a second row** when the tower roster outgrows one line (it holds up to
  all 13 towers on the finale), so every tower stays selectable.

---

## Defenders (Towers)

The player places these on buildable (grass) tiles along the path. The base
four are available from level 1; the rest unlock as the story progresses (see
the table above) and stay buildable on every later level.

| Unit            | Role              | Strength                    | Weakness              |
|-----------------|-------------------|-----------------------------|-----------------------|
| Soldier ⚔️      | Cheap melee block | Holds chokepoints, soaks    | Low range, ground only|
| Archer 🏹       | Ranged single DPS | Hits flyers, long range     | Fragile, low HP       |
| Knight 🛡️      | Tanky frontline   | High HP, slows enemies on hit | Slow attack, costly |
| Wizard 🔮       | AoE magic         | Splash, hits air            | Long cooldown, costly |
| Crossbowman 🏹  | Burst single DPS  | Very fast fire rate         | Shorter range than Archer |
| Frost Mage ❄️   | AoE + slow        | Splash that slows everyone hit | Lower damage than Wizard |
| Catapult 💥     | Long-range siege  | Huge splash, very long range | Very slow reload, can't hit air |
| Cleric ✨       | Holy AoE support  | Splash that dazzles + slows | Low damage per hit |
| Paladin 🛡️     | Heavy holy melee  | Deep slow, big hits         | Costly, ground only |
| Bard 🎵         | Crowd control     | Wide splash, lingering slow | Very low damage |
| Alchemist 🧪    | Lobbed splash     | Arcs over the front, hits air | Smaller splash radius |
| Prince 🏹       | Royal marksman    | Fast accurate shots, hits air | Shorter range than Archer |
| Princess ✨     | Enchanted bolts   | Long range, slows on hit, hits air | Moderate damage |

### Stats (exact live values)
| Unit        | Cost | Damage | Range | Fire rate | Special |
|-------------|------|--------|-------|-----------|---------|
| Soldier     | 50   | 8      | 77    | 1.5/s     | Ground only |
| Archer      | 80   | 12     | 160   | 1.2/s     | Hits air |
| Knight      | 110  | 18     | 83    | 1.0/s     | Slows on hit (0.5× for 1.2s) |
| Wizard      | 150  | 22     | 128   | 0.7/s     | Splash radius 48, hits air |
| Crossbowman | 95   | 10     | 140   | 2.0/s     | Hits air |
| Frost Mage  | 140  | 12     | 120   | 0.9/s     | Splash 52, slows (0.55× for 1.5s), hits air |
| Catapult    | 200  | 40     | 200   | 0.35/s    | Splash 70, ground only |
| Cleric      | 130  | 14     | 120   | 0.9/s     | Splash 44, slows (0.6× for 1.2s), hits air |
| Paladin     | 170  | 26     | 90    | 0.8/s     | Slows on hit (0.45× for 1.5s), ground only |
| Bard        | 120  | 10     | 110   | 1.6/s     | Splash 50, slows (0.7× for 2.0s), hits air |
| Alchemist   | 160  | 18     | 130   | 1.0/s     | Splash 42, hits air |
| Prince      | 190  | 24     | 100   | 1.2/s     | Hits air |
| Princess    | 150  | 16     | 150   | 1.1/s     | Slows on hit (0.55× for 1.0s), hits air |

> Ranges were scaled to the narrower 16:9 grid so each tower covers the same
> *relative* fraction of the playfield it did on the old wide map.

### Upgrade system
Each placed tower can be upgraded **2 tiers** (Rank 1 → 2 → 3) for gold. Select a
placed tower (left-click it) to open its info panel on the left, showing current
stats, the next tier's effect, and **Target / Upgrade / Sell** buttons.

- **Upgrade** multiplies the tower's BASE stats (damage / range / fire rate, and
  splash radius for splash towers). Multipliers stack cumulatively from base, so
  there's no drift on repeat application. Costs scale per tier.
- **Sell** refunds **70%** of all gold invested (base cost + upgrades) and frees
  the tile for rebuilding. **Two-click confirm:** the first click arms a 3-second
  window (button reads "CONFIRM sell?"), the second click completes the sale.

| Unit        | Tier 1 cost | Tier 1 effect                | Tier 2 cost | Tier 2 effect                   |
|-------------|-------------|------------------------------|-------------|---------------------------------|
| Soldier     | 40          | +DMG, +range, faster swings  | 80          | Veteran: heavy strikes, pace    |
| Archer      | 60          | Eagle eye: +range, +DMG      | 120         | Marksman: rapid fire            |
| Knight      | 80          | Plate armour, heavier blows  | 160         | Champion: deep slow, +DMG       |
| Wizard      | 110         | Wider/hotter explosions      | 220         | Archmage: massive blasts, fast  |
| Crossbowman | 70          | Cranked draw: faster reload  | 140         | Marksman: a bolt for every throat |
| Frost Mage  | 90          | Deeper frost: wider chill    | 180         | Blizzard: the field turns on them |
| Catapult    | 120         | Heavier shot: bigger blasts  | 240         | Siege master: the ground shatters |
| Cleric      | 90          | Brighter halo: wider dazzle  | 180         | High priest: holy light lays low |
| Paladin     | 110         | Blessed plate: deeper slow   | 220         | Templar: hammer of dawn         |
| Bard        | 80          | Louder chorus: lingering drag| 160         | Virtuoso: a symphony stops armies |
| Alchemist   | 100         | Stronger reagents: bigger blasts | 200     | Master chemist: volatile yield  |
| Prince      | 130         | Royal drill: faster volleys  | 260         | Warrior king: every shot lands  |
| Princess    | 100         | Keener enchantments: longer bolts | 200    | Sovereign of frost and starlight |

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

The base roster debuts in levels 1–3; new foes appear as the story continues.

| Enemy           | HP   | Speed | Armor | Reward | Special |
|-----------------|------|-------|-------|--------|---------|
| Goblin 👺       | 30   | 80    | 0     | 6      | Fast, swarms |
| Skeleton 💀    | 55   | 55    | 2     | 9      | Armored |
| Ghost 👻        | 45   | 70    | 0     | 10     | — |
| Bat 🦇          | 28   | 95    | 0     | 8      | **Flying** |
| Wolf 🐺         | 42   | 130   | 0     | 9      | **Very fast** ground rusher |
| Demon 😈        | 130  | 45    | 4     | 20     | Tanky + armored |
| Troll 👹        | 240  | 38    | 3     | 32     | **Regenerates** 8 HP/s — must be focused |
| Dragon 🐉       | 600  | 40    | 0     | 100    | **Boss**, flying, leaks 5 lives |
| Cursed Skull 💀 | 70   | 50    | 3     | 12     | Heavier-armored skeleton *(level 2)* |
| Wraith 👁️      | 35   | 105   | 0     | 11     | **Flying**, very fast *(level 3)* |
| Hellhound 🔥    | 60   | 140   | 2     | 14     | **Very fast** + armored *(level 4)* |
| Banshee 😱      | 90   | 60    | 0     | 16     | HP sponge, no special trick *(level 5)* |
| Hydra 🐉        | 900  | 35    | 0     | 150    | **Arc-1 boss**, flying, leaks 6 lives *(level 6)* |
| Zombie 🧟       | 90   | 35    | 1     | 10     | Slow, high-HP wall *(level 7)* |
| Vampire 🦇      | 80   | 70    | 0     | 15     | **Regenerates** 6 HP/s *(level 7)* |
| Mummy 🔼        | 120  | 45    | 3     | 14     | Heavily armored *(level 8)* |
| Orc 👹          | 110  | 60    | 2     | 14     | Armored infantry *(level 9)* |
| Witch 🧙        | 60   | 75    | 0     | 16     | **Flying**, frail *(level 10)* |
| Gargoyle 🗿     | 150  | 55    | 4     | 22     | **Flying** + heavily armored *(level 11)* |
| Demon Lord 👹   | 1100 | 35    | 0     | 200    | **Final boss**, flying, leaks 7 lives *(level 12)* |

- **Armor** reduces each instance of incoming damage by a flat amount (min 0).
- **Flying** enemies bypass ground-only towers (Soldier, Knight, Catapult, Paladin).
- **Regeneration**: Trolls (8 HP/s) and Vampires (6 HP/s) heal over time, undoing
  chip damage — burst them down.
- **Leak damage**: most enemies cost 1 life if they reach the exit; the Dragon
  costs 5, the Hydra 6, the Demon Lord 7.

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

Starting gold and lives are **per-level** (see the Levels table above); Crystal
Valley starts with 200 gold and 20 lives.

---

## Win / Lose

- **Win:** survive all 9 waves of the map.
- **Lose:** enemies leak through and reduce lives to 0.

---

## Controls

- **Main menu**: click a level card to start a run on that map.
- **Click a unit button** in the bottom bar → enter build mode (green/red tile
  follows cursor).
- **Click a green tile** → place the unit (costs gold).
- **Left-click a placed tower** → select it and open the target/upgrade/sell panel.
- **Right-click** → cancel build mode, or deselect the current tower.
- **Enter / ⏎** → start the next wave (build phase only).
- **Space / P** → pause (only during an active wave). The screen dims and shows a
  "PAUSED" overlay with a **Quit to Menu** button; press again to resume.
  Build/planning time between waves needs no pause.
- **M** → toggle sound.
- **▶ 1x / 2x** button (bottom bar) → toggle simulation speed.
- **Game over**: on victory or defeat, an overlay offers **↻ Play Again**
  (restarts the same level) and **☰ Level Select** (returns to the main menu).

> The Pause and Speed buttons remain interactive while paused; Speed is applied
> via `Engine.time_scale` and is reset to 1× when the game exits or returns to
> the menu.
