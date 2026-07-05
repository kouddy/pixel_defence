# 🏰 Pixel Defence — Siege of the Crystal Kingdom

A pixel-art medieval-fantasy tower defence built in **Godot 4.7**.
Defend the Heart Crystal from waves of goblins, skeletons, ghosts, bats, demons and a dragon boss.

See **[DESIGN.md](DESIGN.md)** for the full design document.

---

## ▶ How to run

1. Open **Godot 4.7** (or newer).
2. Import this folder (`pixel_defence/`) as a project — Godot reads `project.godot`.
3. Press **F5** (Play). The game opens on the **main menu**, where you pick a level.

Or from the command line:

```bash
godot --path /path/to/pixel_defence
```

---

## 🎮 How to play

1. **Pick a level** on the main menu (3 maps, each with its own path, economy, and wave script).
2. The **bottom bar** shows your four defender units and their gold cost.
3. Click a unit button to **enter build mode** (a green/red tile follows your mouse).
4. Click any **green tile** on the map to place the unit there (costs gold).
5. **Right-click** to cancel build mode.
6. **Left-click a placed tower** to select it — opens a panel for targeting mode, upgrades, and sell.
7. Earn gold by killing enemies + a wave-clear bonus.
8. Press **▶ Start Wave** (or **Enter**) to send the next wave. Each level has **9 waves**; the last is a Dragon boss.
9. If **lives** (🏰) reach 0, you lose. Clear all waves to win.
10. On victory or defeat, choose **↻ Play Again** (same level) or **☰ Level Select** (back to menu).

### The defenders (7 total — base 4 + 3 story unlocks)
| Unit | Cost | Notes |
|------|------|-------|
| Soldier ⚔️ | 50 | Cheap melee, ground only |
| Archer 🏹 | 80 | Ranged, hits flyers |
| Knight 🛡️ | 110 | Tanky, slows on hit |
| Wizard 🔮 | 150 | AoE splash |
| Crossbowman 🏹 | 95 | Rapid burst single-target *(unlocks level 2)* |
| Frost Mage ❄️ | 140 | AoE splash that slows *(unlocks level 3)* |
| Catapult 💥 | 200 | Long-range heavy siege, can't hit air *(unlocks level 4)* |

Each tower can be upgraded **2 tiers** (Rank 1 → 3) and sold for a 70% refund (two-click confirm).

### Enemy tips
- **Bats** fly — only Archers/Wizards can hit them.
- **Wolves** are very fast ground rushers.
- **Ghosts** walk the path and can be damaged by anything.
- **Demons** and **Skeletons** are armored (reduce each hit by a flat amount).
- **Trolls** regenerate HP — burst them down.
- **Dragon** (final wave) is a flying boss with huge HP — focus fire with wizards & archers.

### Levels (story order — beat one to unlock the next)
| # | Level | Feel | Start gold | Lives | Unlocks |
|---|-------|------|-----------|-------|---------|
| 1 | Crystal Valley | The classic gentle S-curve | 200 | 20 | Base 4 towers |
| 2 | Shadowfen | Tighter zigzag; bats & trolls early | 190 | 18 | Crossbowman 🏹, Cursed Skull |
| 3 | Dragon's Reach | Long serpentine, hardest early ramp | 280 | 18 | Frost Mage ❄️, Wraith |
| 4 | Plaguelands | Twin parallel runs; hellhound packs | 280 | 18 | Catapult 💥, Hellhound |
| 5 | Sunken Crypt | Maze of causeways; banshee wails | 300 | 16 | Banshee |
| 6 | Throne of Ash | The dragon lord's lair; Hydra finale | 320 | 18 | Hydra boss 🐉 |

Towers unlocked on a level stay buildable on every later level — your arsenal
grows across the story. Progress is saved to disk; the menu has a **Reset
Progress** button to start over.

---

## ⌨️ Controls

- **Click unit button** → build mode. **Click green tile** → place. **Right-click** → cancel / deselect.
- **Left-click tower** → select (opens target/upgrade/sell panel).
- **Enter / ⏯** → start next wave (build phase only).
- **Space / P** → pause (only during a wave).
- **M** → toggle sound.
- **▶ 1x / 2x** → simulation speed toggle.

