extends Control
## HUD: top bar showing gold, wave, lives; bottom-center build bar with unit buttons.
## Emits build_selected when the player picks a unit to place.
##
## Tower info panel: when a placed tower is selected, a panel opens on the left
## showing its name, rank, stats, and Upgrade/Sell buttons.

signal build_selected(unit_data: UnitData)
signal start_wave_requested
signal upgrade_requested
signal sell_requested
signal pause_requested
signal speed_changed(multiplier: float)

const BTN_SIZE := Vector2(120, 70)
const SPEED_OPTIONS := [1.0, 2.0]

@onready var gold_label: Label = %GoldLabel
@onready var lives_label: Label = %LivesLabel
@onready var wave_label: Label = %WaveLabel
@onready var start_wave_btn: Button = %StartWaveButton
@onready var pause_btn: Button = %PauseButton
@onready var speed_btn: Button = %SpeedButton
@onready var build_container: HBoxContainer = %BuildContainer
@onready var tower_panel: Panel = %TowerPanel
@onready var tp_name: Label = %TPName
@onready var tp_rank: Label = %TPRank
@onready var tp_stats: Label = %TPStats
@onready var tp_note: Label = %TPNote
@onready var tp_target_btn: Button = %TPTargetButton
@onready var tp_upgrade_btn: Button = %TPUpgradeButton
@onready var tp_sell_btn: Button = %TPSellButton
@onready var wave_banner: Panel = %WaveBanner
@onready var wave_banner_title: Label = %Title
@onready var wave_banner_body: Label = %Body
@onready var pause_overlay: ColorRect = %PauseOverlay
@onready var pause_label: Label = %PauseLabel
@onready var pause_hint: Label = %PauseHint

# Speed-control index into SPEED_OPTIONS.
var _speed_idx: int = 0
# Sell-confirm: first click arms, second within the window confirms.
var _sell_armed: bool = false
const SELL_ARM_TIME := 3.0
var _sell_arm_timer: float = 0.0


