extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var intro_man: AnimatedSprite2D = $AnimatedSprite2D
@onready var intro_woman: AnimatedSprite2D = $AnimatedSprite2D2

@export_file("*.tscn") var next_scene_path: String = "res://scenes/world.tscn"
@export var intro_animation_name: String = "act1"

var usar_mujer_en_intro: bool = false


func _ready() -> void:
	configurar_personaje_intro()

	if not animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.connect(_on_animation_finished)

	animation_player.play(intro_animation_name)


func _process(_delta: float) -> void:
	if usar_mujer_en_intro:
		sincronizar_mujer_con_hombre()


func configurar_personaje_intro() -> void:
	usar_mujer_en_intro = Global.personaje_seleccionado == 1

	if usar_mujer_en_intro:
		intro_man.visible = false
		intro_woman.visible = true
		copiar_estado_sprite(intro_man, intro_woman)
	else:
		intro_man.visible = true
		intro_woman.visible = false


func sincronizar_mujer_con_hombre() -> void:
	copiar_estado_sprite(intro_man, intro_woman)


func copiar_estado_sprite(origen: AnimatedSprite2D, destino: AnimatedSprite2D) -> void:
	destino.position = origen.position
	destino.rotation = origen.rotation
	destino.scale = origen.scale
	destino.flip_h = origen.flip_h
	destino.flip_v = origen.flip_v
	destino.z_index = origen.z_index
	destino.modulate = origen.modulate
	destino.speed_scale = origen.speed_scale

	var anim_actual: StringName = origen.animation

	if destino.sprite_frames != null and destino.sprite_frames.has_animation(anim_actual):
		if destino.animation != anim_actual:
			destino.play(anim_actual)
		elif not destino.is_playing():
			destino.play(anim_actual)

		destino.frame = origen.frame
		destino.frame_progress = origen.frame_progress


func _on_animation_finished(anim_name: StringName) -> void:
	if String(anim_name) == intro_animation_name:
		get_tree().change_scene_to_file(next_scene_path)
