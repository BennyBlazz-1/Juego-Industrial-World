extends CharacterBody2D

const speed = 200
var current_dir = "none"

@onready var world_camera: Camera2D = $world_camera
@onready var bodega_camera: Camera2D = $bodega_camera

func _ready():
	add_to_group("player")
	$AnimatedSprite2D.play("front_idle")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	call_deferred("update_current_camera")

func _physics_process(_delta):
	if GameManager.is_dialogue_active:
		velocity = Vector2.ZERO
		play_anim(0)
		return
	woman_player_movement()

func woman_player_movement():
	var input_vector: Vector2 = Vector2.ZERO

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

	var moved_distance: float = get_position_delta().length()

	if input_vector == Vector2.ZERO:
		play_anim(0)
	elif moved_distance > 0.01:
		play_anim(1)
	else:
		velocity = Vector2.ZERO
		play_anim(0)

func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D

	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("side_walk")
		else:
			anim.play("side_idle")

	if dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("side_walk")
		else:
			anim.play("side_idle")

	if dir == "down":
		anim.flip_h = true
		if movement == 1:
			anim.play("front_walk")
		else:
			anim.play("front_idle")

	if dir == "up":
		anim.flip_h = true
		if movement == 1:
			anim.play("back_walk")
		else:
			anim.play("back_idle")

func update_current_camera() -> void:
	var current_scene: Node = get_tree().current_scene
	if current_scene == null:
		return

	world_camera.enabled = false
	bodega_camera.enabled = false

	if current_scene.scene_file_path == "res://scenes/world.tscn":
		world_camera.enabled = true
		world_camera.make_current()
	elif current_scene.scene_file_path == "res://scenes/bodega.tscn":
		bodega_camera.enabled = true
		bodega_camera.make_current()
