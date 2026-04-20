extends Node2D

@export var animation_name: StringName = &"actofinal"
@export_range(0.0, 3.0, 0.1) var start_delay: float = 0.5
@export var selected_player_idle_animation: StringName = &"back_idle"
@export_file("*.tscn") var return_scene_path: String = "res://scenes/world.tscn"

@onready var animation_player: AnimationPlayer = get_node_or_null("AnimationPlayer") as AnimationPlayer
@onready var supervisor_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
@onready var cutscene_camera: Camera2D = get_node_or_null("world_camera") as Camera2D
@onready var man_player_node: Node = get_node_or_null("man_player")
@onready var woman_player_node: Node = get_node_or_null("woman_player")


func _ready() -> void:
	GameManager.is_dialogue_active = true

	_resolve_missing_nodes()
	_setup_camera()
	_setup_selected_player()
	_setup_supervisor()

	if animation_player != null and not animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.connect(_on_animation_finished)

	call_deferred("_start_cutscene")


func _resolve_missing_nodes() -> void:
	if cutscene_camera == null:
		cutscene_camera = _find_first_camera(self)

	if supervisor_sprite == null:
		supervisor_sprite = _find_first_animated_sprite(self)


func _find_first_camera(node: Node) -> Camera2D:
	for child in node.get_children():
		if child is Camera2D:
			return child as Camera2D

		var nested_camera := _find_first_camera(child)
		if nested_camera != null:
			return nested_camera

	return null


func _find_first_animated_sprite(node: Node) -> AnimatedSprite2D:
	for child in node.get_children():
		if child is AnimatedSprite2D:
			return child as AnimatedSprite2D

		var nested_sprite := _find_first_animated_sprite(child)
		if nested_sprite != null:
			return nested_sprite

	return null


func _setup_camera() -> void:
	if cutscene_camera == null:
		return

	cutscene_camera.enabled = true
	cutscene_camera.make_current()

	if cutscene_camera.has_method("reset_smoothing"):
		cutscene_camera.reset_smoothing()


func _setup_selected_player() -> void:
	var use_man: bool = Global.personaje_seleccionado == 0

	_configure_player_for_cutscene(man_player_node, use_man)
	_configure_player_for_cutscene(woman_player_node, not use_man)


func _configure_player_for_cutscene(player_node: Node, should_be_visible: bool) -> void:
	if player_node == null:
		return

	if player_node is CanvasItem:
		(player_node as CanvasItem).visible = should_be_visible

	player_node.set_process(false)
	player_node.set_physics_process(false)
	player_node.set_process_input(false)
	player_node.set_process_unhandled_input(false)
	player_node.set_process_unhandled_key_input(false)

	_disable_cameras_recursive(player_node)

	if player_node is CharacterBody2D:
		var body := player_node as CharacterBody2D
		body.velocity = Vector2.ZERO

	if should_be_visible:
		_play_idle_animation(player_node, selected_player_idle_animation)


func _disable_cameras_recursive(node: Node) -> void:
	for child in node.get_children():
		if child is Camera2D:
			(child as Camera2D).enabled = false

		_disable_cameras_recursive(child)


func _play_idle_animation(player_node: Node, animation_to_play: StringName) -> void:
	var sprite := _find_player_sprite(player_node)

	if sprite == null:
		return

	sprite.flip_h = false
	sprite.play(animation_to_play)


func _find_player_sprite(player_node: Node) -> AnimatedSprite2D:
	var sprite := player_node.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if sprite != null:
		return sprite

	return player_node.find_child("AnimatedSprite2D", true, false) as AnimatedSprite2D


func _setup_supervisor() -> void:
	if supervisor_sprite != null:
		supervisor_sprite.play("back_idle")


func _start_cutscene() -> void:
	await get_tree().create_timer(start_delay).timeout

	if animation_player == null:
		_finish_cutscene()
		return

	if animation_player.has_animation(animation_name):
		animation_player.play(animation_name)
	else:
		push_warning("No existe la animación '%s'." % String(animation_name))
		_finish_cutscene()


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name != animation_name:
		return

	_finish_cutscene()


func _finish_cutscene() -> void:
	if supervisor_sprite != null:
		supervisor_sprite.play("back_idle")

	GameManager.final_supervisor_dialogue_enabled = true
	GameManager.is_dialogue_active = false

	if GameManager.return_to_world_after_final_cutscene:
		GameManager.return_to_world_after_final_cutscene = false
		get_tree().change_scene_to_file(return_scene_path)
