# 🏰 Pixel Defence — Siege of the Crystal Kingdom

A pixel-art medieval-fantasy tower defence built in **Godot 4.7**.
Defend the Heart Crystal from waves of goblins, skeletons, ghosts, bats, demons and a dragon boss.

See **[DESIGN.md](DESIGN.md)** for the full design document.

---

## ▶ How to run

1. Open **Godot 4.7** (or newer).
2. Import this folder (`pixel_defence/`) as a project — Godot reads `project.godot`.
3. Press **F5** (Play). The main scene is already set to `src/main.tscn`.

Or from the command line:

```bash
godot --path /path/to/pixel_defence
```

---

## 🎮 How to play

- The **bottom bar** shows your four defender units and their gold cost.
- Click a unit button to **enter build mode** (a green/red tile follows your mouse).
- Click any **green tile** on the map to place the unit there (costs gold).
- **Right-click** to cancel build mode.
- Earn gold by killing enemies.
- Press **▶ Start Wave** to send the next wave. There are **6 waves** — wave 6 is the Dragon boss.
- If **lives** (🏰) reach 0, you lose. Clear all waves to win.

### The defenders
| Unit | Cost | Notes |
|------|------|-------|
| Soldier ⚔️ | 50 | Cheap melee, ground only |
| Archer 🏹 | 80 | Ranged, hits flyers |
| Knight 🛡️ | 120 | Tanky, slows on hit |
| Wizard 🔮 | 150 | AoE splash |

### Enemy tips
- **Bats** fly — only Archers/Wizards can hit them.
- **Ghosts** walk the path and ignore melee blockers' slowing but can still be damaged.
- **Demons** are armored (need high damage).
- **Dragon** (wave 6) is a flying boss with huge HP — focus fire with wizards & archers.

---

## 🗂 Project structure

```
pixel_defence/
├── project.godot              # config + autoloads
├── DESIGN.md                  # game design doc
├── README.md                  # this file
├── icon.svg
└── src/
    ├── main.tscn / .gd        # root scene: world + spawner + HUD + input
    ├── autoload/
    │   └── game_manager.gd    # global: gold, lives, waves (singleton)
    ├── data/
    │   ├── unit_data.gd       # Resource: tower definition
    │   ├── enemy_data.gd      # Resource: enemy definition
    │   ├── units.gd           # catalogue of 4 defender units
    │   └── enemies.gd         # catalogue of 6 enemy types
    ├── world/
    │   └── game_world.gd      # map, path, buildable tiles, placement validation
    ├── towers/
    │   ├── tower.gd/.tscn     # placed defender (targeting + firing)
    │   └── projectile.gd/.tscn
    ├── enemies/
    │   └── enemy.gd/.tscn     # path follower, takes damage, leaks lives
    ├── ui/
    │   └── hud.gd/.tscn       # top bar (gold/wave/lives) + build bar
    └── systems/
        └── wave_spawner.gd    # 6 predefined waves with spawn groups
```

---

## 🧱 What's implemented (MVP)

- ✅ 4 buildable defender units with distinct stats & attack types (melee / projectile / splash)
- ✅ 6 enemy types incl. flyers, armor, and a dragon boss
- ✅ Tile-based build placement with path & overlap blocking
- ✅ Gold economy (earn on kill, spend on placement)
- ✅ Lives system (enemies that reach the exit cost lives)
- ✅ 6 hand-authored waves + win/lose states
- ✅ Targeting AI (towers fire on the enemy closest to the exit)
- ✅ Slow effect (Knight) and splash damage (Wizard)
- ✅ HP bars and build placement hint

## 🚧 Next steps (see DESIGN.md §MVP)

- Unit upgrade trees (Pikeman/Berserker, Crossbow/Ranger, etc.)
- Enemy affixes (Swift, Armored, Splitting...)
- Pixel-art sprites to replace the ColorRect placeholders
- Juice: screen shake, particles, SFX, damage numbers
- Meta-progression (Crystal Shards between runs)
- Multiple maps & daily challenge
