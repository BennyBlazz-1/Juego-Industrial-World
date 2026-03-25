extends Node2D


const BENCHMARK_NPC = preload("res://scenes/benchmarks/benchmark_npc.tscn")

@export var map_size: Vector2 = Vector2(3200, 1800)
@export var npc_per_wave: int = 40
@export var props_per_wave: int = 80
@export var wave_duration: float = 3.0
@export var total_waves: int = 15

var elapsed: float = 0.0
var wave_timer: float = 0.0
var current_wave: int = 0
var total_created: int = 0
var finished_clear: bool = false

@onready var environment_container: Node2D = $EnvironmentContainer
@onready var npc_container: Node2D = $NPCContainer
@onready var prop_container: Node2D = $PropContainer
@onready var player: CharacterBody2D = $man_player
@onready var hud = $BenchmarkHUD

func _ready() -> void:
	randomize()
	create_floor()
	player.global_position = map_size / 2.0
	start_wave(1)

func _process(delta: float) -> void:
	elapsed += delta

	if not finished_clear:
		wave_timer -= delta

		if wave_timer <= 0.0:
			if current_wave < total_waves:
				start_wave(current_wave + 1)
			else:
				clear_current_wave()
				finished_clear = true

	hud.set_values(
		"Churn de instancias",
		elapsed,
		npc_container.get_child_count(),
		prop_container.get_child_count(),
		0,
		total_created
	)

func create_floor() -> void:
	var floor := Polygon2D.new()
	floor.z_index = -10
	floor.color = Color(0.15, 0.17, 0.20, 1.0)
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

func start_wave(index: int) -> void:
	clear_current_wave()
	current_wave = index
	spawn_npcs(npc_per_wave)
	spawn_props(props_per_wave)
	total_created += npc_per_wave + props_per_wave
	wave_timer = wave_duration

func clear_current_wave() -> void:
	for child in npc_container.get_children():
		child.queue_free()

	for child in prop_container.get_children():
		child.queue_free()

func spawn_npcs(count: int) -> void:
	for i in range(count):
		var npc = BENCHMARK_NPC.instantiate()
		npc.global_position = random_point()
		npc.speed = randf_range(60.0, 100.0)
		npc.movement_rect = Rect2(Vector2.ZERO, map_size)
		npc_container.add_child(npc)

func spawn_props(count: int) -> void:
	for i in range(count):
		prop_container.add_child(create_prop(random_point()))

func create_prop(pos: Vector2) -> Node2D:
	var prop := Node2D.new()
	prop.position = pos

	var poly := Polygon2D.new()
	var w := randf_range(18.0, 48.0)
	var h := randf_range(18.0, 48.0)

	poly.polygon = PackedVector2Array([
		Vector2(-w / 2.0, -h / 2.0),
		Vector2(w / 2.0, -h / 2.0),
		Vector2(w / 2.0, h / 2.0),
		Vector2(-w / 2.0, h / 2.0)
	])

	poly.color = Color(
		randf_range(0.4, 0.8),
		randf_range(0.4, 0.8),
		randf_range(0.4, 0.8),
		0.9
	)

	prop.add_child(poly)
	return prop
