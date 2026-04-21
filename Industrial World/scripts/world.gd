extends Node2D

const FINAL_SUPERVISOR_WORLD_POSITION: Vector2 = Vector2(1233, 537)
const SUPERVISOR_INITIAL_WORLD_POSITION: Vector2 = Vector2(1296, 999)

@onready var building2_under_construction_map = $building1_under_construction_map
@onready var building2_completed_map = $building1_completed_map

@onready var building1_under_construction_map = $building2_under_construction_map
@onready var building1_completed_map = $building2_completed_map

@onready var spawn_from_bodega: Marker2D = $spawn_from_bodega
@onready var spawn_from_nivel2: Marker2D = $spawn_from_nivel2

@onready var man_player: Node2D = $man_player
@onready var supervisor_root: Node2D = $boss_player
@onready var supervisor_sprite: AnimatedSprite2D = $boss_player/AnimatedSprite2D
@onready var credits_panel: CanvasLayer = $CreditsPanel


func _ready() -> void:
	update_buildings_visual()
	seleccionar_personaje()
	place_player_at_spawn()
	apply_supervisor_world_state()

	if credits_panel != null and not credits_panel.credits_finished.is_connected(_on_credits_finished):
		credits_panel.credits_finished.connect(_on_credits_finished)


func update_buildings_visual() -> void:
	building1_under_construction_map.visible = not GameManager.level1_passed
	building1_completed_map.visible = GameManager.level1_passed

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

	SaveManager.apply_pending_loaded_state(self)


func apply_supervisor_world_state() -> void:
	if supervisor_root == null:
		return

	if GameManager.postgame_supervisor_dialogue_enabled:
		supervisor_root.visible = true
		supervisor_root.global_position = SUPERVISOR_INITIAL_WORLD_POSITION

		if supervisor_sprite != null:
			supervisor_sprite.play("front_idle")
	elif GameManager.final_supervisor_dialogue_enabled:
		supervisor_root.visible = true
		supervisor_root.global_position = FINAL_SUPERVISOR_WORLD_POSITION

		if supervisor_sprite != null:
			supervisor_sprite.play("back_idle")


func start_endgame_credits() -> void:
	if credits_panel == null:
		return

	if credits_panel.has_method("show_credits"):
		credits_panel.call("show_credits")


func _on_credits_finished() -> void:
	GameManager.credits_played = true
	GameManager.final_supervisor_dialogue_enabled = false
	GameManager.postgame_supervisor_dialogue_enabled = true

	if supervisor_root != null:
		supervisor_root.visible = true
		supervisor_root.global_position = SUPERVISOR_INITIAL_WORLD_POSITION

	if supervisor_sprite != null:
		supervisor_sprite.play("front_idle")
