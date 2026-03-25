extends Node2D

const BENCHMARK_NPC = preload("res://scenes/benchmarks/benchmark_npc.tscn")

@export var map_size: Vector2 = Vector2(3200, 1800)
@export var initial_npc_count: int = 10
@export var initial_prop_count: int = 20
@export var spike_npc_count: int = 100
@export var spike_prop_count: int = 150
@export var spike_delay: float = 5.0

var elapsed: float = 0.0
var spike_done: bool = false

@onready var environment_container: Node2D = $EnvironmentContainer
@onready var npc_container: Node2D = $NPCContainer
@onready var prop_container: Node2D = $PropContainer
@onready var player: CharacterBody2D = $man_player
@onready var hud = $BenchmarkHUD

func _ready() -> void:
	randomize()
	create_floor()
	player.global_position = map_size / 2.0
	spawn_props(initial_prop_count)
	spawn_npcs(initial_npc_count)

func _process(delta: float) -> void:
	elapsed += delta

	if not spike_done and elapsed >= spike_delay:
		spike_done = true
		spawn_npcs(spike_npc_count)
		spawn_props(spike_prop_count)

	hud.set_values(
		"Spike de carga",
		elapsed,
		npc_container.get_child_count(),
		prop_container.get_child_count(),
		0,
		int(spike_done)
	)

func create_floor() -> void:
	var floor := Polygon2D.new()
	floor.z_index = -10
	floor.color = Color(0.18, 0.18, 0.20, 1.0)
	floor.polygon = PackedVector2Array([
		Vector2(0, 0),
		Vector2(map_size.x, 0),
		Vector2(map_size.x, map_size.y),
		Vector2(0, map_size.y)
	])
	environment_container.add_child(floor)

func random_point(margin: float = 80.0) -> Vector2:
	return Vector2(
		randf_range(margin, map_size.x - margin),
		randf_range(margin, map_size.y - margin)
	)

func spawn_npcs(count: int) -> void:
	for i in range(count):
		var npc = BENCHMARK_NPC.instantiate()
		npc.global_position = random_point()
		npc.speed = randf_range(60.0, 110.0)
		npc.movement_rect = Rect2(Vector2.ZERO, map_size)
		npc_container.add_child(npc)

func spawn_props(count: int) -> void:
	for i in range(count):
		prop_container.add_child(create_prop(random_point()))

func create_prop(pos: Vector2) -> Node2D:
	var prop := Node2D.new()
	prop.position = pos

	var poly := Polygon2D.new()
	var w := randf_range(20.0, 60.0)
	var h := randf_range(20.0, 60.0)

	poly.polygon = PackedVector2Array([
		Vector2(-w / 2.0, -h / 2.0),
		Vector2(w / 2.0, -h / 2.0),
		Vector2(w / 2.0, h / 2.0),
		Vector2(-w / 2.0, h / 2.0)
	])

	poly.color = Color(
		randf_range(0.3, 0.9),
		randf_range(0.3, 0.9),
		randf_range(0.3, 0.9),
		0.9
	)

	prop.add_child(poly)
	return prop
