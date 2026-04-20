extends CanvasLayer

@onready var close_button: Button = $PanelRoot/CloseButton

func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)
	visible = false

func show_panel() -> void:
	visible = true
	GameManager.is_dialogue_active = true

func hide_panel() -> void:
	visible = false
	GameManager.is_dialogue_active = false

func _on_close_button_pressed() -> void:
	hide_panel()