---

## 🗂 Project structure

```
pixel_defence/
├── project.godot              # config + autoloads (main scene = main menu)
├── DESIGN.md                  # game design doc (vision)
├── GAMEPLAY.md                # rules, units, enemies, waves (live values)
├── README.md                  # this file
├── icon.svg
└── src/
    ├── main.tscn / .gd        # root gameplay scene: world + spawner + HUD + input
    ├── autoload/
    │   ├── game_manager.gd    # global: gold, lives, waves, selected_level, scene nav, arsenal
    │   ├── save.gd            # story progression persistence (user://progress.cfg)
    │   ├── fx.gd              # screen shake, hitstop, damage numbers, bursts
    │   └── sfx.gd             # procedural sound effects
    ├── data/
    │   ├── unit_data.gd       # Resource: tower definition
    │   ├── enemy_data.gd      # Resource: enemy definition
    │   ├── units.gd           # catalogue of 7 defender units
    │   ├── enemies.gd         # catalogue of 13 enemy types
    │   └── levels.gd          # catalogue of 6 playable levels + story order
    ├── world/
    │   ├── game_world.gd      # map, path, buildable tiles, placement validation
    │   └── props_layer.gd     # pixel-art props (trees, mountains, castle)
    ├── towers/
    │   ├── tower.gd/.tscn     # placed defender (targeting + firing + upgrades)
    │   └── projectile.gd/.tscn
    ├── enemies/
    │   └── enemy.gd/.tscn     # path follower, takes damage, leaks lives
    ├── ui/
    │   ├── main_menu.tscn/.gd # title screen + level select
    │   ├── hud.gd/.tscn       # top bar (gold/wave/lives) + build bar + tower panel + game-over overlay
    │   └── pause_overlay.gd   # pause dim layer (resume / quit to menu)
    ├── systems/
    │   └── wave_spawner.gd    # spawns waves from the selected level's script
    ├── render/
    │   ├── pixel_art.gd       # ASCII pixel-art patterns + shaded palette
    │   └── pixel_sprite.gd    # renders a PixelArt pattern as crisp pixels
    └── fx/
        ├── damage_number.gd/.tscn
        └── burst_shard.gd/.tscn
```

---

## 🧱 What's implemented

- ✅ **Main menu + level select** with 6 distinct maps in a story arc
- ✅ **Story progression** — beat a level to unlock the next; saved to disk
- ✅ **Run-restart flow**: Play Again (same level) and Level Select from the game-over overlay and pause menu
- ✅ **Cumulative arsenal** — towers unlocked on a level stay buildable on every later level
- ✅ 7 buildable defender units (4 base + 3 story unlocks) with distinct stats & roles
- ✅ 13 enemy types incl. flyers, armor, regen, fast rushers, two bosses
- ✅ Tile-based build placement with path & overlap blocking
- ✅ Gold economy (earn on kill + wave-clear bonus, spend on placement/upgrades)
- ✅ Lives system (enemies that reach the exit cost lives; bosses cost 5–6)
- ✅ 9 hand-authored waves per level + win/lose states
- ✅ **Tower upgrades** (2 tiers) with cumulative stat multipliers
- ✅ **Targeting AI** (First / Last / Strongest)
- ✅ **Sell** with 70% refund and two-click confirm
- ✅ Slow effect (Knight, Frost Mage) and splash damage (Wizard, Frost Mage, Catapult)
- ✅ Pixel-art sprites for all units, enemies, and map props
- ✅ Juice: screen shake, hitstop, damage numbers, particle bursts, muzzle flashes, squash/stretch
- ✅ Pause overlay, 1x/2x speed toggle, procedural SFX, mute

## 🚧 Next steps (see DESIGN.md §4)

- Branching upgrade trees (Pikeman/Berserker, Crossbow/Ranger, Paladin/Guardian, Pyromancer/Cryomancer)
- Enemy affixes (Swift, Armored, Splitting...)
- Meta-progression (Crystal Shards between runs)
- Daily challenge & additional maps
- Day/night cycle
