extends Node2D

const BENCHMARK_NPC = preload("res://scenes/benchmarks/benchmark_npc.tscn")

@export var world_chunk_scene: PackedScene
@export var level1_chunk_scene: PackedScene

@export var world_chunk_position: Vector2 = Vector2(0, 0)
@export var level1_chunk_position: Vector2 = Vector2(4300, 0)

@export var fallback_world_spawn: Vector2 = Vector2(500, 500)
@export var fallback_level1_spawn: Vector2 = Vector2(4700, 500)

@export var world_spawn_rect: Rect2 = Rect2(Vector2(120, 120), Vector2(3200, 1700))
@export var level1_spawn_rect: Rect2 = Rect2(Vector2(4420, 120), Vector2(2200, 1400))

@export var world_npc_count: int = 20
@export var level1_npc_count: int = 15

@export var world_prop_count: int = 40
@export var level1_prop_count: int = 30

@export var world_obstacle_count: int = 18
@export var level1_obstacle_count: int = 14

@export var world_area_cols: int = 5
@export var world_area_rows: int = 3
@export var level1_area_cols: int = 4
@export var level1_area_rows: int = 3

@export var auto_spike: bool = true
@export var spike_delay: float = 10.0
@export var extra_npcs_per_zone: int = 10
@export var extra_props_per_zone: int = 15

@export var teleport_cooldown: float = 0.7
@export var portal_size_world_to_level1: Vector2 = Vector2(90, 70)
@export var portal_size_level1_to_world: Vector2 = Vector2(90, 70)

var elapsed: float = 0.0
var total_events: int = 0
var active_areas: int = 0
var spike_done: bool = false
var teleport_locked_until: float = 0.0

var world_chunk_instance: Node = null
var level1_chunk_instance: Node = null

var world_spawn_marker: Node2D = null
var level1_spawn_marker: Node2D = null
var world_to_level1_marker: Node2D = null
var level1_to_world_marker: Node2D = null

@onready var world_chunk_container: Node2D = $WorldChunkContainer
@onready var level1_chunk_container: Node2D = $Level1ChunkContainer
@onready var obstacle_container: Node2D = $DynamicObstacleContainer
@onready var prop_container: Node2D = $DynamicPropContainer
@onready var area_container: Node2D = $DynamicAreaContainer
@onready var npc_container: Node2D = $DynamicNPCContainer
@onready var player: CharacterBody2D = $man_player
@onready var hud = $BenchmarkHUD
@onready var player_camera: Camera2D = $man_player/Camera2D

func _ready() -> void:
	randomize()

	world_chunk_instance = _instantiate_chunk(world_chunk_scene, world_chunk_container, world_chunk_position, "WORLD")
	level1_chunk_instance = _instantiate_chunk(level1_chunk_scene, level1_chunk_container, level1_chunk_position, "LEVEL1")

	_cache_benchmark_nodes()
	_configure_camera_unlimited()
	_print_debug_positions()

	_teleport_to_world(false)

	_spawn_zone_npcs(world_spawn_rect, world_npc_count)
	_spawn_zone_npcs(level1_spawn_rect, level1_npc_count)

	_spawn_zone_props(world_spawn_rect, world_prop_count)
	_spawn_zone_props(level1_spawn_rect, level1_prop_count)

	_spawn_zone_obstacles(world_spawn_rect, world_obstacle_count)
	_spawn_zone_obstacles(level1_spawn_rect, level1_obstacle_count)

	_create_area_grid(world_spawn_rect, world_area_cols, world_area_rows)
	_create_area_grid(level1_spawn_rect, level1_area_cols, level1_area_rows)

func _process(delta: float) -> void:
	elapsed += delta

	_check_portal_positions()

	if auto_spike and not spike_done and elapsed >= spike_delay:
		spike_done = true
		_spawn_zone_npcs(world_spawn_rect, extra_npcs_per_zone)
		_spawn_zone_npcs(level1_spawn_rect, extra_npcs_per_zone)
		_spawn_zone_props(world_spawn_rect, extra_props_per_zone)
		_spawn_zone_props(level1_spawn_rect, extra_props_per_zone)

	hud.set_values(
		"Benchmark integrado",
		elapsed,
		npc_container.get_child_count(),
		prop_container.get_child_count() + obstacle_container.get_child_count(),
		active_areas,
		total_events
	)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_F1:
				_teleport_to_world()
			KEY_F2:
				_teleport_to_level1()
			KEY_F3:
				_spawn_zone_npcs(world_spawn_rect, extra_npcs_per_zone)
				_spawn_zone_npcs(level1_spawn_rect, extra_npcs_per_zone)
				_spawn_zone_props(world_spawn_rect, extra_props_per_zone)
				_spawn_zone_props(level1_spawn_rect, extra_props_per_zone)
			KEY_F4:
				_clear_dynamic_load()
			KEY_F5:
				_reload_dynamic_load()

