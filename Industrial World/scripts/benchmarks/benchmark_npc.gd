extends CharacterBody2D

@export var speed: float = 70.0
@export var min_change_time: float = 0.7
@export var max_change_time: float = 1.8
@export var movement_rect: Rect2 = Rect2(Vector2(0, 0), Vector2(2400, 1400))

var direction: Vector2 = Vector2.RIGHT
var change_direction_timer: float = 0.0
var current_dir: String = "right"

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	randomize()
	choose_new_direction()

func _physics_process(delta: float) -> void:
	change_direction_timer -= delta

	if change_direction_timer <= 0.0:
		choose_new_direction()

	velocity = direction * speed
	move_and_slide()
	keep_inside_bounds()
	update_animation()

func choose_new_direction() -> void:
	var dirs := [
		Vector2.RIGHT,
		Vector2.LEFT,
		Vector2.UP,
		Vector2.DOWN,
		Vector2(1, 1).normalized(),
		Vector2(-1, 1).normalized(),
		Vector2(1, -1).normalized(),
		Vector2(-1, -1).normalized()
	]

	direction = dirs[randi() % dirs.size()]
	change_direction_timer = randf_range(min_change_time, max_change_time)

func keep_inside_bounds() -> void:
	var pos := global_position
	var min_pos := movement_rect.position
	var max_pos := movement_rect.position + movement_rect.size
	var bounced := false

	if pos.x < min_pos.x:
		pos.x = min_pos.x
		direction.x = abs(direction.x)
		bounced = true
	elif pos.x > max_pos.x:
		pos.x = max_pos.x
		direction.x = -abs(direction.x)
		bounced = true

	if pos.y < min_pos.y:
		pos.y = min_pos.y
		direction.y = abs(direction.y)
		bounced = true
	elif pos.y > max_pos.y:
		pos.y = max_pos.y
		direction.y = -abs(direction.y)
		bounced = true

	global_position = pos

	if bounced:
		change_direction_timer = randf_range(min_change_time, max_change_time)

func update_animation() -> void:
	if abs(direction.x) > abs(direction.y):
		current_dir = "right" if direction.x > 0 else "left"
	else:
		current_dir = "down" if direction.y > 0 else "up"

	if current_dir == "right":
		anim.flip_h = false
		anim.play("side_walk")
	elif current_dir == "left":
		anim.flip_h = true
		anim.play("side_walk")
	elif current_dir == "down":
		anim.flip_h = true
		anim.play("front_walk")
	elif current_dir == "up":
		anim.flip_h = true
		anim.play("back_walk")