func _ready() -> void:
	GameManager.gold_changed.connect(_on_gold_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.wave_changed.connect(_on_wave_changed)
	GameManager.game_won.connect(_on_game_won)
	GameManager.game_lost.connect(_on_game_lost)
	_on_gold_changed(GameManager.gold)
	_on_lives_changed(GameManager.lives)
	_on_wave_changed(0, 0)
	_build_unit_buttons()
	start_wave_btn.pressed.connect(func(): start_wave_requested.emit())
	pause_btn.pressed.connect(func(): pause_requested.emit())
	speed_btn.pressed.connect(_on_speed_btn)
	pause_overlay.resume_requested.connect(func(): pause_requested.emit())
	tp_upgrade_btn.pressed.connect(func(): upgrade_requested.emit())
	tp_target_btn.pressed.connect(_on_target_btn)
	tp_sell_btn.pressed.connect(_on_sell_btn)
	tower_panel.visible = false
	pause_overlay.visible = false
	wave_banner.visible = false
	_update_speed_btn()
	# Overlay + labels must process while the tree is paused so the player can
	# see the overlay and read it; the rest of the HUD freezes with the game.
	pause_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_label.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_hint.process_mode = Node.PROCESS_MODE_ALWAYS
	set_can_pause(false)


func _build_unit_buttons() -> void:
	for def in Units.ALL:
		var data := Units.make(def)
		var btn := Button.new()
		btn.custom_minimum_size = BTN_SIZE
		# Color-coded swatch + clean name/cost layout for instant readability.
		btn.text = "● %s\n%d💰" % [data.display_name, data.cost]
		btn.tooltip_text = "%s\nCost: %d gold" % [data.description, data.cost]
		btn.add_theme_font_size_override("font_size", 13)
		# Tint the button text with the unit's identity color so it matches the
		# in-world sprite and the player learns the color -> unit mapping.
		btn.add_theme_color_override("font_color", data.color.lightened(0.2))
		btn.add_theme_color_override("font_hover_color", data.color.lightened(0.4))
		btn.add_theme_color_override("font_pressed_color", data.color)
		# Keep a ref to the unit id so we can refresh affordability each frame.
		btn.set_meta(&"unit_cost", data.cost)
		btn.pressed.connect(func(): _pick(data))
		build_container.add_child(btn)


## Grey out build buttons the player can't afford, so the economy is legible.
## Also refresh the tower-panel Upgrade button affordability while it's open.
func _process(dt: float) -> void:
	for btn in build_container.get_children():
		if not btn is Button:
			continue
		var cost: int = btn.get_meta(&"unit_cost", 0)
		# Buttons without a unit_cost meta (Start/Pause/Speed) are skipped.
		if cost <= 0:
			continue
		var afford: bool = GameManager.gold >= cost
		btn.disabled = not afford
		btn.modulate = Color(1, 1, 1, 0.45) if not afford else Color.WHITE
	# Expire the sell-confirm arm window if it's been a while, so an accidental
	# first click doesn't linger dangerously.
	if _sell_armed:
		_sell_arm_timer -= dt
		if _sell_arm_timer <= 0.0:
			_disarm_sell()
	if tower_panel and tower_panel.visible:
		_refresh_tower_panel_affordability()


func _pick(data: UnitData) -> void:
	build_selected.emit(data)


func set_start_wave_enabled(v: bool) -> void:
	start_wave_btn.disabled = not v


# ============================ SPEED CONTROL ============================

func _on_speed_btn() -> void:
	_speed_idx = (_speed_idx + 1) % SPEED_OPTIONS.size()
	_update_speed_btn()
	speed_changed.emit(SPEED_OPTIONS[_speed_idx])


func _update_speed_btn() -> void:
	var mult: float = SPEED_OPTIONS[_speed_idx]
	speed_btn.text = "▶ %dx" % int(mult)


# ============================ WAVE PREVIEW BANNER ============================

## Show a banner describing the upcoming wave so the player can prep (e.g.
## build archers before a flyer wave). Auto-hides after a few seconds.
func show_wave_preview(index: int, total: int, composition: Dictionary) -> void:
	if index < 1 or index > total:
		wave_banner.visible = false
		return
	wave_banner_title.text = "Wave %d / %d  —  incoming" % [index, total]
	wave_banner_body.text = _format_composition(composition)
	wave_banner.visible = true
	wave_banner.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(wave_banner, "modulate:a", 1.0, 0.25)
	tw.tween_interval(3.5)
	tw.tween_property(wave_banner, "modulate:a", 0.0, 0.4)
	tw.tween_callback(func(): wave_banner.visible = false)


## Summarize each enemy type + count on a single readable line.
func _format_composition(composition: Dictionary) -> String:
	if composition.is_empty():
		return "Unknown forces"
	var parts := PackedStringArray()
	# Sort by count desc so the biggest threat reads first.
	var keys := composition.keys()
	keys.sort_custom(func(a, b): return composition[a] > composition[b])
	for id in keys:
		var def := Enemies.by_id(id)
		parts.append("%s ×%d" % [def.display_name, composition[id]])
	return ", ".join(parts)


# ============================ TARGETING + SELL CONFIRM ============================

func _on_target_btn() -> void:
	var main := get_tree().current_scene
	if main != null and main.get("_selected_tower") != null:
		var sel: Node2D = main.get("_selected_tower")
		if is_instance_valid(sel) and sel.has_method("cycle_target_mode"):
			sel.cycle_target_mode()


func _on_sell_btn() -> void:
	if _sell_armed:
		# Second click within the window: confirm the sale.
		_disarm_sell()
		sell_requested.emit()
	else:
		# First click: arm — require a second click to actually sell.
		_sell_armed = true
		_sell_arm_timer = SELL_ARM_TIME
		tp_sell_btn.text = "CONFIRM sell?"
		tp_sell_btn.modulate = Color(1.0, 0.6, 0.4)


func _disarm_sell() -> void:
	_sell_armed = false
	tp_sell_btn.modulate = Color.WHITE


func _on_gold_changed(amount: int) -> void:
	gold_label.text = "💰 %d" % amount


func _on_lives_changed(lives: int) -> void:
	lives_label.text = "🏰 %d" % lives


func _on_wave_changed(idx: int, total: int) -> void:
	if total == 0:
		wave_label.text = "Wave —"
	else:
		wave_label.text = "Wave %d/%d" % [idx, total]


## Floating "+bonus gold" notice that rises from the gold readout on wave clear.
func show_wave_bonus(_wave: int, amount: int) -> void:
	var lbl := Label.new()
	lbl.text = "+%d bonus!" % amount
	lbl.add_theme_color_override("font_color", Color(1, 0.92, 0.4))
	lbl.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.03, 1))
	lbl.add_theme_constant_override("outline_size", 4)
	lbl.add_theme_font_size_override("font_size", 20)
	lbl.position = gold_label.global_position + Vector2(20, 8)
	add_child(lbl)
	var tw := lbl.create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y - 40, 0.9).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.9)
	tw.tween_callback(lbl.queue_free)


