extends ColorRect
## PauseOverlay: a full-screen dim layer shown while the game is paused.
##
## Runs with PROCESS_MODE_ALWAYS and catches mouse + keyboard input so the
## player can ALWAYS resume, even though the rest of the scene tree is frozen
## (Main._unhandled_input and the build buttons don't fire while paused, which
## is why unpause has to live here on an always-processing node).
##
## Also offers a "Quit to Menu" button so the player can abandon a run mid-wave.

signal resume_requested
signal quit_to_menu_requested


func _ready() -> void:
	# Must process during pause, and must STOP mouse events so a click anywhere
	# is caught by us (instead of passing through to the frozen game below).
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP


func _gui_input(event: InputEvent) -> void:
	# Click anywhere on the dim overlay (but not on a button) to resume.
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		resume_requested.emit()


func _unhandled_input(event: InputEvent) -> void:
	# Only handle the resume keys while we're actually shown (paused).
	if not visible:
		return
	if event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_P):
		resume_requested.emit()
