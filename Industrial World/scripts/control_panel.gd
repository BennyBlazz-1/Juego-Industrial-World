extends CanvasLayer

@onready var close_button: Button = $PanelRoot/MainPanel/CloseButton

var is_open: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	is_open = false

	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo and event.keycode == KEY_C:
			if GameManager.is_dialogue_active and not is_open:
				return

			toggle_panel()
			get_viewport().set_input_as_handled()


func toggle_panel() -> void:
	if is_open:
		close_panel()
	else:
		open_panel()


func open_panel() -> void:
	visible = true
	is_open = true
	get_tree().paused = true

	if close_button:
		close_button.grab_focus()


func close_panel() -> void:
	get_tree().paused = false
	visible = false
	is_open = false


func _on_close_button_pressed() -> void:
	close_panel()


func _exit_tree() -> void:
	if get_tree():
		get_tree().paused = false
