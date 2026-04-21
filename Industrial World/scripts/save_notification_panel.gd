extends CanvasLayer

@onready var message_label: Label = $PanelRoot/MainPanel/MessageLabel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false


func show_message(text: String) -> void:
	visible = true
	message_label.text = text


func hide_message() -> void:
	visible = false
