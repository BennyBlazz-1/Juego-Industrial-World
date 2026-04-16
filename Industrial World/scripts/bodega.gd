extends Node2D

@onready var spawn_from_world: Marker2D = $spawn_from_world

const PLAYER_SCENE = preload("res://scenes/man_player.tscn")

var player: Node2D

func _ready():
	if not GameManager.level1_passed:
		GameManager.reset_level1()

	crear_player()
	call_deferred("place_player_at_spawn")

func crear_player() -> void:
	player = PLAYER_SCENE.instantiate() as Node2D
	player.add_to_group("player")
	add_child(player)

func place_player_at_spawn() -> void:
	if player == null:
		print("No player en bodega")
		return

	var spawn_name := GameManager.consume_next_spawn()

	if spawn_name == "bodega_from_world":
		player.global_position = spawn_from_world.global_position
	else:
		player.global_position = spawn_from_world.global_position
