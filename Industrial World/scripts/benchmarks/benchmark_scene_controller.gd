extends Node

const BENCHMARK_NPC: PackedScene = preload("res://scenes/benchmarks/benchmark_npc.tscn")

@export var test_name: String = "Benchmark"
@export var enabled_benchmark: bool = true

@export var npc_per_zone: int = 6
@export var props_per_zone: int = 12
@export var obstacles_per_zone: int = 4
@export var areas_per_zone: int = 3

@export var npc_spawn_radius: float = 70.0
@export var npc_move_radius: float = 140.0
@export var prop_spawn_radius: float = 90.0
@export var obstacle_spawn_radius: float = 90.0
@export var area_spawn_radius: float = 100.0

@export var npc_speed_min: float = 55.0
@export var npc_speed_max: float = 90.0

@export var obstacle_min_size: Vector2 = Vector2(32, 32)
@export var obstacle_max_size: Vector2 = Vector2(64, 64)
@export var stress_area_size: Vector2 = Vector2(70, 70)

# Teclas para agregar carga en tiempo real
@export var npc_add_per_keypress: int = 2
@export var areas_add_per_keypress: int = 1
@export var max_npcs_runtime: int = 800
@export var max_areas_runtime: int = 800

var elapsed: float = 0.0
var total_events: int = 0
var active_areas: int = 0

var hud: CanvasLayer = null
var scene_root: Node = null
var player: CharacterBody2D = null

var npc_container: Node2D = null
var prop_container: Node2D = null
var obstacle_container: Node2D = null
var area_container: Node2D = null

func _ready() -> void:
	if not enabled_benchmark:
		return

	randomize()
	set_process_unhandled_input(true)

	scene_root = get_parent()
	player = scene_root.get_node_or_null("man_player") as CharacterBody2D

	_ensure_dynamic_containers()
	_ensure_hud()
	_spawn_all_benchmark_load()

func _process(delta: float) -> void:
	if not enabled_benchmark:
		return

	elapsed += delta

	if hud != null and hud.has_method("set_values"):
		hud.call(
			"set_values",
			test_name,
			elapsed,
			npc_container.get_child_count(),
			prop_container.get_child_count() + obstacle_container.get_child_count(),
			active_areas,
			total_events
		)

func _unhandled_input(event: InputEvent) -> void:
	if not enabled_benchmark:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_N:
				_add_runtime_npcs()
			KEY_A:
				_add_runtime_areas()

func _ensure_dynamic_containers() -> void:
	npc_container = _ensure_node2d("BenchmarkDynamicNPCs")
	prop_container = _ensure_node2d("BenchmarkDynamicProps")
	obstacle_container = _ensure_node2d("BenchmarkDynamicObstacles")
	area_container = _ensure_node2d("BenchmarkDynamicAreas")

func _ensure_node2d(node_name: String) -> Node2D:
	var node: Node2D = scene_root.get_node_or_null(node_name) as Node2D
	if node == null:
		node = Node2D.new()
		node.name = node_name
		scene_root.add_child(node)
	return node

func _ensure_hud() -> void:
	hud = scene_root.get_node_or_null("BenchmarkHUD") as CanvasLayer

func _spawn_all_benchmark_load() -> void:
	_spawn_npcs()
	_spawn_props()
	_spawn_obstacles()
	_spawn_stress_areas()

func _spawn_npcs() -> void:
	var markers: Array[Node2D] = _get_zone_markers("NPCZones")

	for marker in markers:
		for i in range(npc_per_zone):
			_spawn_single_npc(marker)

func _spawn_props() -> void:
	var markers: Array[Node2D] = _get_zone_markers("PropZones")

	for marker in markers:
		for i in range(props_per_zone):
			var prop: Node2D = _create_visual_prop(_random_point_in_circle(marker.global_position, prop_spawn_radius))
			prop_container.add_child(prop)

func _spawn_obstacles() -> void:
	var markers: Array[Node2D] = _get_zone_markers("ObstacleZones")

	for marker in markers:
		for i in range(obstacles_per_zone):
			var size: Vector2 = Vector2(
				randf_range(obstacle_min_size.x, obstacle_max_size.x),
				randf_range(obstacle_min_size.y, obstacle_max_size.y)
			)

			var obstacle: StaticBody2D = _create_static_obstacle(
				_random_point_in_circle(marker.global_position, obstacle_spawn_radius),
				size
			)

			obstacle_container.add_child(obstacle)

func _spawn_stress_areas() -> void:
	var markers: Array[Node2D] = _get_zone_markers("AreaZones")

	for marker in markers:
		for i in range(areas_per_zone):
			_spawn_single_area(marker)

func _spawn_single_npc(marker: Node2D) -> void:
	var npc: CharacterBody2D = BENCHMARK_NPC.instantiate() as CharacterBody2D
	var spawn_pos: Vector2 = _random_point_in_circle(marker.global_position, npc_spawn_radius)

	npc.global_position = spawn_pos
	npc.set("speed", randf_range(npc_speed_min, npc_speed_max))
	npc.set(
		"movement_rect",
		Rect2(
			marker.global_position - Vector2(npc_move_radius, npc_move_radius),
			Vector2(npc_move_radius * 2.0, npc_move_radius * 2.0)
		)
	)

	npc_container.add_child(npc)

func _spawn_single_area(marker: Node2D) -> void:
	var stress_area: Area2D = _create_stress_area(
		_random_point_in_circle(marker.global_position, area_spawn_radius),
		stress_area_size
	)
	area_container.add_child(stress_area)

