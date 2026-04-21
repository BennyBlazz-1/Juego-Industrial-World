extends Control

@export_file("*.tscn") var new_game_scene_path: String = "res://scenes/chararterselector.tscn"

@onready var new_game_button: Button = $ButtonsArea/CenterContainer/VBoxContainer/NewGameButton
@onready var load_game_button: Button = $ButtonsArea/CenterContainer/VBoxContainer/LoadGameButton
@onready var exit_button: Button = $ButtonsArea/CenterContainer/VBoxContainer/ExitButton


func _ready() -> void:
	get_tree().paused = false
	GameManager.is_dialogue_active = false

	new_game_button.pressed.connect(_on_new_game_button_pressed)
	load_game_button.pressed.connect(_on_load_game_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)

	_update_load_button_visibility()


func _update_load_button_visibility() -> void:
	load_game_button.visible = SaveManager.has_save()


func _on_new_game_button_pressed() -> void:
	SaveManager.prepare_new_game()
	get_tree().change_scene_to_file(new_game_scene_path)


func _on_load_game_button_pressed() -> void:
	SaveManager.load_game()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
