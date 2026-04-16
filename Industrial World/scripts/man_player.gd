extends CharacterBody2D

const speed = 200
var current_dir = "down"

@onready var world_camera: Camera2D = $world_camera
@onready var bodega_camera: Camera2D = $bodega_camera
@onready var nivel2_camera: Camera2D = $nivel2_camera

@onready var spritehombre: AnimatedSprite2D = $AnimatedSprite2D
@onready var spritemujer: AnimatedSprite2D = $AnimatedSprite2D2

var sprite_actual: AnimatedSprite2D


func _ready() -> void:
	add_to_group("player")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

	configurar_personaje()
	call_deferred("update_current_camera")


func configurar_personaje() -> void:
	if Global.personaje_seleccionado == 0:
		spritehombre.visible = true
		spritemujer.visible = false
		sprite_actual = spritehombre
	else:
		spritehombre.visible = false
		spritemujer.visible = true
		sprite_actual = spritemujer

	if sprite_actual != null:
		sprite_actual.play("front_idle")


func _physics_process(_delta: float) -> void:
	if GameManager.is_dialogue_active:
		velocity = Vector2.ZERO
		play_anim(0)
		return

	player_movement()


func player_movement() -> void:
	var input_vector := Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		input_vector.x = 1
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		input_vector.x = -1
	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		input_vector.y = 1
	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		input_vector.y = -1

	velocity = input_vector * speed
	move_and_slide()

	var moved_distance := get_position_delta().length()

	if input_vector == Vector2.ZERO:
		play_anim(0)
	elif moved_distance > 0.01:
		play_anim(1)
	else:
		velocity = Vector2.ZERO
		play_anim(0)


func play_anim(movement: int) -> void:
	if sprite_actual == null:
		return

	if current_dir == "right":
		sprite_actual.flip_h = false
		if movement == 1:
			sprite_actual.play("side_walk")
		else:
			sprite_actual.play("side_idle")

	elif current_dir == "left":
		sprite_actual.flip_h = true
		if movement == 1:
			sprite_actual.play("side_walk")
		else:
			sprite_actual.play("side_idle")

	elif current_dir == "down":
		sprite_actual.flip_h = false
		if movement == 1:
			sprite_actual.play("front_walk")
		else:
			sprite_actual.play("front_idle")

	elif current_dir == "up":
		sprite_actual.flip_h = false
		if movement == 1:
			sprite_actual.play("back_walk")
		else:
			sprite_actual.play("back_idle")


func update_current_camera() -> void:
	if not is_inside_tree():
		return

	var tree := get_tree()
	if tree == null:
		return

	var current_scene := tree.current_scene
	if current_scene == null:
		return

	world_camera.enabled = false
	bodega_camera.enabled = false
	nivel2_camera.enabled = false

	if current_scene.scene_file_path == "res://scenes/world.tscn":
		world_camera.enabled = true
		world_camera.make_current()
	elif current_scene.scene_file_path == "res://scenes/bodega.tscn":
		bodega_camera.enabled = true
		bodega_camera.make_current()
	elif current_scene.scene_file_path == "res://scenes/nivel_2.tscn":
		nivel2_camera.enabled = true
		nivel2_camera.make_current()