func _add_runtime_npcs() -> void:
	var markers: Array[Node2D] = _get_zone_markers("NPCZones")
	if markers.is_empty():
		print("No hay markers en NPCZones")
		return

	var current_npcs: int = npc_container.get_child_count()
	if current_npcs >= max_npcs_runtime:
		print("Límite de NPC alcanzado: ", max_npcs_runtime)
		return

	var available: int = max_npcs_runtime - current_npcs
	var requested_total: int = markers.size() * npc_add_per_keypress
	var total_to_add: int = requested_total if requested_total < available else available

	for marker in markers:
		for i in range(npc_add_per_keypress):
			if total_to_add <= 0:
				break
			_spawn_single_npc(marker)
			total_to_add -= 1

	print("NPC agregados. Total actual: ", npc_container.get_child_count())

func _add_runtime_areas() -> void:
	var markers: Array[Node2D] = _get_zone_markers("AreaZones")
	if markers.is_empty():
		print("No hay markers en AreaZones")
		return

	var current_areas: int = area_container.get_child_count()
	if current_areas >= max_areas_runtime:
		print("Límite de áreas alcanzado: ", max_areas_runtime)
		return

	var available: int = max_areas_runtime - current_areas
	var requested_total: int = markers.size() * areas_add_per_keypress
	var total_to_add: int = requested_total if requested_total < available else available

	for marker in markers:
		for i in range(areas_add_per_keypress):
			if total_to_add <= 0:
				break
			_spawn_single_area(marker)
			total_to_add -= 1

	print("Áreas agregadas. Total actual: ", area_container.get_child_count())

func _get_zone_markers(zone_group_name: String) -> Array[Node2D]:
	var results: Array[Node2D] = []

	var group_root: Node = scene_root.get_node_or_null("BenchmarkZones/" + zone_group_name)
	if group_root == null:
		return results

	for child in group_root.get_children():
		if child is Node2D:
			results.append(child as Node2D)

	return results

func _random_point_in_circle(center: Vector2, radius: float) -> Vector2:
	var angle: float = randf_range(0.0, TAU)
	var dist: float = sqrt(randf()) * radius
	return center + Vector2(cos(angle), sin(angle)) * dist

func _create_visual_prop(pos: Vector2) -> Node2D:
	var prop: Node2D = Node2D.new()
	prop.global_position = pos

	var poly: Polygon2D = Polygon2D.new()
	var w: float = randf_range(18.0, 50.0)
	var h: float = randf_range(18.0, 50.0)

	poly.polygon = PackedVector2Array([
		Vector2(-w / 2.0, -h / 2.0),
		Vector2(w / 2.0, -h / 2.0),
		Vector2(w / 2.0, h / 2.0),
		Vector2(-w / 2.0, h / 2.0)
	])

	poly.color = Color(
		randf_range(0.4, 0.85),
		randf_range(0.4, 0.85),
		randf_range(0.4, 0.85),
		0.45
	)

	prop.add_child(poly)
	return prop

func _create_static_obstacle(pos: Vector2, size: Vector2) -> StaticBody2D:
	var body: StaticBody2D = StaticBody2D.new()
	body.global_position = pos

	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = size
	collision.shape = shape

	var poly: Polygon2D = Polygon2D.new()
	var w: float = size.x
	var h: float = size.y

	poly.polygon = PackedVector2Array([
		Vector2(-w / 2.0, -h / 2.0),
		Vector2(w / 2.0, -h / 2.0),
		Vector2(w / 2.0, h / 2.0),
		Vector2(-w / 2.0, h / 2.0)
	])

	poly.color = Color(0.35, 0.65, 0.9, 0.75)

	body.add_child(collision)
	body.add_child(poly)

	return body

func _create_stress_area(pos: Vector2, size: Vector2) -> Area2D:
	var area: Area2D = Area2D.new()
	area.global_position = pos
	area.monitoring = true
	area.monitorable = true
	area.name = "BenchmarkStressArea"

	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = size
	collision.shape = shape

	var poly: Polygon2D = Polygon2D.new()
	var w: float = size.x
	var h: float = size.y

	poly.polygon = PackedVector2Array([
		Vector2(-w / 2.0, -h / 2.0),
		Vector2(w / 2.0, -h / 2.0),
		Vector2(w / 2.0, h / 2.0),
		Vector2(-w / 2.0, h / 2.0)
	])

	poly.color = Color(1.0, 0.75, 0.15, 0.18)

	area.add_child(collision)
	area.add_child(poly)

	area.body_entered.connect(_on_stress_area_body_entered.bind(area))
	area.body_exited.connect(_on_stress_area_body_exited.bind(area))

	return area

func _on_stress_area_body_entered(body: Node2D, area: Area2D) -> void:
	if body.name != "man_player":
		return

	total_events += 1

	if not area.has_meta("active"):
		area.set_meta("active", true)
		active_areas += 1

	var poly: Polygon2D = area.get_child(1) as Polygon2D
	if poly != null:
		poly.color = Color(0.2, 1.0, 0.3, 0.22)

func _on_stress_area_body_exited(body: Node2D, area: Area2D) -> void:
	if body.name != "man_player":
		return

	total_events += 1

	if area.has_meta("active"):
		area.remove_meta("active")
		active_areas -= 1

	var poly: Polygon2D = area.get_child(1) as Polygon2D
	if poly != null:
		poly.color = Color(1.0, 0.75, 0.15, 0.18)
