extends Node2D

@onready var building1_under_construction_map = $building1_under_construction_map
@onready var building1_completed_map = $building1_completed_map
@onready var spawn_from_bodega: Marker2D = $spawn_from_bodega
@onready var spawn_from_nivel2: Marker2D = $spawn_from_nivel2

@onready var man_player: Node2D = $man_player
@onready var woman_player: Node2D = $woman_player

func _ready():
	update_building_1_visual()
	seleccionar_personaje()
	call_deferred("place_player_at_spawn")


func update_building_1_visual() -> void:
	building1_under_construction_map.visible = not GameManager.level1_passed
	building1_completed_map.visible = GameManager.level1_passed


func seleccionar_personaje() -> void:
	if man_player:
		man_player.remove_from_group("player")
	if woman_player:
		woman_player.remove_from_group("player")

	if Global.personaje_seleccionado == 0:
		# HOMBRE ACTIVO
		if woman_player:
			woman_player.queue_free()

		if man_player:
			man_player.visible = true
			man_player.set_process(true)
			man_player.set_physics_process(true)
			man_player.add_to_group("player")
	else:
		# MUJER ACTIVA
		if man_player:
			man_player.queue_free()

		if woman_player:
			woman_player.visible = true
			woman_player.set_process(true)
			woman_player.set_physics_process(true)
			woman_player.add_to_group("player")


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
