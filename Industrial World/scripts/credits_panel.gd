extends CanvasLayer

signal credits_finished

@export var scroll_speed: float = 42.0

@onready var panel_root: Control = $PanelRoot
@onready var scroll_container: ScrollContainer = $PanelRoot/CreditsFrame/ScrollContainer

var is_showing: bool = false
var is_finishing: bool = false
var scroll_position_float: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	panel_root.visible = false


func show_credits() -> void:
	if is_showing:
		return

	visible = true
	panel_root.visible = true
	is_showing = true
	is_finishing = false
	scroll_position_float = 0.0

	GameManager.is_dialogue_active = true
	get_tree().paused = true

	await get_tree().process_frame
	await get_tree().process_frame

	scroll_container.scroll_vertical = 0


func _process(delta: float) -> void:
	if not is_showing:
		return

	if Input.is_action_just_pressed("ui_accept"):
		finish_credits()
		get_viewport().set_input_as_handled()
		return

	var v_scroll_bar := scroll_container.get_v_scroll_bar()
	if v_scroll_bar == null:
		return

	var max_scroll: float = maxf(0.0, v_scroll_bar.max_value)

	if scroll_position_float < max_scroll:
		scroll_position_float += scroll_speed * delta
		scroll_container.scroll_vertical = int(scroll_position_float)
	else:
		finish_credits()


func finish_credits() -> void:
	if is_finishing:
		return

	is_finishing = true
	is_showing = false

	get_tree().paused = false
	GameManager.is_dialogue_active = false

	panel_root.visible = false
	visible = false

	credits_finished.emit()