func _on_game_won() -> void:
	wave_label.text = "VICTORY!"
	tower_panel.visible = false
	SFX.victory()


func _on_game_lost() -> void:
	wave_label.text = "DEFEAT..."
	tower_panel.visible = false
	SFX.defeat()


# ============================ TOWER INFO PANEL ============================

## Show (or hide, if tower is null) the upgrade/sell panel for a tower.
func show_tower_panel(tower: Node2D) -> void:
	if not is_instance_valid(tower) or not tower.has_method("next_upgrade_cost"):
		tower_panel.visible = false
		_disarm_sell()
		return
	tower_panel.visible = true
	_disarm_sell()
	var data: UnitData = tower.data
	tp_name.text = data.display_name
	tp_name.add_theme_color_override("font_color", data.color.lightened(0.2))
	tp_rank.text = "Rank %d / %d" % [tower.level + 1, Upgrades.MAX_LEVEL + 1]
	# Current stats, formatted for readability.
	var dmg := "%d" % [int(round(data.damage))]
	var atk: String
	match data.attack_type:
		UnitData.AttackType.MELEE:      atk = "Melee"
		UnitData.AttackType.PROJECTILE: atk = "Arrow"
		UnitData.AttackType.SPLASH:     atk = "Splash"
	tp_stats.text = "DMG %s   RNG %d\nRATE %.1f/s   %s" % [dmg, int(data.range_px), data.fire_rate, atk]
	tp_note.text = tower.next_tier_note()
	tp_target_btn.text = "◎ Target: %s" % (tower.target_mode_label() if tower.has_method("target_mode_label") else "First")
	_refresh_tower_panel_affordability()


func _refresh_tower_panel_affordability() -> void:
	# Reach the selected tower via Main's property; the panel may persist briefly
	# after a tower is sold/freed, so bail out gracefully in that case.
	var main := get_tree().current_scene
	var sel: Node2D = null
	if main != null and main.get("_selected_tower") != null:
		sel = main.get("_selected_tower")
	if not is_instance_valid(sel):
		tower_panel.visible = false
		return
	# Keep targeting label in sync if the player cycled it.
	if sel.has_method("target_mode_label"):
		tp_target_btn.text = "◎ Target: %s" % sel.target_mode_label()
	if sel.is_maxed():
		tp_upgrade_btn.disabled = true
		tp_upgrade_btn.text = "MAX"
	else:
		var cost: int = sel.next_upgrade_cost()
		var afford := GameManager.gold >= cost
		tp_upgrade_btn.disabled = not afford
		tp_upgrade_btn.text = "▲ Upgrade\n%d💰" % cost
	# Don't clobber the armed "CONFIRM sell?" label.
	if not _sell_armed:
		var refund: int = sel.sell_value()
		tp_sell_btn.text = "Sell\n+%d💰" % refund


# ============================ PAUSE ============================

## Show or hide the dimmed pause overlay + "PAUSED" text.
func show_pause_overlay(v: bool) -> void:
	pause_overlay.visible = v
	pause_label.visible = v
	pause_hint.visible = v
	# Keep the button label in sync with the paused state.
	pause_btn.text = "▶ Resume" if v else "⏸ Pause"


## Toggle whether the player is allowed to pause right now (only during a wave).
## Shows the Pause button during a wave and hides it during the build phase, so
## it's never a dead control.
func set_can_pause(v: bool) -> void:
	pause_btn.visible = v
	pause_hint.text = "Click anywhere, press Space / P, or hit Resume" if v else ""
