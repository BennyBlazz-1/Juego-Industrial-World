extends Node2D

@onready var spawn_from_world: Marker2D = get_node_or_null("spawn_from_world")

func _ready() -> void:
	call_deferred("place_player_at_spawn")

func place_player_at_spawn() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	if spawn_from_world == null:
		push_error("No existe el nodo 'spawn_from_world' en nivel_2.tscn")
		return

	var spawn_name := GameManager.consume_next_spawn()

	if spawn_name == "spawn_from_world":
		player.global_position = spawn_from_world.global_position
