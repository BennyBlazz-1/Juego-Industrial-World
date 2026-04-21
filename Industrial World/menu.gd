extends Control

@export_file("*.tscn") var new_game_scene_path: String = "res://scenes/chararterselector.tscn"

@onready var new_game_button: Button = $ButtonsArea/CenterContainer/VBoxContainer/NewGameButton
@onready var load_game_button: Button = $ButtonsArea/CenterContainer/VBoxContainer/LoadGameButton
@onready var exit_button: Button = $ButtonsArea/CenterContainer/VBoxContainer/ExitButton


func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game_button_pressed)
	load_game_button.pressed.connect(_on_load_game_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)

	# Por ahora, hasta que hagamos el sistema real de guardado.
	load_game_button.visible = false


func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file(new_game_scene_path)


func _on_load_game_button_pressed() -> void:
	# Aquí después irá la lógica real de cargar partida.
	pass


func _on_exit_button_pressed() -> void:
	get_tree().quit()
