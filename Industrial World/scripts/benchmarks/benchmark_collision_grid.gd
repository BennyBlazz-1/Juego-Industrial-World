extends Node2D

const BENCHMARK_NPC = preload("res://scenes/benchmarks/benchmark_npc.tscn")

@export var map_size: Vector2 = Vector2(3200, 1800)
@export var cols: int = 24
@export var rows: int = 14
@export var obstacle_size: Vector2 = Vector2(60, 60)
@export var spacing: Vector2 = Vector2(110, 110)
@export var corridor_every: int = 4
@export var npc_count: int = 35

var elapsed: float = 0.0

@onready var environment_container: Node2D = $EnvironmentContainer
@onready var obstacle_container: Node2D = $ObstacleContainer
@onready var npc_container: Node2D = $NPCContainer
@onready var player: CharacterBody2D = $man_player
@onready var hud = $BenchmarkHUD

func _ready() -> void:
	randomize()
	create_floor()
	generate_obstacles()
	spawn_npcs(npc_count)
	player.global_position = Vector2(120, 120)

func _process(delta: float) -> void:
	elapsed += delta

	hud.set_values(
		"Grid de colisiones",
		elapsed,
		npc_container.get_child_count(),
		obstacle_container.get_child_count(),
		0,
		0
	)

func create_floor() -> void:
	var floor := Polygon2D.new()
	floor.z_index = -10
	floor.color = Color(0.13, 0.13, 0.15, 1.0)
	floor.polygon = PackedVector2Array([
		Vector2(0, 0),
		Vector2(map_size.x, 0),
		Vector2(map_size.x, map_size.y),
		Vector2(0, map_size.y)
	])
	environment_container.add_child(floor)

func generate_obstacles() -> void:
	var start := Vector2(100, 100)

	for y in range(rows):
		for x in range(cols):
			if x % corridor_every == 0 or y % corridor_every == 0:
				continue

			var pos := start + Vector2(x * spacing.x, y * spacing.y)
			obstacle_container.add_child(create_obstacle(pos, obstacle_size))

func create_obstacle(pos: Vector2, size: Vector2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = pos

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape

	var poly := Polygon2D.new()
	var w := size.x
	var h := size.y
	poly.polygon = PackedVector2Array([
		Vector2(-w / 2.0, -h / 2.0),
		Vector2(w / 2.0, -h / 2.0),
		Vector2(w / 2.0, h / 2.0),
		Vector2(-w / 2.0, h / 2.0)
	])
	poly.color = Color(0.55, 0.65, 0.75, 0.95)

	body.add_child(collision)
	body.add_child(poly)

	return body

func spawn_npcs(count: int) -> void:
	for i in range(count):
		var npc = BENCHMARK_NPC.instantiate()
		npc.global_position = random_point()
		npc.speed = randf_range(55.0, 90.0)
		npc.movement_rect = Rect2(Vector2.ZERO, map_size)
		npc_container.add_child(npc)

func random_point(margin: float = 120.0) -> Vector2:
	return Vector2(
		randf_range(margin, map_size.x - margin),
		randf_range(margin, map_size.y - margin)
	)
