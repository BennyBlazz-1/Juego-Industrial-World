extends Node2D

@onready var building2_under_construction_map = $building1_under_construction_map
@onready var building2_completed_map = $building1_completed_map

@onready var building1_under_construction_map = $building2_under_construction_map
@onready var building1_completed_map = $building2_completed_map

@onready var spawn_from_bodega: Marker2D = $spawn_from_bodega
@onready var spawn_from_nivel2: Marker2D = $spawn_from_nivel2

@onready var man_player: Node2D = $man_player


func _ready() -> void:
	update_buildings_visual()
	seleccionar_personaje()
	call_deferred("place_player_at_spawn")


func update_buildings_visual() -> void:
	# Edificio 1
	building1_under_construction_map.visible = not GameManager.level1_passed
	building1_completed_map.visible = GameManager.level1_passed

	# Edificio 2
	building2_under_construction_map.visible = not GameManager.nivel_2_passed
	building2_completed_map.visible = GameManager.nivel_2_passed


func seleccionar_personaje() -> void:
	if man_player:
		man_player.remove_from_group("player")

	if Global.personaje_seleccionado == 0:
		if man_player:
			man_player.visible = true
			man_player.set_process(true)
			man_player.set_physics_process(true)
			man_player.add_to_group("player")
	else:
		if man_player:
			man_player.visible = true
			man_player.set_process(true)
			man_player.set_physics_process(true)
			man_player.add_to_group("player")


func place_player_at_spawn() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D

	if player == null:
		print("ERROR: no hay player en grupo")
		return

	var spawn_name := GameManager.consume_next_spawn()

	if spawn_name == "world_from_bodega":
		player.global_position = spawn_from_bodega.global_position
	elif spawn_name == "spawn_from_nivel2":
		player.global_position = spawn_from_nivel2.global_position
