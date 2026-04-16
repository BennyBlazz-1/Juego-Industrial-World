extends Control

func _ready() -> void:
	$Timer.wait_time = 2.5
	$Timer.start()

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		cambiar_escena()

func _on_timer_timeout() -> void:
	cambiar_escena()

func cambiar_escena() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