func _instantiate_chunk(scene: PackedScene, container: Node2D, pos: Vector2, label: String) -> Node:
	if scene == null:
		push_warning("No se asignó la escena del chunk: " + label)
		return null

	var instance = scene.instantiate()
	instance.position = pos
	container.add_child(instance)
	_sanitize_chunk(instance)
	return instance

func _sanitize_chunk(root: Node) -> void:
	for child in root.get_children():
		_sanitize_chunk(child)

	if root.name == "man_player" or root.name == "woman_player":
		root.queue_free()
		return

	if root is Camera2D:
		root.queue_free()
		return

	# Elimina áreas reales de cambio de escena si todavía quedaron.
	if root is Area2D and _has_property(root, "next_scene_path"):
		root.queue_free()
		return

func _has_property(node: Object, property_name: String) -> bool:
	for prop in node.get_property_list():
		if prop.name == property_name:
			return true
	return false

func _cache_benchmark_nodes() -> void:
	if world_chunk_instance != null:
		world_spawn_marker = _find_node2d_recursive(world_chunk_instance, "BenchmarkSpawn")
		world_to_level1_marker = _find_node2d_recursive(world_chunk_instance, "BenchmarkToLevel1")

	if level1_chunk_instance != null:
		level1_spawn_marker = _find_node2d_recursive(level1_chunk_instance, "BenchmarkSpawn")
		level1_to_world_marker = _find_node2d_recursive(level1_chunk_instance, "BenchmarkToWorld")

	if world_spawn_marker == null:
		push_warning("No se encontró BenchmarkSpawn en world_benchmark_chunk")
	if world_to_level1_marker == null:
		push_warning("No se encontró BenchmarkToLevel1 en world_benchmark_chunk")
	if level1_spawn_marker == null:
		push_warning("No se encontró BenchmarkSpawn en level1_benchmark_chunk")
	if level1_to_world_marker == null:
		push_warning("No se encontró BenchmarkToWorld en level1_benchmark_chunk")

func _find_node2d_recursive(root: Node, target_name: String) -> Node2D:
	if root is Node2D and root.name == target_name:
		return root

	for child in root.get_children():
		var found = _find_node2d_recursive(child, target_name)
		if found != null:
			return found

	return null

func _configure_camera_unlimited() -> void:
	if player_camera == null:
		return

	# Límites enormes para evitar que la cámara se quede encerrada en world.
	player_camera.limit_left = -100000
	player_camera.limit_top = -100000
	player_camera.limit_right = 100000
	player_camera.limit_bottom = 100000

	if player_camera.has_method("reset_smoothing"):
		player_camera.reset_smoothing()

	if player_camera.has_method("force_update_scroll"):
		player_camera.force_update_scroll()

	print("Camera limits ampliados para benchmark")

func _print_debug_positions() -> void:
	if world_spawn_marker != null:
		print("WORLD BenchmarkSpawn: ", world_spawn_marker.global_position)
	if world_to_level1_marker != null:
		print("WORLD BenchmarkToLevel1: ", world_to_level1_marker.global_position)
	if level1_spawn_marker != null:
		print("LEVEL1 BenchmarkSpawn: ", level1_spawn_marker.global_position)
	if level1_to_world_marker != null:
		print("LEVEL1 BenchmarkToWorld: ", level1_to_world_marker.global_position)

func _check_portal_positions() -> void:
	if _teleport_is_locked():
		return

	if world_to_level1_marker != null:
		if _point_inside_portal(player.global_position, world_to_level1_marker.global_position, portal_size_world_to_level1):
			print("Entrada detectada: WORLD -> LEVEL1")
			_teleport_to_level1()
			return

	if level1_to_world_marker != null:
		if _point_inside_portal(player.global_position, level1_to_world_marker.global_position, portal_size_level1_to_world):
			print("Entrada detectada: LEVEL1 -> WORLD")
			_teleport_to_world()
			return

func _point_inside_portal(point: Vector2, center: Vector2, size: Vector2) -> bool:
	var rect := Rect2(center - size / 2.0, size)
	return rect.has_point(point)

func _teleport_is_locked() -> bool:
	var now = Time.get_ticks_msec() / 1000.0
	return now < teleport_locked_until

func _lock_teleport() -> void:
	teleport_locked_until = Time.get_ticks_msec() / 1000.0 + teleport_cooldown

func _teleport_to_world(lock_after: bool = true) -> void:
	player.velocity = Vector2.ZERO

	if world_spawn_marker != null:
		player.global_position = world_spawn_marker.global_position
	else:
		player.global_position = fallback_world_spawn

	if player_camera != null:
		if player_camera.has_method("reset_smoothing"):
			player_camera.reset_smoothing()
		if player_camera.has_method("force_update_scroll"):
			player_camera.force_update_scroll()

	print("Teleport a WORLD => ", player.global_position)

	if lock_after:
		_lock_teleport()

