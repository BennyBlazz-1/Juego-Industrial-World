extends Node2D

@onready var building1_under_construction_map = $building1_under_construction_map
@onready var building1_completed_map = $building1_completed_map
@onready var spawn_from_bodega: Marker2D = $spawn_from_bodega
@onready var spawn_from_nivel2: Marker2D = $spawn_from_nivel2

var personajes = [
	preload("res://scenes/man_player.tscn"),
	preload("res://scenes/woman_player.tscn"),
]

func _ready():
	update_building_1_visual()
	call_deferred("place_player_at_spawn")

func update_building_1_visual():
	building1_under_construction_map.visible = not GameManager.level1_passed
	building1_completed_map.visible = GameManager.level1_passed

func place_player_at_spawn() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	var spawn_name := GameManager.consume_next_spawn()

	if spawn_name == "world_from_bodega":
		player.global_position = spawn_from_bodega.global_position
	elif spawn_name == "spawn_from_nivel2":
		player.global_position = spawn_from_nivel2.global_position
