extends Node2D

@export var map_size: Vector2 = Vector2(3200, 1800)
@export var columns: int = 20
@export var rows: int = 10
@export var cell_size: Vector2 = Vector2(120, 120)

var elapsed: float = 0.0
var active_areas: int = 0
var total_events: int = 0

@onready var environment_container: Node2D = $EnvironmentContainer
@onready var area_container: Node2D = $AreaContainer
@onready var player: CharacterBody2D = $man_player
@onready var hud = $BenchmarkHUD

func _ready() -> void:
	create_floor()
	player.global_position = Vector2(80, 80)
	generate_areas()

func _process(delta: float) -> void:
	elapsed += delta

	hud.set_values(
		"Campo masivo de Area2D",
		elapsed,
		0,
		0,
		active_areas,
		total_events
	)

func create_floor() -> void:
	var floor := Polygon2D.new()
	floor.z_index = -10
	floor.color = Color(0.12, 0.14, 0.17, 1.0)
	floor.polygon = PackedVector2Array([
		Vector2(0, 0),
		Vector2(map_size.x, 0),
		Vector2(map_size.x, map_size.y),
		Vector2(0, map_size.y)
	])
	environment_container.add_child(floor)

func generate_areas() -> void:
	var start := Vector2(100, 100)

	for y in range(rows):
		for x in range(columns):
			var test_area := Area2D.new()
			test_area.position = start + Vector2(x * cell_size.x, y * cell_size.y)
			test_area.monitoring = true
			test_area.monitorable = true
			test_area.set_meta("active", false)

			var collision := CollisionShape2D.new()
			var shape := RectangleShape2D.new()
			shape.size = cell_size * 0.8
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
			poly.color = Color(1.0, 0.5, 0.1, 0.25)

			test_area.add_child(collision)
			test_area.add_child(poly)

			test_area.body_entered.connect(_on_test_area_body_entered.bind(test_area))
			test_area.body_exited.connect(_on_test_area_body_exited.bind(test_area))

			area_container.add_child(test_area)

func _on_test_area_body_entered(body: Node, test_area: Area2D) -> void:
	if body.name != "man_player":
		return

	total_events += 1

	if not test_area.get_meta("active"):
		test_area.set_meta("active", true)
		active_areas += 1

	var poly: Polygon2D = test_area.get_child(1)
	poly.color = Color(0.2, 1.0, 0.3, 0.35)

func _on_test_area_body_exited(body: Node, test_area: Area2D) -> void:
	if body.name != "man_player":
		return

	total_events += 1

	if test_area.get_meta("active"):
		test_area.set_meta("active", false)
		active_areas -= 1

	var poly: Polygon2D = test_area.get_child(1)
	poly.color = Color(1.0, 0.5, 0.1, 0.25)
