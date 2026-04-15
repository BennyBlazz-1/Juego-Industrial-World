extends Node2D

@onready var spawn_from_world: Marker2D = $spawn_from_world

func _ready():
	if not GameManager.level1_passed:
		GameManager.reset_level1()

	call_deferred("place_player_at_spawn")

func place_player_at_spawn() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	var spawn_name := GameManager.consume_next_spawn()

	if spawn_name == "spawn_from_world":
		player.global_position = spawn_from_world.global_position