func _teleport_to_level1(lock_after: bool = true) -> void:
	player.velocity = Vector2.ZERO

	if level1_spawn_marker != null:
		player.global_position = level1_spawn_marker.global_position
	else:
		player.global_position = fallback_level1_spawn

	if player_camera != null:
		if player_camera.has_method("reset_smoothing"):
			player_camera.reset_smoothing()
		if player_camera.has_method("force_update_scroll"):
			player_camera.force_update_scroll()

	print("Teleport a LEVEL1 => ", player.global_position)

	if lock_after:
		_lock_teleport()

func _spawn_zone_npcs(zone: Rect2, count: int) -> void:
	for i in range(count):
		var npc = BENCHMARK_NPC.instantiate()
		npc.global_position = _random_point_in_rect(zone, 60.0)
		npc.speed = randf_range(55.0, 95.0)
		npc.movement_rect = zone
		npc_container.add_child(npc)

func _spawn_zone_props(zone: Rect2, count: int) -> void:
	for i in range(count):
		var prop = _create_render_prop(_random_point_in_rect(zone, 30.0))
		prop_container.add_child(prop)

func _spawn_zone_obstacles(zone: Rect2, count: int) -> void:
	for i in range(count):
		var obstacle = _create_static_obstacle(
			_random_point_in_rect(zone, 80.0),
			Vector2(randf_range(36.0, 72.0), randf_range(36.0, 72.0))
		)
		obstacle_container.add_child(obstacle)

func _create_render_prop(pos: Vector2) -> Node2D:
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
		randf_range(0.35, 0.90),
		randf_range(0.35, 0.90),
		randf_range(0.35, 0.90),
		0.45
	)

	prop.add_child(poly)
	return prop

func _create_static_obstacle(pos: Vector2, size: Vector2) -> StaticBody2D:
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
	poly.color = Color(0.45, 0.65, 0.90, 0.70)

	body.add_child(collision)
	body.add_child(poly)
	return body

func _create_area_grid(zone: Rect2, cols: int, rows: int) -> void:
	if cols <= 0 or rows <= 0:
		return

	var cell_w = zone.size.x / cols
	var cell_h = zone.size.y / rows

	for row in range(rows):
		for col in range(cols):
			var area := Area2D.new()
			area.position = Vector2(
				zone.position.x + col * cell_w + cell_w / 2.0,
				zone.position.y + row * cell_h + cell_h / 2.0
			)
			area.monitoring = true
			area.monitorable = true
			area.set_meta("active", false)

			var collision := CollisionShape2D.new()
			var shape := RectangleShape2D.new()
			shape.size = Vector2(cell_w * 0.60, cell_h * 0.60)
			collision.shape = shape

			var poly := Polygon2D.new()
			var w := shape.size.x
			var h := shape.size.y
			poly.polygon = PackedVector2Array([
				Vector2(-w / 2.0, -h / 2.0),
				Vector2(w / 2.0, -h / 2.0),
				Vector2(w / 2.0, h / 2.0),
				Vector2(-w / 2.0, h / 2.0)
			])
			poly.color = Color(1.0, 0.75, 0.15, 0.16)

			area.add_child(collision)
			area.add_child(poly)

			area.body_entered.connect(_on_stress_area_body_entered.bind(area))
			area.body_exited.connect(_on_stress_area_body_exited.bind(area))

			area_container.add_child(area)

func _on_stress_area_body_entered(body: Node, area: Area2D) -> void:
	if body.name != "man_player":
		return

	total_events += 1

	if not area.get_meta("active"):
		area.set_meta("active", true)
		active_areas += 1

	var poly: Polygon2D = area.get_child(1)
	poly.color = Color(0.20, 1.00, 0.30, 0.22)

func _on_stress_area_body_exited(body: Node, area: Area2D) -> void:
	if body.name != "man_player":
		return

	total_events += 1

	if area.get_meta("active"):
		area.set_meta("active", false)
		active_areas -= 1

	var poly: Polygon2D = area.get_child(1)
	poly.color = Color(1.0, 0.75, 0.15, 0.16)

func _clear_dynamic_load() -> void:
	for child in npc_container.get_children():
		child.queue_free()

	for child in prop_container.get_children():
		child.queue_free()

	for child in obstacle_container.get_children():
		child.queue_free()

func _reload_dynamic_load() -> void:
	_clear_dynamic_load()
	_spawn_zone_npcs(world_spawn_rect, world_npc_count)
	_spawn_zone_npcs(level1_spawn_rect, level1_npc_count)
	_spawn_zone_props(world_spawn_rect, world_prop_count)
	_spawn_zone_props(level1_spawn_rect, level1_prop_count)
	_spawn_zone_obstacles(world_spawn_rect, world_obstacle_count)
	_spawn_zone_obstacles(level1_spawn_rect, level1_obstacle_count)

func _random_point_in_rect(rect: Rect2, margin: float = 0.0) -> Vector2:
	return Vector2(
		randf_range(rect.position.x + margin, rect.position.x + rect.size.x - margin),
		randf_range(rect.position.y + margin, rect.position.y + rect.size.y - margin)
	)
